// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAchievement _$UserAchievementFromJson(Map<String, dynamic> json) {
  return UserAchievement(
    json['achievement'] == null
        ? null
        : Achievement.fromJson(json['achievement'] as Map<String, dynamic>),
    json['currentCount'] as int,
    UserAchievement.dateFromJson(json['achievedAt']),
    json['achieved'] as bool,
  );
}

Map<String, dynamic> _$UserAchievementToJson(UserAchievement instance) =>
    <String, dynamic>{
      'achievement': instance.achievement?.toJson(),
      'currentCount': instance.currentCount,
      'achieved': instance.achieved,
      'achievedAt': instance.achievedAt?.toIso8601String(),
    };
