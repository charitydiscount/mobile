import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/util/url.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AffiliateService {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _baseUrl;

  Future<List<Promotion>> getPromotions({
    String affiliateUniqueCode,
    String programId,
    String programUniqueCode,
  }) =>
      _auth.currentUser().then(
            (user) => _db
                .collection('promotions')
                .document(programId)
                .get()
                .then((snap) => snap.exists
                    ? _promotionsFromSnapData(
                        snap.data, affiliateUniqueCode, programUniqueCode, user)
                    : []),
          );

  List<Promotion> _promotionsFromSnapData(
    Map<String, dynamic> snapData,
    String affiliateUniqueCode,
    String programUniqueCode,
    FirebaseUser user,
  ) =>
      snapData.entries
          .map((snapEntry) {
            final promotion =
                Promotion.fromJson(Map<String, dynamic>.from(snapEntry.value));
            if (promotion.affiliateUrl != null) {
              promotion.actualAffiliateUrl = interpolateUserCode(
                promotion.landingPageLink,
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

    return authService.currentUser.getIdToken().then((idToken) {
      return launchURL(
        '$_baseUrl/auth/$route?access_token=${idToken.token}&itemKey=$itemKey&itemValue=$itemValue',
      );
    });
  }

  Future<void> _setBaseUrl() async {
    _baseUrl = await remoteConfig.getAffiliateEndpoint();
  }
}

final AffiliateService affiliateService = AffiliateService();
