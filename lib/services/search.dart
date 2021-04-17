import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class SearchServiceBase {
  Future<List<Program>> search(String query, {bool exact = false});

  Future<List<Suggestion>> getSuggestions(String query);

  Future<ProductSearchResult> searchProducts(
    String query, {
    String programId,
    int from,
    SortStrategy sort,
    double minPrice,
    double maxPrice,
  });

  Future<List<Product>> getFeaturedProducts({String userId});

  Future<ProductSearchResult> getProductsForProgram({
    @required Program program,
    int size = 20,
    int from = 0,
  });

  Future<ProductPriceHistory> getProductPriceHistory(String productId);

  Future<List<Product>> getSimilarProducts({
    @required Product product,
    int from = 0,
  });
}

enum SortStrategy { priceAsc, priceDesc, relevance }

class SearchService implements SearchServiceBase {
  String _baseUrl;
  Map<String, ProductSearchResult> _cache = Map();

  dynamic _search(
    String entity, {
    String query = '',
    bool exact = false,
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

    String authToken = await locator<AuthService>().currentUser.getIdToken();
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode != 200) {
      throw Exception('Search failed: (${response.statusCode})');
    }

    return json.decode(response.body);
  }

  dynamic _searchPost(String entity, String query, int from) async {
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    String url = '$_baseUrl/search/$entity?';

    if (from != null) {
      url = '$url&from=$from';
    }

    String authToken = await locator<AuthService>().currentUser.getIdToken();
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'query': query,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Search failed: (${response.statusCode})');
    }

    return json.decode(response.body);
  }

  @override
  Future<List<Program>> search(String query, {bool exact = false}) async {
    Map<String, dynamic> data = await _search('programs', query: query, exact: exact);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Program> programs = fromElasticsearch(hits);

    return programs;
  }

  @override
  Future<List<Suggestion>> getSuggestions(String query) async {
    Map<String, dynamic> data = await _search('programs', query: query);
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
    String programId,
    int from = 0,
    SortStrategy sort,
    double minPrice,
    double maxPrice,
  }) async {
    Map<String, dynamic> data = await _search(
      'products',
      query: query,
      from: from,
      sort: sort,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    if (!data.containsKey('hits')) {
      return ProductSearchResult([], 0);
    }
    List hits = data['hits'];
    return ProductSearchResult(productsFromElastic(hits), data['total']['value'] ?? 0);
  }

  @override
  Future<List<Product>> getFeaturedProducts({String userId}) async {
    Map<String, dynamic> data = await _search('products/featured');
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Product> products = productsFromElastic(hits);

    return products;
  }

  @override
  Future<ProductSearchResult> getProductsForProgram({
    @required Program program,
    int size = 20,
    int from = 0,
  }) async {
    if (program.productsCount == 0 && program.source != Source.altex) {
      return ProductSearchResult([], 0);
    }

    final cachedResult = _getCachedResult(program.id, size, from);
    if (cachedResult != null) return cachedResult;

    Map<String, dynamic> data = await _searchPost('programs/${program.name}/products', '', 0);

    if (!data.containsKey('hits')) {
      return ProductSearchResult([], 0);
    }

    if (!data.containsKey('hits')) {
      return ProductSearchResult([], 0);
    }

    final result = ProductSearchResult(
      productsFromElastic(List.from(data['hits'])),
      data['total']['value'] ?? 0,
    );
    _cacheResult(program.id, result);

    return result;
  }

  ProductSearchResult _getCachedResult(String programId, int size, int from) {
    final cache = _cache[programId];
    if (cache == null) return null;
    if (cache.products.length < from + size) return null;

    return ProductSearchResult(
      cache.products.sublist(from, size),
      cache.totalFound,
    );
  }

  void _cacheResult(String programId, ProductSearchResult result) {
    if (_cache[programId] == null) {
      _cache[programId] = result;
    } else {
      _cache[programId].products.addAll(result.products);
    }
  }

  @override
  Future<ProductPriceHistory> getProductPriceHistory(String productId) async {
    Map<String, dynamic> data = await _searchPost('products/history', productId, 0);
    if (!data.containsKey('hits')) {
      return ProductPriceHistory(productId, []);
    }

    return ProductPriceHistory(
      productId,
      productHistoryFromElastic(List.from(data['hits'])),
    );
  }

  @override
  Future<List<Product>> getSimilarProducts({
    Product product,
    int from = 0,
  }) async {
    Map<String, dynamic> data = await _searchPost('products/similar', product.id, from);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Product> products = productsFromElastic(hits);

    return products;
  }
}
