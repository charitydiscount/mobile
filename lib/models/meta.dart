class ProgramMeta {
  final int count;
  final List<String> categories;

  ProgramMeta({this.count, this.categories});

  factory ProgramMeta.fromJson(Map<String, dynamic> json) => ProgramMeta(
      count: json['count'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []));
}

class TwoPerformantMeta {
  final String uniqueCode;
  final double percentage;

  TwoPerformantMeta({this.uniqueCode, this.percentage});

  factory TwoPerformantMeta.fromJson(Map<String, dynamic> json) =>
      TwoPerformantMeta(
          uniqueCode: json['uniqueCode'], percentage: json['percentage']);
}
