import 'dart:convert';

Promotions promotionsFromJson(String str) =>
    Promotions.fromJson(json.decode(str));

String promotionsToJson(Promotions data) => json.encode(data.toJson());

class Promotions {
  Facets facets;
  Pagination pagination;
  List<AdvertiserPromotion> advertiserPromotions;
  List<dynamic> shoppingEvents;

  Promotions({
    this.facets,
    this.pagination,
    this.advertiserPromotions,
    this.shoppingEvents,
  });

  factory Promotions.fromJson(Map<String, dynamic> json) => new Promotions(
        facets: Facets.fromJson(json["facets"]),
        pagination: Pagination.fromJson(json["pagination"]),
        advertiserPromotions: new List<AdvertiserPromotion>.from(
            json["advertiser_promotions"]
                .map((x) => AdvertiserPromotion.fromJson(x))),
        shoppingEvents:
            new List<dynamic>.from(json["shopping_events"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "facets": facets.toJson(),
        "pagination": pagination.toJson(),
        "advertiser_promotions":
            new List<dynamic>.from(advertiserPromotions.map((x) => x.toJson())),
        "shopping_events": new List<dynamic>.from(shoppingEvents.map((x) => x)),
      };
}

class AdvertiserPromotion {
  int id;
  String name;
  String description;
  DateTime promotionStart;
  DateTime promotionEnd;
  String landingPageLink;
  bool affiliateChallenge;
  bool affiliateBonus;
  bool banners;
  dynamic productFeeds;
  Status status;
  int campaignId;
  dynamic shoppingEventId;
  dynamic shoppingEventName;
  Name campaignName;
  AffrequestStatusEnum affrequestStatus;
  String campaignLogo;
  Slug campaignSlug;
  Program program;
  List<dynamic> linkedFeeds;

  AdvertiserPromotion({
    this.id,
    this.name,
    this.description,
    this.promotionStart,
    this.promotionEnd,
    this.landingPageLink,
    this.affiliateChallenge,
    this.affiliateBonus,
    this.banners,
    this.productFeeds,
    this.status,
    this.campaignId,
    this.shoppingEventId,
    this.shoppingEventName,
    this.campaignName,
    this.affrequestStatus,
    this.campaignLogo,
    this.campaignSlug,
    this.program,
    this.linkedFeeds,
  });

  factory AdvertiserPromotion.fromJson(Map<String, dynamic> json) =>
      new AdvertiserPromotion(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        promotionStart: DateTime.parse(json["promotion_start"]),
        promotionEnd: DateTime.parse(json["promotion_end"]),
        landingPageLink: json["landing_page_link"],
        affiliateChallenge: json["affiliate_challenge"] == null
            ? null
            : json["affiliate_challenge"],
        affiliateBonus:
            json["affiliate_bonus"] == null ? null : json["affiliate_bonus"],
        banners: json["banners"] == null ? null : json["banners"],
        productFeeds: json["product_feeds"],
        status: statusValues.map[json["status"]],
        campaignId: json["campaign_id"],
        shoppingEventId: json["shopping_event_id"],
        shoppingEventName: json["shopping_event_name"],
        campaignName: nameValues.map[json["campaign_name"]],
        affrequestStatus:
            affrequestStatusEnumValues.map[json["affrequest_status"]],
        campaignLogo: json["campaign_logo"],
        campaignSlug: slugValues.map[json["campaign_slug"]],
        program: Program.fromJson(json["program"]),
        linkedFeeds: new List<dynamic>.from(json["linked_feeds"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "promotion_start": promotionStart.toIso8601String(),
        "promotion_end": promotionEnd.toIso8601String(),
        "landing_page_link": landingPageLink,
        "affiliate_challenge":
            affiliateChallenge == null ? null : affiliateChallenge,
        "affiliate_bonus": affiliateBonus == null ? null : affiliateBonus,
        "banners": banners == null ? null : banners,
        "product_feeds": productFeeds,
        "status": statusValues.reverse[status],
        "campaign_id": campaignId,
        "shopping_event_id": shoppingEventId,
        "shopping_event_name": shoppingEventName,
        "campaign_name": nameValues.reverse[campaignName],
        "affrequest_status":
            affrequestStatusEnumValues.reverse[affrequestStatus],
        "campaign_logo": campaignLogo,
        "campaign_slug": slugValues.reverse[campaignSlug],
        "program": program.toJson(),
        "linked_feeds": new List<dynamic>.from(linkedFeeds.map((x) => x)),
      };
}

enum AffrequestStatusEnum { NOT_APPLIED }

final affrequestStatusEnumValues =
    new EnumValues({"not_applied": AffrequestStatusEnum.NOT_APPLIED});

enum Name { BRASTY_RO, LOVEISLAND_RO, IUBA_RO, LAVANDIERE_RO }

final nameValues = new EnumValues({
  "brasty.ro": Name.BRASTY_RO,
  "iuba.ro": Name.IUBA_RO,
  "lavandiere.ro": Name.LAVANDIERE_RO,
  "loveisland.ro": Name.LOVEISLAND_RO
});

enum Slug { BRASTY_RO, LOVEISLAND_RO, IUBA_RO, LAVANDIERE_RO }

final slugValues = new EnumValues({
  "brasty-ro": Slug.BRASTY_RO,
  "iuba-ro": Slug.IUBA_RO,
  "lavandiere-ro": Slug.LAVANDIERE_RO,
  "loveisland-ro": Slug.LOVEISLAND_RO
});

class Program {
  int id;
  Name name;
  Slug slug;

  Program({
    this.id,
    this.name,
    this.slug,
  });

  factory Program.fromJson(Map<String, dynamic> json) => new Program(
        id: json["id"],
        name: nameValues.map[json["name"]],
        slug: slugValues.map[json["slug"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": nameValues.reverse[name],
        "slug": slugValues.reverse[slug],
      };
}

enum Status { PUBLISHED }

final statusValues = new EnumValues({"published": Status.PUBLISHED});

class Facets {
  Available available;

  Facets({
    this.available,
  });

  factory Facets.fromJson(Map<String, dynamic> json) => new Facets(
        available: Available.fromJson(json["available"]),
      );

  Map<String, dynamic> toJson() => {
        "available": available.toJson(),
      };
}

class Available {
  List<AffrequestStatusElement> affrequestStatus;

  Available({
    this.affrequestStatus,
  });

  factory Available.fromJson(Map<String, dynamic> json) => new Available(
        affrequestStatus: new List<AffrequestStatusElement>.from(
            json["affrequest_status"]
                .map((x) => AffrequestStatusElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "affrequest_status":
            new List<dynamic>.from(affrequestStatus.map((x) => x.toJson())),
      };
}

class AffrequestStatusElement {
  String value;
  int count;

  AffrequestStatusElement({
    this.value,
    this.count,
  });

  factory AffrequestStatusElement.fromJson(Map<String, dynamic> json) =>
      new AffrequestStatusElement(
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

  factory Pagination.fromJson(Map<String, dynamic> json) => new Pagination(
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

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
