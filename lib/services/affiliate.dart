import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/util/url.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AffiliateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _baseUrl;

  Future<List<Promotion>> getPromotions({
    String affiliateUniqueCode,
    String programId,
    String programUniqueCode,
  }) =>
      _db
          .collection('promotions')
          .doc(programId)
          .get()
          .then((snap) => snap.exists
              ? _promotionsFromSnapData(
                  snap.data(),
                  affiliateUniqueCode,
                  programUniqueCode,
                  _auth.currentUser,
                )
              : []);

  List<Promotion> _promotionsFromSnapData(
    Map<String, dynamic> snapData,
    String affiliateUniqueCode,
    String programUniqueCode,
    User user,
  ) =>
      snapData.entries
          .map((snapEntry) {
            final promotion =
                Promotion.fromJson(Map<String, dynamic>.from(snapEntry.value));
            if (promotion.affiliateUrl != null) {
              promotion.actualAffiliateUrl = interpolateUserCode(
                promotion.affiliateUrl,
                programUniqueCode,
                user.uid,
              );
            } else {
              // Fallback to previous strategy for old promotions
              promotion.actualAffiliateUrl = convertAffiliateUrl(
                promotion.landingPageLink,
                affiliateUniqueCode,
                programUniqueCode,
                user.uid,
              );
            }
            return promotion;
          })
          .where((promotion) =>
              promotion.promotionStart.isBefore(DateTime.now()) &&
              promotion.promotionEnd.isAfter(DateTime.now()))
          .toList();

  Future<void> launchWebApp(
      String route, String itemKey, String itemValue) async {
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    return locator<AuthService>().currentUser.getIdToken().then((idToken) {
      return launchURL(
        '$_baseUrl/auth/$route?access_token=$idToken&itemKey=$itemKey&itemValue=$itemValue',
      );
    });
  }

  Future<void> _setBaseUrl() async {
    _baseUrl = await remoteConfig.getAffiliateEndpoint();
  }
}
