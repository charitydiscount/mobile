import 'package:charity_discount/models/commission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral.g.dart';

@JsonSerializable()
class Referral {
  final String ownerId;
  final String userId;
  final String name;
  final String photoUrl;
  @JsonKey(
    fromJson: createdAtFromJson,
    toJson: createdAtToJson,
  )
  final DateTime createdAt;
  @JsonKey(ignore: true)
  List<Commission> commissions;

  Referral({
    this.ownerId,
    this.userId,
    this.name,
    this.photoUrl,
    this.createdAt,
  });

  void setCommissions(List<Commission> commissions) {
    this.commissions = commissions;
  }

  static DateTime createdAtFromJson(dynamic json) {
    return (json as Timestamp).toDate();
  }

  static String createdAtToJson(DateTime createdAt) {
    return Timestamp.fromDate(createdAt).toString();
  }

  factory Referral.fromJson(Map<String, dynamic> json) =>
      _$ReferralFromJson(Map.from(json));

  Map<String, dynamic> toJson() => _$ReferralToJson(this);
}

const SOURCE = 'referral';
