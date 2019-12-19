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

  Future<ProductSearchResult> searchProducts(
    String query, {
    String category,
    int programId,
    int from,
    SortStrategy sort,
    double minPrice,
    double maxPrice,
  });

  Future<List<Product>> getFeaturedProducts({String userId});
}

enum SortStrategy { priceAsc, priceDesc, relevance }

class SearchService implements SearchServiceBase {
  String _baseUrl;

  dynamic _search(
    String entity,
    String query,
    bool exact, {
    int from,
    SortStrategy sort,
    double minPrice,
    double maxPrice,
  }) async {
    String trimmedQuery = query.trim();
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    String url = '$_baseUrl/search/$entity?query=$trimmedQuery';

    if (exact == true) {
      url = '$url&exact=true';
    }

    if (from != null) {
      url = '$url&page=$from';
    }

    if (sort == SortStrategy.priceAsc) {
      url = '$url&sort=asc';
    }

    if (sort == SortStrategy.priceDesc) {
      url = '$url&sort=desc';
    }

    if (minPrice != null) {
      url = '$url&min=$minPrice';
    }

    if (maxPrice != null) {
      url = '$url&max=$maxPrice';
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
  Future<ProductSearchResult> searchProducts(
    String query, {
    String category,
    int programId,
    int from = 0,
    SortStrategy sort,
    double minPrice,
    double maxPrice,
  }) async {
    Map<String, dynamic> data = await _search(
      'products',
      query,
      false,
      from: from,
      sort: sort,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    if (!data.containsKey('hits')) {
      return ProductSearchResult([], 0);
    }
    List hits = data['hits'];
    return ProductSearchResult(
        productsFromElastic(hits), data['total']['value'] ?? 0);
  }

  @override
  Future<List<Product>> getFeaturedProducts({String userId}) async {
    Map<String, dynamic> data = await _search('products/featured', '', false);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Product> products = productsFromElastic(hits);

    return products;
  }
}
