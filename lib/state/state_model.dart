import 'dart:async';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:charity_discount/util/url.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/local.dart';

class AppModel extends Model {
  bool _loading = true;
  bool _introCompleted = false;
  bool _explanationSkipped = false;
  bool _referralSent = false;
  User _user;
  Settings _settings = Settings(
    displayMode: DisplayMode.GRID,
    notificationsForCashback: true,
    notificationsForPromotions: true,
  );
  StreamSubscription _profileListener;
  List<Program> _programs;
  FavoriteShops _favoriteShops = FavoriteShops(programs: {});
  TwoPerformantMeta _affiliateMeta;
  ProgramMeta _programsMeta;
  Wallet wallet;
  double minimumWithdrawalAmount;

  List<Promotion> _promotions;

  AppModel() {
    initFromLocal().then((_) {
      createListeners();
    });
    remoteConfig.getWithdrawalThreshold().then((threshold) => minimumWithdrawalAmount = threshold);
  }

  void createListeners() {
    setLoading(true);
    if (_profileListener != null) {
      return;
    }
    _profileListener = locator<AuthService>().profile.listen(
      (profile) {
        if (profile == null) {
          if (user == null) {
            // No auth in progress
            locator<AuthService>().signInAnonymously();
          }
          return;
        }

        if (locator<AuthService>().isActualUser()) {
          if (_referralSent == false && userController.isRecentNewUser()) {
            _referralSent = true;
            handleReferral();
          }
        }

        setUser(User.fromFirebaseAuth(profile));

        List<Future> futuresForLoading = [];

        if (affiliateMeta == null) {
          futuresForLoading.add(
            locator<MetaService>().getTwoPerformantMeta().then(
              (twoPMeta) {
                setAffiliateMeta(twoPMeta);
                return true;
              },
            ),
          );
        }

        if (programsMeta == null) {
          futuresForLoading.add(updateProgramsMeta());
        }

        if (futuresForLoading.isEmpty) {
          finishLoading();
        } else {
          Future.wait(futuresForLoading).then((loaded) {
            finishLoading();
          });
        }
      },
    );
  }

  Future<void> closeListeners() async {
    clearFavoriteShops();
    if (_profileListener != null) {
      await _profileListener.cancel();
      _profileListener = null;
    }
  }

  static AppModel of(BuildContext context, {bool rebuildOnChange = false}) =>
      ScopedModel.of<AppModel>(context, rebuildOnChange: rebuildOnChange);

  Future<Null> initFromLocal() async {
    User user = await localService.getUserLocal();
    Settings settings = await localService.getSettingsLocal();
    bool isIntroCompleted = await localService.isIntroCompleted();
    List<Program> programs = await localService.getPrograms();
    bool explanationSkipped = await localService.isExplanationSkipped();

    if (user != null && _user == null) {
      setUser(user);
    }
    if (settings != null) {
      setSettings(settings);
      if (settings.notificationsForPromotions == null) {
        final token = await FirebaseMessaging.instance.getToken();
        await locator<MetaService>().setNotificationsForPromotions(
          token,
          true,
        );
      }
    } else {
      await localService.storeSettingsLocal(_settings);
      final token = await FirebaseMessaging.instance.getToken();
      await locator<MetaService>().setNotificationsForPromotions(
        token,
        true,
      );
    }
    if (isIntroCompleted != null) {
      finishIntro();
    }
    if (programs != null) {
      setPrograms(programs, storeLocal: false);
    }
    if (explanationSkipped != null) {
      skipExplanation(explanationSkipped);
    }
  }

  bool get loading => _loading;
  void setLoading(bool loading) {
    if (loading == _loading) {
      return;
    }
    _loading = loading;
    notifyListeners();
  }

  void finishLoading() {
    setLoading(false);
  }

  bool get introCompleted => _introCompleted;
  void finishIntro() {
    _introCompleted = true;
    localService.setIntroCompleted();
    notifyListeners();
  }

  bool get explanationSkipped => _explanationSkipped;
  void skipExplanation(bool skip) {
    _explanationSkipped = skip;
    localService.setSkipExplanation(skip);
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

  void setAffiliateMeta(TwoPerformantMeta twoPerformantMeta) {
    _affiliateMeta = twoPerformantMeta;
    localService.setAffiliateMeta(_affiliateMeta);
    notifyListeners();
  }

  Future<bool> updateProgramsMeta() {
    return locator<MetaService>().getProgramsMeta().then((programsMeta) {
      _programsMeta = programsMeta;
      notifyListeners();
      return true;
    });
  }

  List<Program> get programs => _programs;
  void setPrograms(List<Program> programs, {bool storeLocal = true}) {
    _programs = [];
    _programs.addAll(programs);
    _programs.removeWhere((p) => p.affiliateUrl == null);
    _programs.sort((p1, p2) => p1.getOrder().compareTo(p2.getOrder()));
    notifyListeners();
    if (storeLocal) {
      _programs.forEach((program) {
        final userPercentage = affiliateMeta?.percentage ?? 0.6;
        program.leadCommissionAmount = program.defaultLeadCommissionAmount != null
            ? (program.defaultLeadCommissionAmount * userPercentage).toStringAsFixed(2)
            : null;
        program.saleCommissionRate = program.defaultSaleCommissionRate != null
            ? (program.defaultSaleCommissionRate * userPercentage).toStringAsFixed(2)
            : null;
        program.commissionMinDisplay =
            program.commissionMin != null ? (program.commissionMin * userPercentage).toStringAsFixed(2) : null;
        program.commissionMaxDisplay =
            program.commissionMax != null ? (program.commissionMax * userPercentage).toStringAsFixed(2) : null;
        program.actualAffiliateUrl = interpolateUserCode(
          program.affiliateUrl,
          program.uniqueCode,
          user.userId,
        );
      });

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
        var programs = await locator<ShopsService>().getAllPrograms();
        setPrograms(programs);
      }
    }

    return _programs;
  }

