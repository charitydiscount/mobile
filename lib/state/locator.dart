import 'package:charity_discount/services/achievements.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/leadeboard.dart';
import 'package:charity_discount/services/local.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/navigation.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:get_it/get_it.dart';
import 'package:charity_discount/services/auth.dart';

GetIt locator = GetIt.instance;

void setupServices() {
  _registerServices();
}

void setupTestLocator() {
  _registerServices();
}

void _registerServices() {
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<AuthService>(
    () => AuthService(),
    dispose: (service) {
      service?.signOut();
    },
  );
  locator.registerLazySingleton<LocalService>(
    () => LocalService(),
    dispose: (service) {
      service?.clear();
    },
  );
  locator.registerLazySingleton<AffiliateService>(() => AffiliateService());
  locator.registerLazySingleton<CharityService>(
    () => FirebaseCharityService(),
    dispose: (service) {
      service?.closeListeners();
    },
  );
  locator.registerLazySingleton<MetaService>(
    () => MetaService(),
    dispose: (service) {
      service?.closeListeners();
    },
  );
  locator.registerLazySingleton<SearchServiceBase>(() => SearchService());
  locator.registerLazySingleton<ShopsService>(
    () => FirebaseShopsService(),
    dispose: (service) {
      service?.closeFavoritesSink();
    },
  );
  locator.registerLazySingleton<AppModel>(
    () => AppModel(),
    dispose: (service) {
      service?.closeListeners();
    },
  );
  locator.registerLazySingleton<AchievementsService>(
    () => AchievementsService(),
  );
  locator.registerLazySingleton<LeaderboardService>(
    () => LeaderboardService(),
  );
}

Future<void> resetServices() async {
  await locator.reset(dispose: true);
  _registerServices();
}
