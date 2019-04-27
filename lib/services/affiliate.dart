import 'package:http/http.dart' as http;
import 'package:charity_discount/models/market.dart';
import 'dart:convert';

final String baseUrl = 'https://api.2performant.com/affiliate';

class AffiliateService {
  Map<String, String> _auth;

  _initAuth() async {
    final response =
        await http.get('https://charity-proxy.appspot.com/2p-auth');

    if (response.statusCode != 200) {
      throw Exception('Failed to get auth data (${response.statusCode})');
    }

    final relevantHeaders = ['access-token', 'client', 'uid', 'token-type'];

    _auth = response.headers;
    _auth.removeWhere((key, value) => !relevantHeaders.contains(key));
    _auth.putIfAbsent('Content-Type', () => 'application/json');
    _auth.putIfAbsent('Accept', () => 'application/json');
  }

  Future<Market> getMarket() async {
    if (_auth == null) {
      await _initAuth();
    }

    final url = baseUrl + '/programs?filter[relation]=accepted';
    final response = await http.get(url, headers: _auth);

    if (response.statusCode != 200) {
      throw Exception('Could not load shops (${response.statusCode})');
    }

    return Market.fromJson(json.decode(response.body));
  }
}

final AffiliateService affiliateService = new AffiliateService();
