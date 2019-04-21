import 'package:json_annotation/json_annotation.dart';

part 'market.g.dart';

@JsonSerializable()
class Market {
  List<Program> programs;
  Metadata metadata;

  Market({
    this.programs,
    this.metadata,
  });

  factory Market.fromJson(Map<String, dynamic> json) =>
    _$MarketFromJson(json);
}

@JsonSerializable()
class Metadata {
  MetadataCommissionVariation commissionVariation;
  Pagination pagination;

  Metadata({
    this.commissionVariation,
    this.pagination,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) =>
    _$MetadataFromJson(json);
}

@JsonSerializable()
class MetadataCommissionVariation {
  int days;
  int forTopProgramsNumber;

  MetadataCommissionVariation({
    this.days,
    this.forTopProgramsNumber,
  });

  factory MetadataCommissionVariation.fromJson(Map<String, dynamic> json) =>
    _$MetadataCommissionVariationFromJson(json);
}

@JsonSerializable()
class Pagination {
  int results;
  int pages;
  int currentPage;

  Pagination({
    this.results,
    this.pages,
    this.currentPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
    _$PaginationFromJson(json);
}

@JsonSerializable()
class Program {
  int id;
  String slug;
  String name;
  String mainUrl;
  String baseUrl;
  String description;
  DateTime activatedAt;
  int userId;
  String uniqueCode;
  String status;
  int cookieLife;
  String tos;
  int productFeedsCount;
  int productsCount;
  int bannersCount;
  int approvalTime;
  String currency;
  String workingCurrencyCode;
  bool enableLeads;
  bool enableSales;
  dynamic defaultLeadCommissionAmount;
  dynamic defaultLeadCommissionType;
  String defaultSaleCommissionRate;
  String defaultSaleCommissionType;
  String approvedCommissionCountRate;
  String approvedCommissionAmountRate;
  String paymentType;
  String balanceIndicator;
  String downtime;
  int averagePaymentTime;
  int logoId;
  String logoPath;
  String userLogin;
  Category category;
  List<SellingCountry> sellingCountries;
  PromotionalMethods promotionalMethods;
  ProgramCommissionVariation commissionVariation;
  Affrequest affrequest;

  Program({
    this.id,
    this.slug,
    this.name,
    this.mainUrl,
    this.baseUrl,
    this.description,
    this.activatedAt,
    this.userId,
    this.uniqueCode,
    this.status,
    this.cookieLife,
    this.tos,
    this.productFeedsCount,
    this.productsCount,
    this.bannersCount,
    this.approvalTime,
    this.currency,
    this.workingCurrencyCode,
    this.enableLeads,
    this.enableSales,
    this.defaultLeadCommissionAmount,
    this.defaultLeadCommissionType,
    this.defaultSaleCommissionRate,
    this.defaultSaleCommissionType,
    this.approvedCommissionCountRate,
    this.approvedCommissionAmountRate,
    this.paymentType,
    this.balanceIndicator,
    this.downtime,
    this.averagePaymentTime,
    this.logoId,
    this.logoPath,
    this.userLogin,
    this.category,
    this.sellingCountries,
    this.promotionalMethods,
    this.commissionVariation,
    this.affrequest,
  });

  factory Program.fromJson(Map<String, dynamic> json) =>
    _$ProgramFromJson(json);
}

@JsonSerializable()
class Affrequest {
  String status;
  int id;
  dynamic deleteAt;
  dynamic suspendAt;
  bool customConditions;
  bool customCookieLife;
  bool customCommission;
  int cookieLife;
  String commissionSaleRate;
  dynamic commissionLeadAmount;

  Affrequest({
    this.status,
    this.id,
    this.deleteAt,
    this.suspendAt,
    this.customConditions,
    this.customCookieLife,
    this.customCommission,
    this.cookieLife,
    this.commissionSaleRate,
    this.commissionLeadAmount,
  });

  factory Affrequest.fromJson(Map<String, dynamic> json) =>
    _$AffrequestFromJson(json);
}

@JsonSerializable()
class Category {
  String name;
  int id;
  int programsCount;
  int averageApprovalRateAmount;
  int averageApprovalRateCount;
  int oldestPendingCommission;
  int commission;

  Category({
    this.name,
    this.id,
    this.programsCount,
    this.averageApprovalRateAmount,
    this.averageApprovalRateCount,
    this.oldestPendingCommission,
    this.commission,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
    _$CategoryFromJson(json);
}

@JsonSerializable()
class ProgramCommissionVariation {
  String change;

  ProgramCommissionVariation({
    this.change,
  });

  factory ProgramCommissionVariation.fromJson(Map<String, dynamic> json) =>
    _$ProgramCommissionVariationFromJson(json);
}

@JsonSerializable()
class PromotionalMethods {
  String googlePpc;
  String paidSocialMedia;

  PromotionalMethods({
    this.googlePpc,
    this.paidSocialMedia,
  });

  factory PromotionalMethods.fromJson(Map<String, dynamic> json) =>
    _$PromotionalMethodsFromJson(json);
}

@JsonSerializable()
class SellingCountry {
  int id;
  String name;
  String code;
  String currency;

  SellingCountry({
    this.id,
    this.name,
    this.code,
    this.currency,
  });

  factory SellingCountry.fromJson(Map<String, dynamic> json) =>
    _$SellingCountryFromJson(json);
}
