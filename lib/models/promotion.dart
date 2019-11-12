List<Promotion> promotionsFromJsonArray(List json) {
  return List<Promotion>.from(
    json.map((promotion) => Promotion.fromJson(promotion)).toList(),
  );
}

class Promotion {
  final int id;
  final String name;
  final int programId;
  final String campaignLogo;
  final DateTime promotionStart;
  final DateTime promotionEnd;
  final String landingPageLink;

  String affilitateUrl;

  Promotion({
    this.id,
    this.name,
    this.programId,
    this.campaignLogo,
    this.promotionStart,
    this.promotionEnd,
    this.landingPageLink,
    this.affilitateUrl,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'],
        name: json['name'],
        programId: json['programId'],
        campaignLogo: json['campaignLogo'],
        promotionStart: DateTime.parse(json['promotionStart']),
        promotionEnd: DateTime.parse(json['promotionEnd']),
        landingPageLink: json['landingPageLink'],
      );
}
