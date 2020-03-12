import 'dart:async';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:charity_discount/util/url.dart';
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
        setUser(User.fromFirebaseAuth(profile));
        List<Future> futuresForLoading = [
          metaService.getTwoPerformantMeta().then((twoPMeta) {
            _affiliateMeta = twoPMeta;
            localService.setAffiliateMeta(_affiliateMeta);
            return true;
          }),
          updateProgramsMeta(),
        ];
        Future.wait(futuresForLoading).then((loaded) {
          loading.add(false);
        });
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

    if (user != null && _user == null) {
      setUser(user);
    }
    if (settings != null) {
      setSettings(settings);
    }
    if (isIntroCompleted != null) {
      finishIntro();
    }
    if (programs != null) {
      setPrograms(programs, storeLocal: false);
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
  void setPrograms(List<Program> programs, {bool storeLocal = true}) {
    _programs = [];
    _programs.addAll(programs);
    _programs.sort((p1, p2) => p1.getOrder().compareTo(p2.getOrder()));
    if (storeLocal) {
      _programs.forEach((program) {
        final userPercentage = affiliateMeta.percentage;
        program.leadCommissionAmount =
            program.defaultLeadCommissionAmount != null
                ? (program.defaultLeadCommissionAmount * userPercentage)
                    .toStringAsFixed(2)
                : null;
        program.saleCommissionRate = program.defaultSaleCommissionRate != null
            ? (program.defaultSaleCommissionRate * userPercentage)
                .toStringAsFixed(2)
            : null;
        program.commissionMinDisplay = program.commissionMin != null
            ? (program.commissionMin * userPercentage).toStringAsFixed(2)
            : null;
        program.commissionMaxDisplay = program.commissionMax != null
            ? (program.commissionMax * userPercentage).toStringAsFixed(2)
            : null;
        if (program.affiliateUrl != null && program.affiliateUrl.isNotEmpty) {
          program.actualAffiliateUrl = interpolateUserCode(
            program.affiliateUrl,
            program.uniqueCode,
            user.userId,
          );
        } else {
          // fallback to the previous strategy (probably old cache)
          program.actualAffiliateUrl = convertAffiliateUrl(
            program.mainUrl,
            affiliateMeta.uniqueCode,
            program.uniqueCode,
            user.userId,
          );
        }
      });
    }
    if (storeLocal) {
      localService.setPrograms(_programs);
    }
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
        setPrograms(localPrograms, storeLocal: false);
      } else {
        var programs = await _shopsService.getAllPrograms();
        setPrograms(programs);
      }
    }

    return _programs;
  }

  Future<void> refreshPrograms() async {
    var programs = await _shopsService.getAllPrograms();
    setPrograms(programs);
  }

  Future<List<SavedAccount>> get savedAccounts => user.savedAccounts != null
      ? Future.value(user.savedAccounts)
      : _charityService.userAccounts.then((savedAccounts) {
          user.savedAccounts = savedAccounts;
          return savedAccounts;
        });

  Future<void> addSavedAccount(SavedAccount savedAccount) {
    if (user.savedAccounts == null) {
      user.savedAccounts = [savedAccount];
    } else {
      int accountIndex = user.savedAccounts.indexWhere(
        (account) => account.iban.compareTo(savedAccount.iban) == 0,
      );
      if (accountIndex != -1) {
        user.savedAccounts[accountIndex] = savedAccount;
      } else {
        user.savedAccounts.add(savedAccount);
      }
    }
    return _charityService.saveAccount(savedAccount);
  }

  void deleteSavedAccount(SavedAccount savedAccount) {
    user.savedAccounts
        .removeWhere((account) => account.iban == savedAccount.iban);
    _charityService.removeAccount(savedAccount);
  }
}
