import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class Program {
  final String id;
  final String uniqueCode;
  final String status;
  final String name;
  final String category;
  final String mainUrl;
  final String logoPath;
  final double defaultSaleCommissionRate;
  final String defaultSaleCommissionType;
  final double defaultLeadCommissionAmount;
  final String defaultLeadCommissionType;
  final String currency;
  final String source;
  final int order;
  OverallRating rating;

  bool favorited;
  String affilitateUrl;
  String saleCommissionRate;
  String leadCommissionAmount;

  Program({
    this.id,
    this.uniqueCode,
    this.status,
    this.name,
    this.category,
    this.mainUrl,
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
  });

  factory Program.fromJson(Map json) {
    return Program(
      id: json['id'].toString(),
      uniqueCode: json['uniqueCode'],
      status: json['status'] ?? 'active',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      mainUrl: json['mainUrl'] ?? '',
      logoPath:
          json['logoPath'] ?? 'https://charitydiscount.ro/img/favicon.png',
      defaultSaleCommissionRate: json['defaultSaleCommissionRate'] != null
          ? double.tryParse(json['defaultSaleCommissionRate']) ?? 0
          : null,
      defaultSaleCommissionType: json['defaultSaleCommissionType'],
      defaultLeadCommissionAmount: json['defaultLeadCommissionAmount'] != null
          ? double.tryParse(json['defaultLeadCommissionAmount']) ?? 0
          : null,
      defaultLeadCommissionType: json['defaultLeadCommissionType'],
      currency: json['currency'] ?? 'RON',
      source: json['source'] ?? '',
      rating: json['rating'] != null
          ? OverallRating.fromJson(json['rating'])
          : OverallRating.fromJson({}),
      order: parseOrder(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uniqueCode': uniqueCode,
        'status': status,
        'name': name,
        'category': category,
        'mainUrl': mainUrl,
        'logoPath': logoPath,
        'defaultSaleCommissionRate': defaultSaleCommissionRate != null
            ? defaultSaleCommissionRate.toString()
            : null,
        'defaultSaleCommissionType': defaultSaleCommissionType,
        'defaultLeadCommissionAmount': defaultLeadCommissionAmount != null
            ? defaultLeadCommissionAmount.toString()
            : null,
        'defaultLeadCommissionType': defaultLeadCommissionType,
        'currency': currency,
        'source': source,
        'order': order,
      };
}

int parseOrder(dynamic json) {
  if (json['mainOrder'] is int) {
    return json['mainOrder'];
  }

  if (json['mainOrder'] != null) {
    return int.tryParse(json['mainOrder']);
  }

  if (json['order'] is int) {
    return json['order'];
  }

  if (json['order'] != null) {
    return int.tryParse(json['order']);
  }

  return 10000;
}

enum CommissionType {
  percent,
  variable,
  fixed,
}

CommissionType getCommissionTypeEnum(String type) => CommissionType.values
    .firstWhere((e) => e.toString() == 'CommissionType.' + type.toLowerCase());

class OverallRating {
  int count;
  double overall;

  OverallRating({this.count, this.overall});

  factory OverallRating.fromJson(Map json) => OverallRating(
        count: json['count'] ?? 0,
        overall: json['rating'] != null
            ? double.tryParse(json['rating'].toString()) ?? null
            : null,
      );
}
