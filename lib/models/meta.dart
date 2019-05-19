class ProgramMeta {
  final int count;
  final List<String> categories;

  ProgramMeta({this.count, this.categories});

  factory ProgramMeta.fromJson(Map<String, dynamic> json) => ProgramMeta(
      count: json['count'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []));
}
