import 'package:http/http.dart' as http;
import 'package:charity_discount/models/market.dart';
import 'dart:convert';

final String baseUrl = 'https://api.2performant.com/affiliate';

class AffiliateService {
  final Map<String, String> headers;
  
  const AffiliateService(this.headers);

  Future<Market> getMarket() async {
    final url = baseUrl + '/programs?filter[relation]=accepted';
    final response = await http.get(url, headers: headers);

    if(response.statusCode != 200) {
      throw Exception('Could not load shops (${response.statusCode})');
    }

    return Market.fromJson(json.decode(response.body));
  }
}
