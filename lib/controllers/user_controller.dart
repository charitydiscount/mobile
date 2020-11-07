import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum Strategy { EmailAndPass, Google, Facebook, Apple }

class UserController {
  StreamSubscription authListener;

  Future<void> signIn(
    Strategy provider, {
    Map<String, dynamic> credentials,
    dynamic authResult,
  }) async {
    switch (provider) {
      case Strategy.EmailAndPass:
        await locator<AuthService>().signInWithEmailAndPass(credentials['email'], credentials['password']);
        break;
      case Strategy.Google:
        await locator<AuthService>().signInWithGoogle();
        break;
      case Strategy.Facebook:
        await locator<AuthService>().signInWithFacebook(authResult);
        break;
      case Strategy.Apple:
        await locator<AuthService>().signInWithApple(authResult);
        break;
      default:
        return;
    }

    final notifcationSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (notifcationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerFcmToken();
    }
  }

  Future<void> signOut() async {
    if (authListener != null) {
      await authListener.cancel();
    }
    var token = await FirebaseMessaging.instance.getToken();
    await locator<MetaService>().removeFcmToken(token);
    await locator<MetaService>().setNotificationsForPromotions(token, false);
    await resetServices();
  }

  Future<void> resetPassword(email) async {
    await locator<AuthService>().resetPassword(email);
  }

  Future<User> signUp(email, password, firstName, lastName) async {
    return await locator<AuthService>().createUser(email, password, firstName, lastName);
  }

  Future<void> _registerFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    await locator<MetaService>().addFcmToken(token);
    await locator<MetaService>().setNotificationsForPromotions(token, true);
  }

  bool isRecentNewUser() =>
      locator<AuthService>().currentUser != null &&
      DateTime.now().toUtc().difference(locator<AuthService>().currentUser.metadata.creationTime.toUtc()).inMinutes < 2;

  Future<bool> deleteAccount() async {
    try {
      await locator<AuthService>().deleteAccount();
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            return true;
            break;
          default:
        }
      }
    }

    return false;
  }
}

UserController userController = UserController();
