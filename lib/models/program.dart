import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'program.g.dart';

List<Program> fromFirestoreBatch(DocumentSnapshot doc) {
  List data = doc.data['batch'] ?? [];
  return fromJsonArray(data);
}

List<Program> fromJsonArray(List json) {
  return List<Program>.from(
    json.map((program) => Program.fromJson(program)).toList(),
  );
}

List<Program> fromElasticsearch(List json) {
  return List<Program>.from(
    json.map((program) => Program.fromJson(program['_source'])).toList(),
  );
}

List<String> programsToJson(List<Program> programs) {
  return programs.map((p) => json.encode(p.toJson())).toList();
}

List<Program> fromJsonStringList(List<String> jsonList) {
  return List<Program>.from(
    jsonList.map((program) => Program.fromJson(json.decode(program))).toList(),
  );
}

@JsonSerializable()
class Program {
  @JsonKey(fromJson: idFromJson)
  final String id;
  final String uniqueCode;
  final String status;
  final String name;
  final String category;
  final String mainUrl;
  final String affiliateUrl;
  final String logoPath;
  @JsonKey(
    toJson: defaultSaleCommissionRateToJson,
    fromJson: defaultSaleCommissionRateFromJson,
  )
  final double defaultSaleCommissionRate;
  final String defaultSaleCommissionType;
  @JsonKey(
    toJson: defaultLeadCommissionAmountToJson,
    fromJson: defaultLeadCommissionAmountFromJson,
  )
  final double defaultLeadCommissionAmount;
  final String defaultLeadCommissionType;
  final String currency;
  final String source;
  final int order;
  final int mainOrder;
  final int productsCount;
  OverallRating rating;

  bool favorited;
  String saleCommissionRate;
  String leadCommissionAmount;
  String actualAffiliateUrl;

  Program({
    this.id,
    this.uniqueCode,
    this.status,
    this.name,
    this.category,
    this.mainUrl,
    this.affiliateUrl,
    this.logoPath,
    this.defaultSaleCommissionRate,
    this.defaultSaleCommissionType,
    this.defaultLeadCommissionAmount,
    this.defaultLeadCommissionType,
    this.currency,
    this.favorited = false,
    this.source,
    this.rating,
    this.order,
    this.mainOrder,
    this.productsCount,
  });

  factory Program.fromJson(Map json) => _$ProgramFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramToJson(this);

  int getOrder() {
    if (mainOrder != null) {
      return mainOrder;
    }

    if (order != null) {
      return order;
    }

    return 10000;
  }

  static String idFromJson(dynamic json) => json.toString();

  static double defaultSaleCommissionRateFromJson(dynamic json) {
    return json != null ? double.tryParse(json) ?? 0 : null;
  }

  static String defaultSaleCommissionRateToJson(
      double defaultSaleCommissionRate) {
    return defaultSaleCommissionRate != null
        ? defaultSaleCommissionRate.toString()
        : null;
  }

  static double defaultLeadCommissionAmountFromJson(dynamic json) {
    return json != null ? double.tryParse(json) ?? 0 : null;
  }

  static String defaultLeadCommissionAmountToJson(
      double defaultLeadCommissionAmount) {
    return defaultLeadCommissionAmount != null
        ? defaultLeadCommissionAmount.toString()
        : null;
  }
}

enum CommissionType {
  percent,
  variable,
  fixed,
}

CommissionType getCommissionTypeEnum(String type) => CommissionType.values
    .firstWhere((e) => e.toString() == 'CommissionType.' + type.toLowerCase());

@JsonSerializable()
class OverallRating {
  int count;
  @JsonKey(name: 'rating')
  double overall;

  OverallRating({this.count, this.overall});

  factory OverallRating.fromJson(Map json) => _$OverallRatingFromJson(json);

  Map<String, dynamic> toJson() => _$OverallRatingToJson(this);
}
