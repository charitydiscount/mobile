import 'package:charity_discount/models/program.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';

class LocalService {
  Future<String> storeUserLocal(User user) async {
    if (user == null) {
      return '';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  Future<void> storeSettingsLocal(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeSettings = settingsToJson(settings);
    await prefs.setString('settings', storeSettings);
  }

  Future<User> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('user') == null) {
      return null;
    }

    return userFromJson(prefs.getString('user'));
  }

  Future<Settings> getSettingsLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('settings') == null) {
      return null;
    }

    return settingsFromJson(prefs.getString('settings'));
  }

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('introCompleted', true);
  }

  Future<void> setIntroCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('introCompleted', true);
  }

  Future<bool> isIntroCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('introCompleted') == null) {
      return null;
    }

    return prefs.getBool('introCompleted');
  }

  Future<void> setPrograms(List<Program> programs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('programs', programsToJson(programs));
  }

  Future<List<Program>> getPrograms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonPrograms = prefs.getStringList('programs');
    if (jsonPrograms == null) {
      return null;
    }

    return fromJsonStringList(jsonPrograms);
  }
}

final LocalService localService = LocalService();
