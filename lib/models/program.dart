import 'package:cloud_firestore/cloud_firestore.dart';

List<Program> fromFirestoreBatch(DocumentSnapshot doc) {
  List data = doc.data['batch'] ?? [];
  return List<Program>.from(
      data.map((program) => Program.fromJson(program)).toList());
}

class Program {
  final int id;
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

  bool favorited;
  String affilitateUrl;
  String saleCommissionRate;
  String leadCommissionAmount;

  Program(
      {this.id,
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
      this.source});

  factory Program.fromJson(Map json) {
    return Program(
        id: json['id'],
        uniqueCode: json['uniqueCode'],
        status: json['status'] ?? 'active',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        mainUrl: json['mainUrl'] ?? '',
        logoPath:
            json['logoPath'] ?? 'https://charitydiscount.ro/img/favicon.png',
        defaultSaleCommissionRate: json['defaultSaleCommissionRate'] != null
            ? double.parse(json['defaultSaleCommissionRate'])
            : null,
        defaultSaleCommissionType: json['defaultSaleCommissionType'],
        defaultLeadCommissionAmount: json['defaultLeadCommissionAmount'] != null
            ? double.parse(json['defaultLeadCommissionAmount'])
            : null,
        defaultLeadCommissionType: json['defaultLeadCommissionType'],
        currency: json['currency'] ?? 'RON',
        source: json['source'] ?? '');
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
        'source': source
      };
}
