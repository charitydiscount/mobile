// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return Achievement(
    json['badgeUrl'] as String,
    (json['conditions'] as List)
        ?.map((e) => e == null
            ? null
            : AchievementCondition.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    Achievement.dateFromJson(json['createdAt']),
    json['description'] == null
        ? null
        : LocalizedText.fromJson(json['description'] as Map<String, dynamic>),
    json['name'] == null
        ? null
        : LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    json['reward'] == null
        ? null
        : AchievementReward.fromJson(json['reward'] as Map<String, dynamic>),
    json['type'] as String,
    json['weight'] as String,
  );
}

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'badgeUrl': instance.badgeUrl,
      'conditions': instance.conditions?.map((e) => e?.toJson())?.toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'description': instance.description?.toJson(),
      'name': instance.name?.toJson(),
      'reward': instance.reward?.toJson(),
      'type': instance.type,
      'weight': instance.weight,
    };

AchievementCondition _$AchievementConditionFromJson(Map<String, dynamic> json) {
  return AchievementCondition(
    json['target'] as String,
    json['type'] as String,
    json['unit'] as String,
  );
}

Map<String, dynamic> _$AchievementConditionToJson(
        AchievementCondition instance) =>
    <String, dynamic>{
      'target': instance.target,
      'type': instance.type,
      'unit': instance.unit,
    };

AchievementReward _$AchievementRewardFromJson(Map<String, dynamic> json) {
  return AchievementReward(
    json['amount'] as String,
    json['unit'] as String,
  );
}

Map<String, dynamic> _$AchievementRewardToJson(AchievementReward instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'unit': instance.unit,
    };
