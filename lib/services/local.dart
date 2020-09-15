import 'dart:convert';

import 'package:charity_discount/models/meta.dart';
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

    return User.fromJson(json.decode(prefs.getString('user')));
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

  Future<void> setSkipExplanation(bool skip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skipExplanation', skip);
  }

  Future<bool> isExplanationSkipped() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('skipExplanation') == null) {
      return false;
    }

    return prefs.getBool('skipExplanation');
  }

  Future<void> setPrograms(List<Program> programs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('programs', programsToJson(programs));
    await prefs.setString('programs-date', DateTime.now().toString());
  }

  Future<List<Program>> getPrograms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String programsDateString = prefs.getString('programs-date');
    bool isRecentEnough = true;
    if (programsDateString == null) {
      isRecentEnough = false;
    } else if (DateTime.now()
            .difference(DateTime.tryParse(programsDateString) ??
                DateTime.fromMillisecondsSinceEpoch(0))
            .inHours >
        6) {
      // Cache the programs for at most 6 hours
      isRecentEnough = false;
    }

    if (!isRecentEnough) {
      await prefs.remove('programs');
      return null;
    }

    var jsonPrograms = prefs.getStringList('programs');
    if (jsonPrograms == null) {
      return null;
    }

    return fromJsonStringList(jsonPrograms);
  }

  Future<void> setAffiliateMeta(TwoPerformantMeta meta) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('affiliateMeta', jsonEncode(meta.toJson()));
  }

  Future<TwoPerformantMeta> getAffiliateMeta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var affiliateMetaPrefs = prefs.getString('affiliateMeta');
    if (affiliateMetaPrefs == null) {
      return null;
    }

    return TwoPerformantMeta.fromJson(jsonDecode(affiliateMetaPrefs));
  }

  Future<void> storeReferralCode(String referralCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (referralCode == null) {
      await prefs.remove('referralCode');
    } else {
      await prefs.setString('referralCode', referralCode);
    }
  }

  Future<String> getReferralCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('referralCode');
  }
}

final LocalService localService = LocalService();
