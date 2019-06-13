import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charity_discount/util/url.dart';

final String baseUrl = 'https://charity-proxy.appspot.com';

class AffiliateService {
  Future<List<Promotion>> getPromotions({
    String affiliateUniqueCode,
    int programId,
    String programUniqueCode,
    String userId,
  }) async {
    final url = '$baseUrl/programs/$programId/promotions';

    String authToken = await authService.currentUser.getIdToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode != 200) {
      throw Exception('Could not load shops (${response.statusCode})');
    }

    List<Promotion> promotions = promotionsFromJsonArray(
      json.decode(response.body),
    );

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
}

final AffiliateService affiliateService = AffiliateService();
