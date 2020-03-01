// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return Review(
    reviewer: json['reviewer'] == null
        ? null
        : Reviewer.fromJson(json['reviewer'] as Map<String, dynamic>),
    rating: json['rating'] as int,
    description: json['description'] as String,
    createdAt: Review.createdAtFromJson(json['createdAt']),
  );
}

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'reviewer': instance.reviewer,
      'rating': instance.rating,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

Reviewer _$ReviewerFromJson(Map<String, dynamic> json) {
  return Reviewer(
    userId: json['userId'] as String,
    name: json['name'] as String,
    photoUrl: json['photoUrl'] as String,
  );
}

Map<String, dynamic> _$ReviewerToJson(Reviewer instance) => <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
    };
