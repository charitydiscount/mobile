import 'package:flutter/material.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/local.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/models/state.dart';

enum Strategy { EmailAndPass, Google, Facebook }

class UserController {
  Future<void> signIn(BuildContext context, Strategy provider,
      [Map<String, dynamic> credentials]) async {
    switch (provider) {
      case Strategy.EmailAndPass:
        await authService.signInWithEmailAndPass(
            credentials["email"], credentials["password"]);
        break;
      case Strategy.Google:
        await authService.signInWithGoogle();
        break;
      default:
        return; //throw("Unknown authentication strategy");
    }

    StateModel appState = StateWidget.of(context).getState();

    authService.updateUserData(appState.user.userId, appState.user.toJson());

    localService.storeUserLocal(appState.user);
    localService.storeSettingsLocal(appState.settings);
  }

  Future<void> signOut() async {
    await authService.signOut();
    await localService.clear();
  }
}

UserController userController = new UserController();
