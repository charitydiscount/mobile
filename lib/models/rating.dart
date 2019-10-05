import 'package:charity_discount/models/user.dart';
import 'package:flutter/material.dart';

class Review {
  final Reviewer reviewer;
  final int rating;
  final String description;
  final DateTime createdAt;

  Review({
    @required this.reviewer,
    @required this.rating,
    @required this.description,
    this.createdAt,
  });

  factory Review.fromJson(Map json) => Review(
        reviewer: Reviewer.fromJson(json['reviewer']),
        rating: json['rating'] ?? 0,
        description: json['description'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'reviewer': reviewer.toJson(),
        'rating': rating,
        'description': description,
        'createdAt': createdAt.toString(),
      };
}

class Reviewer {
  final String userId;
  final String name;
  final String photoUrl;

  Reviewer({this.userId, this.name, this.photoUrl});

  factory Reviewer.fromJson(Map json) => Reviewer(
        userId: json['userId'],
        name: json['name'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
      );

  factory Reviewer.fromUser(User user) => Reviewer(
        userId: user.userId,
        name: '${user.firstName} ${user.lastName}',
        photoUrl: user.photoUrl,
      );

  Map<String, String> toJson() => {
        'userId': userId,
        'name': name,
        'photoUrl': photoUrl,
      };
}
