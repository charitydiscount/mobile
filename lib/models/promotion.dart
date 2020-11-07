import 'package:charity_discount/util/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'promotion.g.dart';

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
  final String affiliateUrl;
  final PromotionProgram program;
  final String source;

  String actualAffiliateUrl;

  Promotion({
    this.id,
    this.name,
    this.programId,
    this.campaignLogo,
    this.promotionStart,
    this.promotionEnd,
    this.landingPageLink,
    this.affiliateUrl,
    this.program,
    this.source,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'],
        name: json['name'],
        programId: json['programId'],
        campaignLogo: json['campaignLogo'],
        promotionStart: DateTime.parse(json['promotionStart']),
        promotionEnd: DateTime.parse(json['promotionEnd']),
        landingPageLink: json['landingPageLink'],
        affiliateUrl: json['affiliateUrl'],
        program: PromotionProgram.fromJson(json['program']),
        source: json['source'] ?? Source.twoP,
      );
}

@JsonSerializable()
class PromotionProgram {
  final int id;
  final String name;

  PromotionProgram({this.id, this.name});

  factory PromotionProgram.fromJson(dynamic json) => _$PromotionProgramFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionProgramToJson(this);
}
