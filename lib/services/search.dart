import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchService {
  final baseUrl = 'https://FD3M2QUXMQ-dsn.algolia.net/1/indexes/programs';

  dynamic _search(String query, exact) async {
    String url = baseUrl + '?query=$query';

    if (exact == true) {
      url = url + '&typoTolerance=false';
    }

    final response = await http.get(url, headers: {
      'X-Algolia-API-Key': '71b71c5df443405fda1ba5a735aeef71',
      'X-Algolia-Application-Id': 'FD3M2QUXMQ',
    });

    if (response.statusCode != 200) {
      throw Exception('Search failed: (${response.statusCode})');
    }

    return json.decode(response.body);
  }

  Future<List<Program>> search(String query, {bool exact = false}) async {
    dynamic data = await _search(query, exact);
    List<Program> programs = fromJsonArray(data['hits']);

    return programs;
  }

  Future<List<Suggestion>> getSuggestions(String query) async {
    dynamic data = await _search(query, false);
    List hits = data['hits'] ?? [];
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
