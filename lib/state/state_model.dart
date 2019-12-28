import 'dart:async';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:rxdart/rxdart.dart';
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
    displayMode: DisplayMode.GRID,
    lang: 'en',
    notifications: true,
  );
  StreamSubscription _profileListener;
  List<Program> _programs;
  FavoriteShops _favoriteShops = FavoriteShops(programs: {});
  TwoPerformantMeta _affiliateMeta;
  ProgramMeta _programsMeta;
  Wallet wallet;
  ShopsService _shopsService;
  CharityService _charityService;
  bool _isNewDevice = true;
  double minimumWithdrawalAmount;
  BehaviorSubject<bool> loading;

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: 'Main Navigator');

  AppModel() {
    createListeners();
    initFromLocal();
    remoteConfig
        .getWithdrawalThreshold()
        .then((threshold) => minimumWithdrawalAmount = threshold);
  }

  void setServices(ShopsService shopService, CharityService charityService) {
    _shopsService = shopService;
    _charityService = charityService;
  }

  void createListeners() {
    loading = BehaviorSubject();
    _profileListener = authService.profile.listen(
      (profile) {
        if (profile == null) {
          return;
        }
        setUser(User.fromJson(profile));
        List<Future> futuresForLoading = [
          metaService.getTwoPerformantMeta().then((twoPMeta) {
            _affiliateMeta = twoPMeta;
            return true;
          }),
          updateProgramsMeta(),
        ];
        Future.wait(futuresForLoading).then((loaded) => loading.add(false));
      },
    );
  }

  Future<void> closeListeners() async {
    clearFavoriteShops();
    await _profileListener.cancel();
    loading.close();
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
    bool isKnownDevice = await localService.isDeviceKnown();

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
    if (isKnownDevice != null) {
      setKnownDevice();
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
    localService.storeUserLocal(user);
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

  Future<bool> updateProgramsMeta() {
    return metaService.getProgramsMeta().then((programsMeta) {
      _programsMeta = programsMeta;
      notifyListeners();
      return true;
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
    _favoriteShops = FavoriteShops(programs: {});
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

  bool get isNewDevice => _isNewDevice;
  void setKnownDevice() {
    _isNewDevice = false;
    localService.setKnownDevice();
    notifyListeners();
  }
}
