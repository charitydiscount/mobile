// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return UserProfile(
    userId: json['userId'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    photoUrl: json['photoUrl'] as String,
    privateName: json['privateName'] as bool ?? false,
    privatePhoto: json['privatePhoto'] as bool ?? false,
  );
}

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'privateName': instance.privateName,
      'privatePhoto': instance.privatePhoto,
    };
