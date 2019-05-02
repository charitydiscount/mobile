import 'dart:convert';

Market marketFromJson(String str) => Market.fromJson(json.decode(str));

String marketToJson(Market data) => json.encode(data.toJson());

class Market {
  List<Program> programs;
  Metadata metadata;

  Market({
    this.programs,
    this.metadata,
  });

  factory Market.fromJson(Map<String, dynamic> json) => Market(
        programs: List<Program>.from(
            json["programs"].map((x) => Program.fromJson(x))),
        metadata: Metadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "programs": List<dynamic>.from(programs.map((x) => x.toJson())),
        "metadata": metadata.toJson(),
      };
}

class Metadata {
  MetadataCommissionVariation commissionVariation;
  Pagination pagination;

  Metadata({
    this.commissionVariation,
    this.pagination,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        commissionVariation:
            MetadataCommissionVariation.fromJson(json["commission_variation"]),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "commission_variation": commissionVariation.toJson(),
        "pagination": pagination.toJson(),
      };
}

class MetadataCommissionVariation {
  int days;
  int forTopProgramsNumber;

  MetadataCommissionVariation({
    this.days,
    this.forTopProgramsNumber,
  });

  factory MetadataCommissionVariation.fromJson(Map<String, dynamic> json) =>
      MetadataCommissionVariation(
        days: json["days"],
        forTopProgramsNumber: json["for_top_programs_number"],
      );

  Map<String, dynamic> toJson() => {
        "days": days,
        "for_top_programs_number": forTopProgramsNumber,
      };
}

class Facets {
  Available search;
  Available available;

  Facets({
    this.search,
    this.available,
  });

  factory Facets.fromJson(Map<String, dynamic> json) => Facets(
        search: Available.fromJson(json["search"]),
        available: Available.fromJson(json["available"]),
      );

  Map<String, dynamic> toJson() => {
        "search": search.toJson(),
        "available": available.toJson(),
      };
}

class Available {
  List<CategoryName> status;
  List<CategoryName> categoryName;
  List<CategoryName> countryName;
  List<CategoryName> paymentType;
  List<CategoryName> affrequestStatus;

  Available({
    this.status,
    this.categoryName,
    this.countryName,
    this.paymentType,
    this.affrequestStatus,
  });

