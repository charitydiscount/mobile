import 'dart:async';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/local.dart';

class AppModel extends Model {
  bool _introCompleted = false;
  User _user;
  Settings _settings = Settings(
    displayMode: DisplayMode.LIST,
    lang: 'en',
    notifications: false,
  );
  StreamSubscription _profileListener;
  List<Program> _programs;
  FavoriteShops _favoriteShops = FavoriteShops(programs: []);
  TwoPerformantMeta _affiliateMeta;
  ProgramMeta _programsMeta;
  Wallet wallet;
  ShopsService _shopsService;
  CharityService _charityService;

  AppModel() {
    createListeners();
    initFromLocal();
  }

  void setServices(ShopsService shopService, CharityService charityService) {
    _shopsService = shopService;
    _charityService = charityService;
  }

  void createListeners() {
    _profileListener = authService.profile.listen(
      (profile) {
        if (profile == null) {
          return;
        }
        User currentUser = User.fromJson(profile);
        this.setUser(currentUser);
        metaService.getTwoPerformantMeta().then((twoPMeta) {
          _affiliateMeta = twoPMeta;
        });
        updateProgramsMeta();
      },
    );
  }

  Future<void> closeListeners() async {
    await _profileListener.cancel();
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
    List<Program> programs = await localService.getPrograms();

    if (user != null) {
      setUser(user);
    }
    if (settings != null) {
      setSettings(settings);
    }
    if (isIntroCompleted != null) {
      finishIntro();
    }
    if (programs != null) {
      _programs = programs;
    }
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
  void setSettings(Settings settings, {bool storeLocal = false}) {
    _settings = settings;
    if (storeLocal) {
      localService.storeSettingsLocal(_settings);
    }
    notifyListeners();
  }

  TwoPerformantMeta get affiliateMeta => _affiliateMeta;
  ProgramMeta get programsMeta => _programsMeta;

  void updateProgramsMeta() {
    metaService.getProgramsMeta().then((programsMeta) {
      _programsMeta = programsMeta;
      notifyListeners();
    });
  }

  List<Program> get programs => _programs;
  void addPrograms(List<Program> programs) {
    _programs.addAll(programs);
  }

  FavoriteShops get favoriteShops => _favoriteShops;
  void setFavoriteShops(FavoriteShops favoriteShops) {
    _favoriteShops = favoriteShops;
  }

  void clearFavoriteShops() {
    _favoriteShops = FavoriteShops(programs: []);
  }

  Future<List<Program>> get programsFuture async {
    if (_programs == null) {
      var localPrograms = await localService.getPrograms();
      if (localPrograms != null) {
        _programs = localPrograms;
      } else {
        _programs = await _shopsService.getAllPrograms();
        localService.setPrograms(_programs);
      }
    }

    return _programs;
  }

  Future<void> refreshPrograms() async {
    _programs = await _shopsService.getAllPrograms();
    await localService.setPrograms(_programs);
  }

  void addSavedAccount(SavedAccount savedAccount) {
    user.savedAccounts.add(savedAccount);
    _charityService.saveAccount(user.userId, savedAccount);
  }

  void deleteSavedAccount(SavedAccount savedAccount) {
    user.savedAccounts
        .removeWhere((account) => account.iban == savedAccount.iban);
    _charityService.removeAccount(user.userId, savedAccount);
  }
}
