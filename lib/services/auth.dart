import 'dart:async';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User currentUser;
  BehaviorSubject<User> profile = BehaviorSubject();

  AuthService() {
    _auth.authStateChanges().listen((u) => _setUser(u));
  }

  void _setUser(User u) {
    currentUser = u;
    profile.add(u);
  }

  void updateCurrentUser() => _setUser(_auth.currentUser);

  Future<User> signInWithEmailAndPass(email, password) async {
    final authResult = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return authResult.user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User> signInWithGoogle({AuthCredential previousCredential}) async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the google sign in flow
      throw Exception('User canceled google sign in');
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final authResult = await _auth.signInWithCredential(credential);
    User user = authResult.user;

    final googleApisUrl =
        'https://www.googleapis.com/oauth2/v3/userinfo?alt=json&access_token=${googleAuth.accessToken}';
    final response = await http.get(googleApisUrl);

    if (response.statusCode == 200) {
      Map<String, dynamic> userInfoJson = json.decode(response.body);
      if (userInfoJson['given_name'] != null ||
          userInfoJson['family_name'] != null ||
          userInfoJson['picture'] != null) {
        await updateUser(
          firstName: userInfoJson['given_name'],
          lastName: userInfoJson['family_name'],
          photoUrl: user.photoURL ?? userInfoJson['picture'],
        );
      }
    }

    if (previousCredential != null) {
      user.linkWithCredential(previousCredential).catchError(() {});
    }

    return user;
  }

  Future<User> signInWithFacebook(
    FacebookLoginResult result,
  ) async {
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=$token');

    if (graphResponse.statusCode != 200) {
      throw PlatformException(code: 'GRAPH_CALL_FAILED');
    }

    Map<String, dynamic> userInfoJson = json.decode(graphResponse.body);

    final credential = FacebookAuthProvider.credential(token);
    UserCredential authResult;
    try {
      authResult = await _auth.signInWithCredential(credential);
    } catch (e) {
      switch (e.code) {
        case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
          return _handleDifferentCredential(
            credential: credential,
            email: userInfoJson['email'],
          );
          break;
        default:
          throw e;
      }
    }
    User user = authResult.user;
    if (userInfoJson['first_name'] != null ||
        userInfoJson['last_name'] != null ||
        userInfoJson['picture'] != null) {
      updateUser(
        firstName: userInfoJson['first_name'],
        lastName: userInfoJson['last_name'],
        photoUrl: user.photoURL ?? userInfoJson['picture']['data']['url'],
      );
    }

    return user;
  }

  Future<User> signInWithApple(AuthorizationResult authorizationResult) async {
    final AppleIdCredential appleIdCredential = authorizationResult.credential;

    OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    final AuthCredential credential = oAuthProvider.credential(
      idToken: String.fromCharCodes(appleIdCredential.identityToken),
      accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
    );

    UserCredential authResult;
    try {
      authResult = await _auth.signInWithCredential(credential);
    } catch (e) {
      switch (e.code) {
        case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
          return _handleDifferentCredential(
            credential: credential,
            email: appleIdCredential.email,
          );
          break;
        default:
          throw e;
      }
    }
    User user = authResult.user;

    if (appleIdCredential.fullName.givenName != null ||
        appleIdCredential.fullName.familyName != null) {
      await updateUser(
        firstName: appleIdCredential.fullName.givenName,
        lastName: appleIdCredential.fullName.familyName,
      );
    }

    return user;
  }

  Future<User> _handleDifferentCredential(
      {AuthCredential credential, String email}) async {
    final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
    if (signInMethods.contains(GoogleAuthProvider.PROVIDER_ID)) {
      return signInWithGoogle(previousCredential: credential);
    } else {
      throw PlatformException(
        code: 'ACCOUNT_EXISTS_CASE_NOT_HANDLED',
        message:
            'Please try another sign in method until we get this one working :D',
      );
    }
  }

  Future<void> updateUser({
    String firstName,
    String lastName,
    String photoUrl,
  }) async {
    await updateFirebaseUser(
      name: firstName != null || lastName != null
          ? '$firstName $lastName'.trim()
          : null,
      photoUrl: photoUrl,
    );
  }

  Future<void> updateFirebaseUser({
    String name,
    String photoUrl,
  }) async {
    return _auth.currentUser.updateProfile(
      displayName: name,
      photoURL: photoUrl,
    );
  }

  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    DocumentReference ref = _db.collection('settings').doc(userId);

    return ref.set(settings, SetOptions(merge: true));
  }

  Future<User> createUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await authResult.user.updateProfile(displayName: '$firstName $lastName');

    updateCurrentUser();

    return authResult.user;
  }
}
