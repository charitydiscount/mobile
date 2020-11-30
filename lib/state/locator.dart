import 'package:charity_discount/services/achievements.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/services/charity.dart';
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
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<LocalService>(() => LocalService());
  locator.registerLazySingleton<AffiliateService>(() => AffiliateService());
  locator.registerLazySingleton<CharityService>(() => FirebaseCharityService());
  locator.registerLazySingleton<MetaService>(() => MetaService());
  locator.registerLazySingleton<SearchServiceBase>(() => SearchService());
  locator.registerLazySingleton<ShopsService>(() => FirebaseShopsService());
  locator.registerLazySingleton<AppModel>(() => AppModel());
  locator.registerLazySingleton<AchievementsService>(
    () => AchievementsService(),
  );
}

Future<void> resetServices() async {
  await locator<ShopsService>().closeFavoritesSink();
  await locator<LocalService>().clear();
  await locator<AuthService>().signOut();
  await locator<CharityService>().closeListeners();
  await locator<MetaService>().closeListeners();
  locator<AppModel>().closeListeners();
  locator.reset();
  _registerServices();
}
