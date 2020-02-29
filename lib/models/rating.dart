import 'package:charity_discount/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable()
class Review {
  final Reviewer reviewer;
  final int rating;
  final String description;
  @JsonKey(fromJson: createdAtfromJson)
  final DateTime createdAt;

  Review({
    @required this.reviewer,
    @required this.rating,
    @required this.description,
    this.createdAt,
  });

  factory Review.fromJson(Map json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  static DateTime createdAtfromJson(dynamic json) =>
      json['createdAt'] is Timestamp
          ? json['createdAt'].toDate()
          : DateTime.parse(json['createdAt']);
}

@JsonSerializable()
class Reviewer {
  final String userId;
  final String name;
  final String photoUrl;

  Reviewer({this.userId, this.name, this.photoUrl});

  factory Reviewer.fromJson(Map json) => _$ReviewerFromJson(json);

  factory Reviewer.fromUser(User user) => Reviewer(
        userId: user.userId,
        name: user.name,
        photoUrl: user.photoUrl,
      );

  Map<String, String> toJson() => _$ReviewerToJson(this);
}
