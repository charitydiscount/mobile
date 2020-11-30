abstract class DeepLinkPath {
  static const String referral = 'referral';
  static const String shop = 'shop';
  static const String product = 'product';
  static const String charityCase = 'case';
}

abstract class Routes {
  static const String shopDetails = 'ShopDetails';
  static const String signIn = '/signin';
}

abstract class NotificationTypes {
  static const String commission = 'COMMISSION';
  static const String shop = 'SHOP';
}

abstract class Source {
  static const String twoP = '2p';
  static const String altex = 'altex';
}

abstract class FirestoreCollection {
  static const String achievements = 'achievements';
  static const String userAchievements = 'user-achievements';
}
