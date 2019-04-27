import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/local.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';

enum Strategy { EmailAndPass, Google, Facebook }

class UserController {
  Future<void> signIn(Strategy provider, String lang,
      [Map<String, dynamic> credentials]) async {
    authService.profile.take(1).listen(
        (profile) => localService.storeUserLocal(User.fromJson(profile)));
    authService.settings.take(1).listen((settings) =>
        localService.storeSettingsLocal(Settings.fromJson(settings)));

    switch (provider) {
      case Strategy.EmailAndPass:
        await authService.signInWithEmailAndPass(
            credentials["email"], credentials["password"]);
        break;
      case Strategy.Google:
        await authService.signInWithGoogle(lang);
        break;
      default:
        return; //throw("Unknown authentication strategy");
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    await localService.clear();
  }

  Future<void> resetPassword(email) async {
    await authService.resetPassword(email);
  }

  Future<void> signUp(email, password, firstName, lastName, lang) async {
    await authService.createUser(email, password, firstName, lastName, lang);
  }
}

UserController userController = new UserController();
