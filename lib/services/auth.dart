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
  final Firestore _db = Firestore.instance;

  FirebaseUser currentUser;
  BehaviorSubject<FirebaseUser> profile = BehaviorSubject();

  AuthService() {
    _auth.onAuthStateChanged.listen((u) => _setUser(u));
  }

  void _setUser(FirebaseUser u) {
    currentUser = u;
    profile.add(u);
  }

  Future<void> updateCurrentUser() =>
      _auth.currentUser().then((user) => _setUser(user));

  Future<FirebaseUser> signInWithEmailAndPass(email, password) async {
    AuthResult authResult = await _auth.signInWithEmailAndPassword(
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

  Future<FirebaseUser> signInWithGoogle(
      {AuthCredential previousCredential}) async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the google sign in flow
      throw Exception('User canceled google sign in');
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;

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
          photoUrl: user.photoUrl ?? userInfoJson['picture'],
        );
      }
    }

    if (previousCredential != null) {
      user.linkWithCredential(previousCredential).catchError(() {});
    }

    return user;
  }

  Future<FirebaseUser> signInWithFacebook(
    FacebookLoginResult result,
  ) async {
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=$token');

    if (graphResponse.statusCode != 200) {
      throw PlatformException(code: 'GRAPH_CALL_FAILED');
    }

    Map<String, dynamic> userInfoJson = json.decode(graphResponse.body);

    final credential = FacebookAuthProvider.getCredential(accessToken: token);
    AuthResult authResult;
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
    FirebaseUser user = authResult.user;
    if (userInfoJson['first_name'] != null ||
        userInfoJson['last_name'] != null ||
        userInfoJson['picture'] != null) {
      updateUser(
        firstName: userInfoJson['first_name'],
        lastName: userInfoJson['last_name'],
        photoUrl: user.photoUrl ?? userInfoJson['picture']['data']['url'],
      );
    }

    return user;
  }

  Future<FirebaseUser> signInWithApple(
      AuthorizationResult authorizationResult) async {
    final AppleIdCredential appleIdCredential = authorizationResult.credential;

    OAuthProvider oAuthProvider = OAuthProvider(providerId: 'apple.com');
    final AuthCredential credential = oAuthProvider.getCredential(
      idToken: String.fromCharCodes(appleIdCredential.identityToken),
      accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
    );

    AuthResult authResult;
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
    FirebaseUser user = authResult.user;

    if (appleIdCredential.fullName.givenName != null ||
        appleIdCredential.fullName.familyName != null) {
      await updateUser(
        firstName: appleIdCredential.fullName.givenName,
        lastName: appleIdCredential.fullName.familyName,
      );
    }

    return user;
  }

  Future<FirebaseUser> _handleDifferentCredential(
      {AuthCredential credential, String email}) async {
    final signInMethods = await _auth.fetchSignInMethodsForEmail(email: email);
    if (signInMethods.contains(GoogleAuthProvider.providerId)) {
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
      name:
          firstName != null || lastName != null ? '$firstName $lastName' : null,
      photoUrl: photoUrl,
    );
  }

  Future<void> updateFirebaseUser({
    String name,
    String photoUrl,
  }) async {
    return _auth.currentUser().then((user) async {
      UserUpdateInfo updateUser = UserUpdateInfo();
      if (name != null && name.isNotEmpty) {
        updateUser.displayName = name.trim();
      }
      if (photoUrl != null) {
        updateUser.photoUrl = photoUrl;
      }
      return user.updateProfile(updateUser);
    });
  }

  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    DocumentReference ref = _db.collection('settings').document(userId);

    return ref.setData(settings, merge: true);
  }

  Future<FirebaseUser> createUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    AuthResult authResult = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    UserUpdateInfo userInfo = UserUpdateInfo();
    userInfo.displayName = '$firstName $lastName';
    await authResult.user.updateProfile(userInfo);

    await updateCurrentUser();

    return authResult.user;
  }
}

final AuthService authService = AuthService();
