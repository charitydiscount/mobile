// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return LeaderboardEntry(
    json['userId'] as String,
    json['name'] as String,
    json['photoUrl'] as String,
    (json['points'] as num)?.toDouble(),
    LeaderboardEntry.dateFromJson(json['updatedAt']),
    json['isStaff'] as bool,
    json['achievementsCount'] as int,
    json['anonym'] as bool,
  );
}

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'points': instance.points,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isStaff': instance.isStaff,
      'achievementsCount': instance.achievementsCount,
      'anonym': instance.anonym,
    };
