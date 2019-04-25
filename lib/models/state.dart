import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';

class StateModel {
  bool isLoading;
  User user;
  Settings settings;

  StateModel({
    this.isLoading = false,
    this.user,
    this.settings,
  });
}
