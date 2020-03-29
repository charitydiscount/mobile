// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Referral _$ReferralFromJson(Map<String, dynamic> json) {
  return Referral(
    ownerId: json['ownerId'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    photoUrl: json['photoUrl'] as String,
    createdAt: Referral.createdAtFromJson(json['createdAt']),
  );
}

Map<String, dynamic> _$ReferralToJson(Referral instance) => <String, dynamic>{
      'ownerId': instance.ownerId,
      'userId': instance.userId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'createdAt': Referral.createdAtToJson(instance.createdAt),
    };
