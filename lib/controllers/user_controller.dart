import 'dart:async';
import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:charity_discount/state/locator.dart';
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
        await locator<AuthService>().signInWithEmailAndPass(
            credentials['email'], credentials['password']);
        break;
      case Strategy.Google:
        await locator<AuthService>().signInWithGoogle();
        break;
      case Strategy.Facebook:
        await locator<AuthService>().signInWithFacebook(facebookResult);
        break;
      case Strategy.Apple:
        await locator<AuthService>().signInWithApple(appleResult);
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
    await locator<MetaService>().removeFcmToken(token);
    await locator<MetaService>().setNotificationsForPromotions(token, false);
    _iosSubscription?.cancel();
    await resetServices();
  }

  Future<void> resetPassword(email) async {
    await locator<AuthService>().resetPassword(email);
  }

  Future<User> signUp(email, password, firstName, lastName) async {
    return await locator<AuthService>()
        .createUser(email, password, firstName, lastName);
  }

  void _registerFcmToken() async {
    final token = await fcm.getToken();
    await locator<MetaService>().addFcmToken(token);
    await locator<MetaService>().setNotificationsForPromotions(token, true);
  }
}

UserController userController = UserController();
