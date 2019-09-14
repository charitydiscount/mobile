import 'dart:async';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/wallet.dart';
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
  Settings _settings;
  StreamSubscription _profileListener;
  StreamSubscription _settingsListener;
  List<Program> _programs;
  FavoriteShops _favoriteShops = FavoriteShops(programs: []);
  TwoPerformantMeta _affiliateMeta;
  ProgramMeta _programsMeta;
  Wallet wallet;

  AppModel() {
    createListeners();
    initFromLocal();
  }

  void createListeners() {
    _profileListener = authService.profile.listen(
      (profile) {
        if (profile == null) {
          return;
        }
        User currentUser = User.fromJson(profile);
        this.setUser(currentUser);
        _settingsListener = authService.settings.listen(
          (settings) {
            if (settings != null) {
              this.setSettings(
                Settings.fromJson(settings),
              );
            }
          },
        );
        metaService.getTwoPerformantMeta().then((twoPMeta) {
          _affiliateMeta = twoPMeta;
        });
        metaService.getProgramsMeta().then((programsMeta) {
          _programsMeta = programsMeta;
        });
      },
    );
  }

  Future<void> closeListeners() async {
    await _profileListener.cancel();
    await _settingsListener.cancel();
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
  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }

  TwoPerformantMeta get affiliateMeta => _affiliateMeta;
  ProgramMeta get programsMeta => _programsMeta;

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
        _programs = await getShopsService(_user.userId).getAllPrograms();
        localService.setPrograms(_programs);
      }
    }

    return _programs;
  }

  Future<void> refreshPrograms() async {
    _programs = await getShopsService(_user.userId).getAllPrograms();
    await localService.setPrograms(_programs);
  }

  void addSavedAccount(SavedAccount savedAccount) {
    wallet.savedAccounts.add(savedAccount);
  }

  void deleteSavedAccount(SavedAccount savedAccount) {
    wallet.savedAccounts
        .removeWhere((account) => account.iban == savedAccount.iban);
  }
}
