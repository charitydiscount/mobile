import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/userinfo.profile', 'email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Observable<FirebaseUser> _user;
  FirebaseUser currentUser;
  BehaviorSubject<Map<String, dynamic>> profile = BehaviorSubject();
  BehaviorSubject<Map<String, dynamic>> settings = BehaviorSubject();

  StreamSubscription _usersListener;
  StreamSubscription _settingsListener;

  AuthService() {
    _user = Observable(_auth.onAuthStateChanged);

    _user.listen((FirebaseUser u) {
      currentUser = u;

      if (u != null) {
        if (_usersListener != null) {
          _usersListener.cancel();
        }
        _usersListener = _db
            .collection('users')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.exists ? snap.data : {})
            .listen((data) => profile.add(data));
      } else {
        profile.add(null);
      }
    });

    _user.listen((FirebaseUser u) {
      if (u != null) {
        if (_settingsListener != null) {
          _settingsListener.cancel();
        }
        _settingsListener = _db
            .collection('settings')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data)
            .listen((data) => settings.add(data));
      } else {
        settings.add(null);
      }
    });
  }

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
    if (_usersListener != null) {
      await _usersListener.cancel();
    }
    if (_settingsListener != null) {
      await _settingsListener.cancel();
    }
    await _auth.signOut();
  }

  Future<FirebaseUser> signInWithGoogle(lang) async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;

    final googleApisUrl =
        'https://www.googleapis.com/oauth2/v3/userinfo?alt=json&access_token=${googleAuth.accessToken}';
    final response = await http.get(googleApisUrl);

    if (response.statusCode == 200) {
      Map<String, dynamic> userInfoJson = json.decode(response.body);
      await updateUserData(user.uid, {
        'userId': user.uid,
        'email': googleUser.email,
        'firstName': userInfoJson['given_name'],
        'lastName': userInfoJson['family_name'],
        'photoUrl': user.photoUrl,
      });
    }

    await updateUserSettings(user.uid, {'lang': lang});

    return user;
  }

  Future<void> updateUserData(
      String userId, Map<String, dynamic> userData) async {
    DocumentReference ref = _db.collection('users').document(userId);

    return ref.setData(userData, merge: true);
  }

  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    DocumentReference ref = _db.collection('settings').document(userId);

    return ref.setData(settings, merge: true);
  }

  Future<FirebaseUser> createUser(String email, String password,
      String firstName, String lastName, String lang) async {
    AuthResult authResult = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await updateUserData(authResult.user.uid, {
      'userId': authResult.user.uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName
    });

    await updateUserSettings(authResult.user.uid, {'lang': lang});

    return authResult.user;
  }
}

final AuthService authService = AuthService();