  factory Available.fromJson(Map<String, dynamic> json) => Available(
        status: List<CategoryName>.from(
            json["status"].map((x) => CategoryName.fromJson(x))),
        categoryName: List<CategoryName>.from(
            json["category_name"].map((x) => CategoryName.fromJson(x))),
        countryName: List<CategoryName>.from(
            json["country_name"].map((x) => CategoryName.fromJson(x))),
        paymentType: List<CategoryName>.from(
            json["payment_type"].map((x) => CategoryName.fromJson(x))),
        affrequestStatus: json["affrequest_status"] == null
            ? null
            : List<CategoryName>.from(
                json["affrequest_status"].map((x) => CategoryName.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": List<dynamic>.from(status.map((x) => x.toJson())),
        "category_name":
            List<dynamic>.from(categoryName.map((x) => x.toJson())),
        "country_name": List<dynamic>.from(countryName.map((x) => x.toJson())),
        "payment_type": List<dynamic>.from(paymentType.map((x) => x.toJson())),
        "affrequest_status": affrequestStatus == null
            ? null
            : List<dynamic>.from(affrequestStatus.map((x) => x.toJson())),
      };
}

class CategoryName {
  String value;
  int count;

  CategoryName({
    this.value,
    this.count,
  });

  factory CategoryName.fromJson(Map<String, dynamic> json) => CategoryName(
        value: json["value"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "count": count,
      };
}

class Pagination {
  int results;
  int pages;
  int currentPage;

  Pagination({
    this.results,
    this.pages,
    this.currentPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        results: json["results"],
        pages: json["pages"],
        currentPage: json["current_page"],
      );

  Map<String, dynamic> toJson() => {
        "results": results,
        "pages": pages,
        "current_page": currentPage,
      };
}

class Program {
  int id;
  String slug;
  String name;
  String mainUrl;
  String baseUrl;
  DateTime activatedAt;
  int userId;
  String uniqueCode;
  String status;
  int cookieLife;
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
  Affrequest affrequest;
  bool favorited = false;

  Program({
    this.id,
    this.slug,
    this.name,
    this.mainUrl,
    this.baseUrl,
    this.activatedAt,
    this.userId,
    this.uniqueCode,
    this.status,
    this.cookieLife,
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
    this.affrequest,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json["id"],
        slug: json["slug"],
        name: json["name"],
        mainUrl: json["main_url"],
        baseUrl: json["base_url"],
        activatedAt: DateTime.parse(json["activated_at"]),
        userId: json["user_id"],
        uniqueCode: json["unique_code"],
        status: json["status"],
        cookieLife: json["cookie_life"],
        productFeedsCount: json["product_feeds_count"],
        productsCount: json["products_count"],
        bannersCount: json["banners_count"],
        approvalTime: json["approval_time"],
        currency: json["currency"],
        workingCurrencyCode: json["working_currency_code"],
        enableLeads: json["enable_leads"],
        enableSales: json["enable_sales"],
        defaultLeadCommissionAmount: json["default_lead_commission_amount"],
        defaultLeadCommissionType: json["default_lead_commission_type"],
        defaultSaleCommissionRate: json["default_sale_commission_rate"],
        defaultSaleCommissionType: json["default_sale_commission_type"],
        approvedCommissionCountRate: json["approved_commission_count_rate"],
        approvedCommissionAmountRate: json["approved_commission_amount_rate"],
        paymentType: json["payment_type"],
        balanceIndicator: json["balance_indicator"],
        downtime: json["downtime"],
        averagePaymentTime: json["average_payment_time"],
        logoId: json["logo_id"],
        logoPath: json["logo_path"],
        userLogin: json["user_login"],
        category: Category.fromJson(json["category"]),
        sellingCountries: List<SellingCountry>.from(
            json["selling_countries"].map((x) => SellingCountry.fromJson(x))),
        affrequest: Affrequest.fromJson(json["affrequest"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "main_url": mainUrl,
        "base_url": baseUrl,
        "activated_at": activatedAt.toIso8601String(),
        "user_id": userId,
        "unique_code": uniqueCode,
        "status": status,
        "cookie_life": cookieLife,
        "product_feeds_count": productFeedsCount,
        "products_count": productsCount,
        "banners_count": bannersCount,
        "approval_time": approvalTime,
        "currency": currency,
        "working_currency_code": workingCurrencyCode,
        "enable_leads": enableLeads,
        "enable_sales": enableSales,
        "default_lead_commission_amount": defaultLeadCommissionAmount,
        "default_lead_commission_type": defaultLeadCommissionType,
        "default_sale_commission_rate": defaultSaleCommissionRate,
        "default_sale_commission_type": defaultSaleCommissionType,
        "approved_commission_count_rate": approvedCommissionCountRate,
        "approved_commission_amount_rate": approvedCommissionAmountRate,
        "payment_type": paymentType,
        "balance_indicator": balanceIndicator,
        "downtime": downtime,
        "average_payment_time": averagePaymentTime,
        "logo_id": logoId,
        "logo_path": logoPath,
        "user_login": userLogin,
        "category": category.toJson(),
        "selling_countries":
            List<dynamic>.from(sellingCountries.map((x) => x.toJson())),
        "affrequest": affrequest.toJson(),
      };
}

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

  factory Affrequest.fromJson(Map<String, dynamic> json) => Affrequest(
        status: json["status"],
        id: json["id"],
        deleteAt: json["delete_at"],
        suspendAt: json["suspend_at"],
        customConditions: json["custom_conditions"],
        customCookieLife: json["custom_cookie_life"],
        customCommission: json["custom_commission"],
        cookieLife: json["cookie_life"],
        commissionSaleRate: json["commission_sale_rate"],
        commissionLeadAmount: json["commission_lead_amount"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "id": id,
        "delete_at": deleteAt,
        "suspend_at": suspendAt,
        "custom_conditions": customConditions,
        "custom_cookie_life": customCookieLife,
        "custom_commission": customCommission,
        "cookie_life": cookieLife,
        "commission_sale_rate": commissionSaleRate,
        "commission_lead_amount": commissionLeadAmount,
      };
}

class Category {
  String name;
  int id;
  int programsCount;
  int averageApprovalRateAmount;
  int averageApprovalRateCount;
  int oldestPendingCommission;
  double commission;

  Category({
    this.name,
    this.id,
    this.programsCount,
    this.averageApprovalRateAmount,
    this.averageApprovalRateCount,
    this.oldestPendingCommission,
    this.commission,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        id: json["id"],
        programsCount: json["programs_count"],
        averageApprovalRateAmount: json["average_approval_rate_amount"],
        averageApprovalRateCount: json["average_approval_rate_count"],
        oldestPendingCommission: json["oldest_pending_commission"],
        commission: json["commission"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "programs_count": programsCount,
        "average_approval_rate_amount": averageApprovalRateAmount,
        "average_approval_rate_count": averageApprovalRateCount,
        "oldest_pending_commission": oldestPendingCommission,
        "commission": commission,
      };
}

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

  factory SellingCountry.fromJson(Map<String, dynamic> json) => SellingCountry(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "currency": currency,
      };
}
