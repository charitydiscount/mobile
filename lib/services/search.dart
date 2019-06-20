import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchService {
  final baseUrl = 'https://charity-proxy.appspot.com/search';

  dynamic _search(String query, exact) async {
    String url = '$baseUrl?query=$query';

    if (exact == true) {
      url = url + '&exact=true';
    }

    String authToken = await authService.currentUser.getIdToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
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
}

final SearchService searchService = SearchService();
