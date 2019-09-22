import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/factory.dart';
import 'package:charity_discount/services/local.dart';
import 'package:charity_discount/models/user.dart';

enum Strategy { EmailAndPass, Google, Facebook }

class UserController {
  Future<void> signIn(Strategy provider,
      [Map<String, dynamic> credentials]) async {
    authService.profile.listen((profile) {
      if (profile != null) {
        User currentUser = User.fromJson(profile);
        localService.storeUserLocal(currentUser);
      }
    });

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
  }

  Future<void> signOut() async {
    await getFirebaseShopsService(authService.currentUser.uid).closeFavoritesSink();
    await authService.signOut();
    await localService.clear();
  }

  Future<void> resetPassword(email) async {
    await authService.resetPassword(email);
  }

  Future<void> signUp(email, password, firstName, lastName) async {
    await authService.createUser(email, password, firstName, lastName);
  }
}

UserController userController = UserController();
