import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/local.dart';

class AppModel extends Model {
  bool _isLoading = false;
  bool _introCompleted = false;
  User _user;
  Settings _settings = Settings(lang: 'ro');

  AppModel() {
    authService.profile
        .listen((profile) => this.setUser(User.fromJson(profile)));
    authService.settings
        .listen((settings) => this.setSettings(Settings.fromJson(settings)));

    initFromLocal();
  }

  static AppModel of(
    BuildContext context, {
    bool rebuildOnChange = false,
  }) =>
      ScopedModel.of<AppModel>(context, rebuildOnChange: rebuildOnChange);

  Future<Null> initFromLocal() async {
    User user = await localService.getUserLocal();
    Settings settings = await localService.getSettingsLocal();
    bool isIntroCompleted = await localService.isIntroCompleted();

    if (user != null) {
      setUser(user);
    }
    if (settings != null) {
      setSettings(settings);
    }
    if (isIntroCompleted != null) {
      finishIntro();
    }
  }

  bool get isLoading => _isLoading;
  void toggleLoading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get introCompleted => _introCompleted;
  void finishIntro() {
    _introCompleted = true;
    localService.setIntroCompleted();
    notifyListeners();
  }

  User get user => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Settings get settings => _settings;
  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }
}
