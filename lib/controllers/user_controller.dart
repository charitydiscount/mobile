import 'dart:async';
import 'dart:io';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Strategy { EmailAndPass, Google, Facebook, Apple }

class UserController {
  StreamSubscription authListener;
  StreamSubscription _iosSubscription;

  Future<void> signIn(
    Strategy provider, {
    Map<String, dynamic> credentials,
    dynamic authResult,
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
        await locator<AuthService>().signInWithFacebook(authResult);
        break;
      case Strategy.Apple:
        await locator<AuthService>().signInWithApple(authResult);
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

  bool isRecentNewUser() =>
      locator<AuthService>().currentUser != null &&
      DateTime.now()
              .toUtc()
              .difference(locator<AuthService>()
                  .currentUser
                  .metadata
                  .creationTime
                  .toUtc())
              .inMinutes <
          2;

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
