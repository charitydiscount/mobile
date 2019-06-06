import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charity_discount/models/promotions.dart';
import 'package:charity_discount/util/url.dart';

final String baseUrl = 'https://api.2performant.com/affiliate';

class AffiliateService {
  Map<String, String> _auth;

  _initAuth() async {
    final response =
        await http.get('https://charity-proxy.appspot.com/2p-auth');

    if (response.statusCode != 200) {
      throw Exception('Failed to get auth data (${response.statusCode})');
    }

    final relevantHeaders = [
      'access-token',
      'client',
      'uid',
      'token-type',
      'unique-id'
    ];

    _auth = response.headers;
    _auth.removeWhere((key, value) => !relevantHeaders.contains(key));
    _auth.putIfAbsent('Content-Type', () => 'application/json');
    _auth.putIfAbsent('Accept', () => 'application/json');
  }

  Future<List<AdvertiserPromotion>> getPromotions(
      int programId, String uniqueId, String userId) async {
    if (_auth == null) {
      await _initAuth();
    }

    final url =
        baseUrl + '/advertiser_promotions?filter[affrequest_status]=accepted';
    final response = await http.get(url, headers: _auth);

    if (response.statusCode != 200) {
      throw Exception('Could not load shops (${response.statusCode})');
    }

    Promotions promotions = Promotions.fromJson(json.decode(response.body));
    promotions.advertiserPromotions
        .removeWhere((p) => p.program.id != programId);

    promotions.advertiserPromotions.forEach((p) {
      p.landingPageLink = convertAffiliateUrl(
          p.landingPageLink, _auth['unique-id'], uniqueId, userId);
    });

    return promotions.advertiserPromotions;
  }
}

final AffiliateService affiliateService = new AffiliateService();
