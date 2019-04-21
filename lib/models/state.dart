import 'package:firebase_auth/firebase_auth.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';

class StateModel {
  bool isLoading;
  FirebaseUser firebaseUserAuth;
  User user;
  Settings settings;

  StateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
  });
}
