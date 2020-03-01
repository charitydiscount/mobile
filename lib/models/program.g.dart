// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Program _$ProgramFromJson(Map<String, dynamic> json) {
  return Program(
    id: Program.idFromJson(json['id']),
    uniqueCode: json['uniqueCode'] as String,
    status: json['status'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    mainUrl: json['mainUrl'] as String,
    affiliateUrl: json['affiliateUrl'] as String,
    logoPath: json['logoPath'] as String,
    defaultSaleCommissionRate: Program.defaultSaleCommissionRateFromJson(
        json['defaultSaleCommissionRate']),
    defaultSaleCommissionType: json['defaultSaleCommissionType'] as String,
    defaultLeadCommissionAmount: Program.defaultLeadCommissionAmountFromJson(
        json['defaultLeadCommissionAmount']),
    defaultLeadCommissionType: json['defaultLeadCommissionType'] as String,
    currency: json['currency'] as String,
    favorited: json['favorited'] as bool,
    source: json['source'] as String,
    rating: json['rating'] == null
        ? null
        : OverallRating.fromJson(json['rating'] as Map<String, dynamic>),
    order: json['order'] as int,
    mainOrder: json['mainOrder'] as int,
    productsCount: json['productsCount'] as int ?? 0,
    sellingCountries: (json['sellingCountries'] as List)
        ?.map((e) => e == null
            ? null
            : SellingCountry.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )
    ..saleCommissionRate = json['saleCommissionRate'] as String
    ..leadCommissionAmount = json['leadCommissionAmount'] as String
    ..actualAffiliateUrl = json['actualAffiliateUrl'] as String;
}

Map<String, dynamic> _$ProgramToJson(Program instance) => <String, dynamic>{
      'id': instance.id,
      'uniqueCode': instance.uniqueCode,
      'status': instance.status,
      'name': instance.name,
      'category': instance.category,
      'mainUrl': instance.mainUrl,
      'affiliateUrl': instance.affiliateUrl,
      'logoPath': instance.logoPath,
      'defaultSaleCommissionRate': Program.defaultSaleCommissionRateToJson(
          instance.defaultSaleCommissionRate),
      'defaultSaleCommissionType': instance.defaultSaleCommissionType,
      'defaultLeadCommissionAmount': Program.defaultLeadCommissionAmountToJson(
          instance.defaultLeadCommissionAmount),
      'defaultLeadCommissionType': instance.defaultLeadCommissionType,
      'currency': instance.currency,
      'source': instance.source,
      'order': instance.order,
      'mainOrder': instance.mainOrder,
      'productsCount': instance.productsCount,
      'sellingCountries': instance.sellingCountries,
      'rating': instance.rating,
      'favorited': instance.favorited,
      'saleCommissionRate': instance.saleCommissionRate,
      'leadCommissionAmount': instance.leadCommissionAmount,
      'actualAffiliateUrl': instance.actualAffiliateUrl,
    };

OverallRating _$OverallRatingFromJson(Map<String, dynamic> json) {
  return OverallRating(
    count: json['count'] as int,
    overall: (json['rating'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$OverallRatingToJson(OverallRating instance) =>
    <String, dynamic>{
      'count': instance.count,
      'rating': instance.overall,
    };

SellingCountry _$SellingCountryFromJson(Map<String, dynamic> json) {
  return SellingCountry(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    currency: json['currency'] as String,
  );
}

Map<String, dynamic> _$SellingCountryToJson(SellingCountry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'currency': instance.currency,
    };
