// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Market _$MarketFromJson(Map<String, dynamic> json) {
  return Market(
      programs: (json['programs'] as List)
          ?.map((e) =>
              e == null ? null : Program.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>));
}

Map<String, dynamic> _$MarketToJson(Market instance) => <String, dynamic>{
      'programs': instance.programs,
      'metadata': instance.metadata
    };

Metadata _$MetadataFromJson(Map<String, dynamic> json) {
  return Metadata(
      commissionVariation: json['commissionVariation'] == null
          ? null
          : MetadataCommissionVariation.fromJson(
              json['commissionVariation'] as Map<String, dynamic>),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>));
}

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'commissionVariation': instance.commissionVariation,
      'pagination': instance.pagination
    };

MetadataCommissionVariation _$MetadataCommissionVariationFromJson(
    Map<String, dynamic> json) {
  return MetadataCommissionVariation(
      days: json['days'] as int,
      forTopProgramsNumber: json['forTopProgramsNumber'] as int);
}

Map<String, dynamic> _$MetadataCommissionVariationToJson(
        MetadataCommissionVariation instance) =>
    <String, dynamic>{
      'days': instance.days,
      'forTopProgramsNumber': instance.forTopProgramsNumber
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return Pagination(
      results: json['results'] as int,
      pages: json['pages'] as int,
      currentPage: json['currentPage'] as int);
}

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'results': instance.results,
      'pages': instance.pages,
      'currentPage': instance.currentPage
    };

Program _$ProgramFromJson(Map<String, dynamic> json) {
  return Program(
      id: json['id'] as int,
      slug: json['slug'] as String,
      name: json['name'] as String,
      mainUrl: json['mainUrl'] as String,
      baseUrl: json['baseUrl'] as String,
      description: json['description'] as String,
      activatedAt: json['activatedAt'] == null
          ? null
          : DateTime.parse(json['activatedAt'] as String),
      userId: json['userId'] as int,
      uniqueCode: json['uniqueCode'] as String,
      status: json['status'] as String,
      cookieLife: json['cookieLife'] as int,
      tos: json['tos'] as String,
      productFeedsCount: json['productFeedsCount'] as int,
      productsCount: json['productsCount'] as int,
      bannersCount: json['bannersCount'] as int,
      approvalTime: json['approvalTime'] as int,
      currency: json['currency'] as String,
      workingCurrencyCode: json['workingCurrencyCode'] as String,
      enableLeads: json['enableLeads'] as bool,
      enableSales: json['enableSales'] as bool,
      defaultLeadCommissionAmount: json['defaultLeadCommissionAmount'],
      defaultLeadCommissionType: json['defaultLeadCommissionType'],
      defaultSaleCommissionRate: json['defaultSaleCommissionRate'] as String,
      defaultSaleCommissionType: json['defaultSaleCommissionType'] as String,
      approvedCommissionCountRate:
          json['approvedCommissionCountRate'] as String,
      approvedCommissionAmountRate:
          json['approvedCommissionAmountRate'] as String,
      paymentType: json['paymentType'] as String,
      balanceIndicator: json['balanceIndicator'] as String,
      downtime: json['downtime'] as String,
      averagePaymentTime: json['averagePaymentTime'] as int,
      logoId: json['logoId'] as int,
      logoPath: json['logoPath'] as String,
      userLogin: json['userLogin'] as String,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      sellingCountries: (json['sellingCountries'] as List)
          ?.map((e) => e == null
              ? null
              : SellingCountry.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      promotionalMethods: json['promotionalMethods'] == null
          ? null
          : PromotionalMethods.fromJson(
              json['promotionalMethods'] as Map<String, dynamic>),
      commissionVariation: json['commissionVariation'] == null
          ? null
          : ProgramCommissionVariation.fromJson(
              json['commissionVariation'] as Map<String, dynamic>),
      affrequest: json['affrequest'] == null
          ? null
          : Affrequest.fromJson(json['affrequest'] as Map<String, dynamic>));
}

Map<String, dynamic> _$ProgramToJson(Program instance) => <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'mainUrl': instance.mainUrl,
      'baseUrl': instance.baseUrl,
      'description': instance.description,
      'activatedAt': instance.activatedAt?.toIso8601String(),
      'userId': instance.userId,
      'uniqueCode': instance.uniqueCode,
      'status': instance.status,
      'cookieLife': instance.cookieLife,
      'tos': instance.tos,
      'productFeedsCount': instance.productFeedsCount,
      'productsCount': instance.productsCount,
      'bannersCount': instance.bannersCount,
      'approvalTime': instance.approvalTime,
      'currency': instance.currency,
      'workingCurrencyCode': instance.workingCurrencyCode,
      'enableLeads': instance.enableLeads,
      'enableSales': instance.enableSales,
      'defaultLeadCommissionAmount': instance.defaultLeadCommissionAmount,
      'defaultLeadCommissionType': instance.defaultLeadCommissionType,
      'defaultSaleCommissionRate': instance.defaultSaleCommissionRate,
      'defaultSaleCommissionType': instance.defaultSaleCommissionType,
      'approvedCommissionCountRate': instance.approvedCommissionCountRate,
      'approvedCommissionAmountRate': instance.approvedCommissionAmountRate,
      'paymentType': instance.paymentType,
      'balanceIndicator': instance.balanceIndicator,
      'downtime': instance.downtime,
      'averagePaymentTime': instance.averagePaymentTime,
      'logoId': instance.logoId,
      'logoPath': instance.logoPath,
      'userLogin': instance.userLogin,
      'category': instance.category,
      'sellingCountries': instance.sellingCountries,
      'promotionalMethods': instance.promotionalMethods,
      'commissionVariation': instance.commissionVariation,
      'affrequest': instance.affrequest
    };

