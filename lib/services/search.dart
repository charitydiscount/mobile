import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchService {
  String _baseUrl;

  dynamic _search(String query, exact) async {
    String trimmedQuery = query.trim();
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    String url = '$_baseUrl/search?query=$trimmedQuery';

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

  Future<List<Program>> search(String query, {bool exact = false}) async {
    Map<String, dynamic> data = await _search(query, exact);
    if (!data.containsKey('hits')) {
      return [];
    }
    List hits = data['hits'];
    List<Program> programs = fromElasticsearch(hits);

    return programs;
  }

  Future<List<Suggestion>> getSuggestions(String query) async {
    Map<String, dynamic> data = await _search(query, false);
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
}

final SearchService searchService = SearchService();
