import 'package:charity_discount/models/achievement.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_achievement.g.dart';

@JsonSerializable(explicitToJson: true)
class UserAchievement {
  final Achievement achievement;
  final int currentCount;
  final bool achieved;
  @JsonKey(fromJson: dateFromJson)
  final DateTime achievedAt;

  UserAchievement(
      this.achievement, this.currentCount, this.achievedAt, this.achieved);

  static DateTime dateFromJson(dynamic json) => jsonToDate(json);

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);
}
