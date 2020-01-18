import 'dart:async';
import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/factory.dart';
import 'package:charity_discount/services/local.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

enum Strategy { EmailAndPass, Google, Facebook, Apple }

class UserController {
  StreamSubscription authListener;
  StreamSubscription _iosSubscription;

  Future<void> signIn(
    Strategy provider, {
    Map<String, dynamic> credentials,
    FacebookLoginResult facebookResult,
    AuthorizationResult appleResult,
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
      case Strategy.Apple:
        await authService.signInWithApple(appleResult);
        break;
      default:
        return;
    }
    if (Platform.isIOS) {
      _iosSubscription = fcm.onIosSettingsRegistered.listen((data) {
        _registerFcmToken();
      });
      fcm.requestNotificationPermissions();
    } else {
      _registerFcmToken();
    }
  }

  Future<void> signOut() async {
    if (authListener != null) {
      await authListener.cancel();
    }
    var token = await fcm.getToken();
    await metaService.removeFcmToken(authService.currentUser.uid, token);
    _iosSubscription?.cancel();
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

  void _registerFcmToken() async {
    final token = await fcm.getToken();
    metaService.addFcmToken(authService.currentUser.uid, token);
  }
}

UserController userController = UserController();
