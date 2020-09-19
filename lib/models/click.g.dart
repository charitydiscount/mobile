// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'click.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClickInfo _$ClickInfoFromJson(Map<String, dynamic> json) {
  return ClickInfo(
    json['userId'] as String,
    json['ipAddress'] as String,
    json['ipv6Address'] as String,
    json['programId'] as String,
    ClickInfo.dateFromJson(json['createdAt']),
  );
}

Map<String, dynamic> _$ClickInfoToJson(ClickInfo instance) => <String, dynamic>{
      'userId': instance.userId,
      'ipAddress': instance.ipAddress,
      'ipv6Address': instance.ipv6Address,
      'programId': instance.programId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
