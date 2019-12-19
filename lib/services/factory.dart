import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/shops.dart';

FirebaseShopsService _shopsService;
FirebaseShopsService getFirebaseShopsService(String userId) {
  if (_shopsService == null) {
    _shopsService = FirebaseShopsService(userId);
  }

  return _shopsService;
}

FirebaseCharityService _charityService;
FirebaseCharityService getFirebaseCharityService() {
  if (_charityService == null) {
    _charityService = FirebaseCharityService();
  }

  return _charityService;
}

void clearInstances() {
  _shopsService = null;
  _charityService = null;
}
