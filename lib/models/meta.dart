import 'package:charity_discount/models/program.dart';

class ProgramMeta {
  final int count;
  final List<String> categories;
  final Map<String, OverallRating> ratings;

  ProgramMeta({this.count, this.categories, this.ratings});

  factory ProgramMeta.fromJson(Map<String, dynamic> json) => ProgramMeta(
        count: json['count'] ?? 0,
        categories: List<String>.from(
          json['categories'] ?? [],
        ),
        ratings: Map.from(json['ratings'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            OverallRating.fromJson(value),
          ),
        ),
      );
}

class TwoPerformantMeta {
  final String uniqueCode;
  final double percentage;

  TwoPerformantMeta({this.uniqueCode, this.percentage});

  factory TwoPerformantMeta.fromJson(Map<String, dynamic> json) =>
      TwoPerformantMeta(
        uniqueCode: json['uniqueCode'],
        percentage: json['percentage'],
      );
}