  Future<void> refreshPrograms() async {
    var programs = await locator<ShopsService>().getAllPrograms();
    setPrograms(programs);
  }

  Future<List<SavedAccount>> get savedAccounts => user.savedAccounts != null
      ? Future.value(user.savedAccounts)
      : locator<CharityService>().userAccounts.then((savedAccounts) {
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
    return locator<CharityService>().saveAccount(savedAccount);
  }

  void deleteSavedAccount(SavedAccount savedAccount) {
    user.savedAccounts.removeWhere((account) => account.iban == savedAccount.iban);
    locator<CharityService>().removeAccount(savedAccount);
  }

  Future<void> handleReferral() async {
    String referralCode = await localService.getReferralCode();

    if (referralCode == null) {
      // Ensure that there is no pending dynamic link
      var data = await FirebaseDynamicLinks.instance.getInitialLink();
      if (data?.link != null && data.link.pathSegments.first == DeepLinkPath.referral) {
        referralCode = data.link.pathSegments.last;
      }
    }

    if (referralCode != null) {
      locator<CharityService>().createReferralRequest(referralCode);
      await localService.storeReferralCode(null);
    }
  }

  List<Promotion> get promotions => _promotions;
  void setPromotions(List<Promotion> promotions) {
    _promotions = promotions;
    notifyListeners();
  }

  Future<List<Promotion>> loadPromotions() async {
    if (_promotions == null) {
      final promotions = await locator<AffiliateService>().getAllPromotions();

      // Find the program unique codes required to create the affiliate URL
      final programIds = promotions.map((e) => e.program.id).toSet();
      final programs = await programsFuture;
      Map<int, Program> relevantPrograms = Map.fromIterable(
        programIds,
        key: (programId) => programId,
        value: (programId) => programs.firstWhere(
          (element) => element.id == programId.toString(),
          orElse: () => null,
        ),
      );
      promotions.removeWhere((p) => relevantPrograms[p.program.id] == null);

      // Build the affiliate URL for the promotions
      promotions.forEach((p) {
        p.actualAffiliateUrl = interpolateUserCode(
          p.affiliateUrl,
          relevantPrograms[p.program.id].uniqueCode,
          user.userId,
        );
      });
      promotions.sort(
          (p1, p2) => relevantPrograms[p1.program.id].getOrder().compareTo(relevantPrograms[p2.program.id].getOrder()));
      setPromotions(promotions);
    }

    return promotions;
  }

  Future<List<Product>> getSimilarProducts(Product product) async {
    final products = await locator<SearchServiceBase>().getSimilarProducts(product: product);
    return _prepareProducts(products);
  }

  Future<ProductSearchResult> searchProducts(
    String query, {
    String programId,
    int from = 0,
    SortStrategy sort,
    double minPrice,
    double maxPrice,
  }) async {
    final searchResult = await locator<SearchServiceBase>().searchProducts(
      query,
      programId: programId,
      from: from,
      maxPrice: maxPrice,
      minPrice: minPrice,
      sort: sort,
    );
    return ProductSearchResult(_prepareProducts(searchResult.products), searchResult.totalFound);
  }

  Future<ProductSearchResult> getProductsForProgram({
    Program program,
    int size = 20,
    int from = 0,
  }) async {
    final searchResult = await locator<SearchServiceBase>().getProductsForProgram(
      program: program,
      size: size,
      from: from,
    );
    return ProductSearchResult(_prepareProducts(searchResult.products), searchResult.totalFound);
  }

  Future<List<Product>> getFeaturedProducts() async {
    final products = await locator<SearchServiceBase>().getFeaturedProducts(userId: user.userId);
    return _prepareProducts(products);
  }

  List<Product> _prepareProducts(Iterable<Product> products) => products
      .map((product) {
        final program = programs?.firstWhere(
          (program) => program.id == product.programId,
          orElse: () => null,
        );

        if (program == null) return null;

        return product.copyWith(
          program: program,
          actualAffiliateUrl: interpolateUserCode(product.affiliateUrl, program.uniqueCode, user.userId),
        );
      })
      .where((product) => product != null)
      .toList();
}
