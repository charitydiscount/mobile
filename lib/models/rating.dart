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
  @JsonKey(fromJson: createdAtFromJson)
  final DateTime createdAt;

  Review({
    @required this.reviewer,
    @required this.rating,
    @required this.description,
    this.createdAt,
  });

  factory Review.fromJson(Map json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  static DateTime createdAtFromJson(dynamic json) =>
      json is Timestamp ? json.toDate() : DateTime.parse(json);
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

  Map<String, dynamic> toJson() => _$ReviewerToJson(this);
}
