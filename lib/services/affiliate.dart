import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/util/url.dart';

class AffiliateService {
  final Firestore _db = Firestore.instance;
  String _baseUrl;

  Future<List<Promotion>> getPromotions({
    String affiliateUniqueCode,
    int programId,
    String programUniqueCode,
    String userId,
  }) async {
    final snap =
        await _db.collection('promotions').document('$programId').get();
    if (!snap.exists) {
      return [];
    }

    return snap.data.entries
        .map((snapEntry) {
          final promotion =
              Promotion.fromJson(Map<String, dynamic>.from(snapEntry.value));
          promotion.affilitateUrl = convertAffiliateUrl(
            promotion.landingPageLink,
            affiliateUniqueCode,
            programUniqueCode,
            userId,
          );
          return promotion;
        })
        .where((promotion) =>
            promotion.promotionStart.isBefore(DateTime.now()) &&
            promotion.promotionEnd.isAfter(DateTime.now()))
        .toList();
  }

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
