import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class SearchServiceBase {
  Future<List<Program>> search(String query, {bool exact = false});

  Future<List<Suggestion>> getSuggestions(String query);

  Future<List<Product>> searchProducts(
    String query, {
    String category,
    int programId,
  });

  Future<List<Product>> getFeaturedProducts({String userId});
}

class SearchService implements SearchServiceBase {
  String _baseUrl;

  dynamic _search(String entity, String query, bool exact) async {
    String trimmedQuery = query.trim();
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    String url = '$_baseUrl/search/$entity?query=$trimmedQuery';

    if (exact == true) {
      url = '$url&exact=true';
    }

    IdTokenResult authToken = await authService.currentUser.getIdToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${authToken.token}',
    });

    if (response.statusCode != 200) {
      throw Exception('Search failed: (${response.statusCode})');
    }

    return json.decode(response.body);
  }

  @override
  Future<List<Program>> search(String query, {bool exact = false}) async {
    Map<String, dynamic> data = await _search('programs', query, exact);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Program> programs = fromElasticsearch(hits);

    return programs;
  }

  @override
  Future<List<Suggestion>> getSuggestions(String query) async {
    Map<String, dynamic> data = await _search('programs', query, false);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Suggestion> suggestions = List<Suggestion>.from(
      hits.map(
        (hit) => Suggestion(
          name: hit['_source']['name'],
          query: query,
        ),
      ),
    );

    suggestions.removeWhere(
      (suggestion) => !suggestion.name.startsWith(suggestion.query),
    );

    return suggestions;
  }

  Future<void> _setBaseUrl() async {
    _baseUrl = await remoteConfig.getSearchEndpoint();
  }

  @override
  Future<List<Product>> searchProducts(
    String query, {
    String category,
    int programId,
  }) async {
    Map<String, dynamic> data = await _search('products', query, false);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Product> products = productsFromElastic(hits);

    return products;
  }

  @override
  Future<List<Product>> getFeaturedProducts({String userId}) {
    return Future.value(
      List.generate(
        10,
        (index) => Product(
          title: 'Arta subtila a nepasarii | Mark Manson',
          brand: 'Lifestyle Publishing',
          category: 'Carte',
          id: '2328214',
          imageUrl: 'https://carturesti.ro/img-prod/2328214-0.jpeg',
          price: 31.2,
          oldPrice: 38.5,
          programId: 1677,
          programName: 'carturesti.ro',
          url: 'https://carturesti.ro/carte/arta-subtila-a-nepasarii-2328214',
        ),
      ),
    );
  }
}
