import 'package:charity_discount/models/localized_text.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable(explicitToJson: true)
class Achievement {
  final String badgeUrl;
  final List<AchievementCondition> conditions;
  @JsonKey(fromJson: dateFromJson)
  final DateTime createdAt;
  final LocalizedText description;
  final LocalizedText name;
  final AchievementReward reward;

  /// Use [AchievementType]
  final String type;
  final String weight;

  Achievement(
    this.badgeUrl,
    this.conditions,
    this.createdAt,
    this.description,
    this.name,
    this.reward,
    this.type,
    this.weight,
  );

  static DateTime dateFromJson(dynamic json) => jsonToDate(json);

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

@JsonSerializable()
class AchievementCondition {
  final String target;

  /// Use [AchievementConditionType]
  final String type;
  final String unit;

  AchievementCondition(this.target, this.type, this.unit);

  factory AchievementCondition.fromJson(Map<String, dynamic> json) => _$AchievementConditionFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementConditionToJson(this);
}

abstract class AchievementConditionType {
  static const COUNT = 'count';
  static const EXACT_DATE = 'exactDate';
  static const UNTIL_DATE = 'untilDate';
}

@JsonSerializable()
class AchievementReward {
  final String amount;
  final String unit;

  AchievementReward(this.amount, this.unit);

  factory AchievementReward.fromJson(Map<String, dynamic> json) => _$AchievementRewardFromJson(json);

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
