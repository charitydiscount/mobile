import 'package:charity_discount/util/tools.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard.g.dart';

@JsonSerializable(explicitToJson: true)
class LeaderboardEntry {
  final String userId;
  final String name;
  final String photoUrl;
  final double points;
  @JsonKey(fromJson: dateFromJson)
  final DateTime updatedAt;
  final bool isStaff;
  final int achievementsCount;
  final bool anonym;

  LeaderboardEntry(
    this.userId,
    this.name,
    this.photoUrl,
    this.points,
    this.updatedAt,
    this.isStaff,
    this.achievementsCount,
    this.anonym,
  );

  static DateTime dateFromJson(dynamic json) => jsonToDate(json);

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}
