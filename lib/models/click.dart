import 'package:charity_discount/util/tools.dart';
import 'package:json_annotation/json_annotation.dart';

part 'click.g.dart';

@JsonSerializable(explicitToJson: true)
class ClickInfo {
  final String userId;
  final String ipAddress;
  final String ipv6Address;
  final String programId;
  @JsonKey(fromJson: dateFromJson)
  final DateTime createdAt;

  ClickInfo(
    this.userId,
    this.ipAddress,
    this.ipv6Address,
    this.programId,
    this.createdAt,
  );

  factory ClickInfo.fromJson(Map<String, dynamic> json) =>
      _$ClickInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClickInfoToJson(this);

  static DateTime dateFromJson(dynamic json) => jsonToDate(json);
}
