import 'package:charity_discount/models/localized_text.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable(explicitToJson: true)
class Achievement {
  final String id;
  final String badge;
  final List<AchievementCondition> conditions;
  @JsonKey(fromJson: dateFromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: dateFromJson)
  final DateTime updatedAt;
  final LocalizedText description;
  final LocalizedText name;
  final AchievementReward reward;
  final int order;

  /// Use [AchievementType]
  final String type;
  final int weight;

  String badgeUrl;

  Achievement(
    this.id,
    this.badge,
    this.conditions,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.name,
    this.reward,
    this.type,
    this.weight,
    this.order,
  );

  static DateTime dateFromJson(dynamic json) => jsonToDate(json);

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

@JsonSerializable(createFactory: false)
class AchievementCondition {
  final dynamic target;

  /// Use [AchievementConditionType]
  final String type;
  final String unit;

  AchievementCondition(this.target, this.type, this.unit);

  factory AchievementCondition.fromJson(Map<String, dynamic> json) {
    dynamic target;
    switch (json['type']) {
      case AchievementConditionType.COUNT:
        target = json['target'] as int;
        break;
      case AchievementConditionType.EXACT_DATE:
      case AchievementConditionType.UNTIL_DATE:
        final format = new DateFormat('dd-mm-yyyy');
        try {
          target = format.parse(json['target']);
        } catch (e) {
          print((e as FormatException).message);
        }
        break;
      default:
    }
    return AchievementCondition(
      target,
      json['type'] as String,
      json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() => _$AchievementConditionToJson(this);
}

abstract class AchievementConditionType {
  static const COUNT = 'count';
  static const EXACT_DATE = 'exactDate';
  static const UNTIL_DATE = 'untilDate';
}

@JsonSerializable()
class AchievementReward {
  final int amount;
  final String unit;

  AchievementReward(this.amount, this.unit);

  factory AchievementReward.fromJson(Map<String, dynamic> json) =>
      _$AchievementRewardFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementRewardToJson(this);
}

abstract class AchievementType {
  static const COMMISSION_PAID = 'commission-paid';
  static const COMMISSION_PENDING = 'commission-pending';
  static const CLICK = 'click';
  static const DONATION = 'donation';
  static const CASHOUT = 'cashout';
  static const REVIEW = 'review';
  static const INVITE = 'invite';
  static const FAVORITE = 'favorite';
}

abstract class AchievementConditionUnit {
  static const SHOP = 'shop';
}
