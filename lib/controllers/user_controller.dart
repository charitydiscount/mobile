import 'dart:async';

import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/factory.dart';
import 'package:charity_discount/services/local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

enum Strategy { EmailAndPass, Google, Facebook }

class UserController {
  StreamSubscription authListener;

  Future<void> signIn(
    Strategy provider, {
    Map<String, dynamic> credentials,
    FacebookLoginResult facebookResult,
  }) async {
    switch (provider) {
      case Strategy.EmailAndPass:
        await authService.signInWithEmailAndPass(
            credentials['email'], credentials['password']);
        break;
      case Strategy.Google:
        await authService.signInWithGoogle();
        break;
      case Strategy.Facebook:
        await authService.signInWithFacebook(facebookResult);
        break;
      default:
        return;
    }
  }

  Future<void> signOut() async {
    if (authListener != null) {
      await authListener.cancel();
    }
    await getFirebaseShopsService(authService.currentUser.uid)
        .closeFavoritesSink();
    await authService.signOut();
    await localService.clear();
  }

  Future<void> resetPassword(email) async {
    await authService.resetPassword(email);
  }

  Future<FirebaseUser> signUp(email, password, firstName, lastName) async {
    return await authService.createUser(email, password, firstName, lastName);
  }
}

UserController userController = UserController();
