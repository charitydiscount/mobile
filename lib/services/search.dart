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
    if (_baseUrl == null) {
      await _setBaseUrl();
    }

    String url = '$_baseUrl/search?query=$query';

    if (exact == true) {
      url = url + '&exact=true';
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
    dynamic data = await _search(query, exact);
    List<Program> programs = fromJsonArray(data);

    return programs;
  }

  Future<List<Suggestion>> getSuggestions(String query) async {
    dynamic data = await _search(query, false);
    List hits = data ?? [];
    List<Suggestion> suggestions = List<Suggestion>.from(hits.map(
      (hit) => Suggestion(
        name: hit['name'],
        formattedName: hit['_highlightResult']['name']['value'],
      ),
    ));

    return suggestions;
  }

  Future<void> _setBaseUrl() async {
    _baseUrl = await remoteConfig.getSearchEndpoint();
  }
}

final SearchService searchService = SearchService();
