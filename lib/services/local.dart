import 'package:shared_preferences/shared_preferences.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';

class LocalService {
  Future<String> storeUserLocal(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  Future<String> storeSettingsLocal(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeSettings = settingsToJson(settings);
    await prefs.setString('settings', storeSettings);
    return settings.userId;
  }

  Future<User> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      User user = userFromJson(prefs.getString('user'));
      return user;
    } else {
      return null;
    }
  }

  Future<Settings> getSettingsLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('settings') != null) {
      Settings settings = settingsFromJson(prefs.getString('settings'));
      return settings;
    } else {
      return null;
    }
  }

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

final LocalService localService = new LocalService();
