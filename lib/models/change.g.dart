// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeTracking _$ChangeTrackingFromJson(Map<String, dynamic> json) {
  return ChangeTracking(
    privateNameChangedAt: json['privateNameChangedAt'] == null
        ? null
        : DateTime.parse(json['privateNameChangedAt'] as String),
    privatePhotoChangedAt: json['privatePhotoChangedAt'] == null
        ? null
        : DateTime.parse(json['privatePhotoChangedAt'] as String),
    newsletterChangedAt: json['newsletterChangedAt'] == null
        ? null
        : DateTime.parse(json['newsletterChangedAt'] as String),
  );
}

Map<String, dynamic> _$ChangeTrackingToJson(ChangeTracking instance) =>
    <String, dynamic>{
      'privateNameChangedAt': instance.privateNameChangedAt?.toIso8601String(),
      'privatePhotoChangedAt':
          instance.privatePhotoChangedAt?.toIso8601String(),
      'newsletterChangedAt': instance.newsletterChangedAt?.toIso8601String(),
    };
