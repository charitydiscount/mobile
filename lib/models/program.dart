import 'package:cloud_firestore/cloud_firestore.dart';

List<Program> fromFirestoreBatch(DocumentSnapshot doc) {
  List data = doc.data['batch'] ?? [];
  return List<Program>.from(data.map((program) => Program.fromJson(program)));
}

class Program {
  final int id;
  final String uniqueCode;
  final String status;
  final String name;
  final String category;
  final String mainUrl;
  final String logoPath;
  final double saleCommissionRate;
  final String saleCommissionType;
  final double leadCommissionAmount;
  final String leadCommissionType;
  final String currency;
  bool favorited;
  final String source;

  Program(
      {this.id,
      this.uniqueCode,
      this.status,
      this.name,
      this.category,
      this.mainUrl,
      this.logoPath,
      this.saleCommissionRate,
      this.saleCommissionType,
      this.leadCommissionAmount,
      this.leadCommissionType,
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
        saleCommissionRate:
            double.parse(json['defaultSaleCommissionRate'] ?? '0'),
        saleCommissionType: json['defaultSaleCommissionType'],
        leadCommissionAmount:
            double.parse(json['defaultLeadCommissionAmount'] ?? '0'),
        leadCommissionType: json['defaultLeadCommissionType'],
        currency: json['currency'] ?? 'RON',
        source: json['source'] ?? '');
  }
}
