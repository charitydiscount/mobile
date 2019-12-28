import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charity_discount/util/url.dart';

class AffiliateService {
  String _baseUrl;

  Future<List<Promotion>> getPromotions({
    String affiliateUniqueCode,
    int programId,
    String programUniqueCode,
    String userId,
  }) async {
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    final url = '$_baseUrl/programs/$programId/promotions';

    IdTokenResult authToken = await authService.currentUser.getIdToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${authToken.token}',
    });

    if (response.statusCode != 200) {
      throw Exception('Could not load shops (${response.statusCode})');
    }

    List responseBody = List<dynamic>.from(json.decode(response.body));
    if (responseBody.isEmpty) {
      return [];
    }
    List<Promotion> promotions = promotionsFromJsonArray(responseBody);

    promotions.forEach((p) {
      p.affilitateUrl = convertAffiliateUrl(
        p.landingPageLink,
        affiliateUniqueCode,
        programUniqueCode,
        userId,
      );
    });

    return promotions;
  }

  Future<void> launchWebApp(
      String route, String itemKey, String itemValue) async {
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    return authService.currentUser.getIdToken().then((idToken) {
      return launchURL(
          '$_baseUrl/auth/$route?itemKey=$itemKey&itemValue=$itemValue',
          headers: {
            'Authorization': 'Bearer ${idToken.token}',
          });
    });
  }

  Future<void> _setBaseUrl() async {
    _baseUrl = await remoteConfig.getAffiliateEndpoint();
  }
}

final AffiliateService affiliateService = AffiliateService();
