import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  Observable<Map<String, dynamic>> settings;
  PublishSubject loading = PublishSubject();

  AuthService() {
    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection('users')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });

    settings = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection('settings')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  Future<FirebaseUser> signInWithEmailAndPass(email, password) async {
    loading.add(true);

    FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    loading.add(false);

    return user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    _auth.signOut();
  }

  Future<FirebaseUser> signInWithGoogle() async {
    loading.add(true);

    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    FirebaseUser user = await _auth.signInWithCredential(credential);

    loading.add(false);

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

  Future<FirebaseUser> createUser(String email, String password) async {
    FirebaseUser newUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return newUser;
  }
}

final AuthService authService = new AuthService();