Affrequest _$AffrequestFromJson(Map<String, dynamic> json) {
  return Affrequest(
      status: json['status'] as String,
      id: json['id'] as int,
      deleteAt: json['deleteAt'],
      suspendAt: json['suspendAt'],
      customConditions: json['customConditions'] as bool,
      customCookieLife: json['customCookieLife'] as bool,
      customCommission: json['customCommission'] as bool,
      cookieLife: json['cookieLife'] as int,
      commissionSaleRate: json['commissionSaleRate'] as String,
      commissionLeadAmount: json['commissionLeadAmount']);
}

Map<String, dynamic> _$AffrequestToJson(Affrequest instance) =>
    <String, dynamic>{
      'status': instance.status,
      'id': instance.id,
      'deleteAt': instance.deleteAt,
      'suspendAt': instance.suspendAt,
      'customConditions': instance.customConditions,
      'customCookieLife': instance.customCookieLife,
      'customCommission': instance.customCommission,
      'cookieLife': instance.cookieLife,
      'commissionSaleRate': instance.commissionSaleRate,
      'commissionLeadAmount': instance.commissionLeadAmount
    };

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
      name: json['name'] as String,
      id: json['id'] as int,
      programsCount: json['programsCount'] as int,
      averageApprovalRateAmount: json['averageApprovalRateAmount'] as int,
      averageApprovalRateCount: json['averageApprovalRateCount'] as int,
      oldestPendingCommission: json['oldestPendingCommission'] as int,
      commission: json['commission'] as int);
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'programsCount': instance.programsCount,
      'averageApprovalRateAmount': instance.averageApprovalRateAmount,
      'averageApprovalRateCount': instance.averageApprovalRateCount,
      'oldestPendingCommission': instance.oldestPendingCommission,
      'commission': instance.commission
    };

ProgramCommissionVariation _$ProgramCommissionVariationFromJson(
    Map<String, dynamic> json) {
  return ProgramCommissionVariation(change: json['change'] as String);
}

Map<String, dynamic> _$ProgramCommissionVariationToJson(
        ProgramCommissionVariation instance) =>
    <String, dynamic>{'change': instance.change};

PromotionalMethods _$PromotionalMethodsFromJson(Map<String, dynamic> json) {
  return PromotionalMethods(
      googlePpc: json['googlePpc'] as String,
      paidSocialMedia: json['paidSocialMedia'] as String);
}

Map<String, dynamic> _$PromotionalMethodsToJson(PromotionalMethods instance) =>
    <String, dynamic>{
      'googlePpc': instance.googlePpc,
      'paidSocialMedia': instance.paidSocialMedia
    };

SellingCountry _$SellingCountryFromJson(Map<String, dynamic> json) {
  return SellingCountry(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      currency: json['currency'] as String);
}

Map<String, dynamic> _$SellingCountryToJson(SellingCountry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'currency': instance.currency
    };
