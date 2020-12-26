import 'package:json_annotation/json_annotation.dart';

part 'change.g.dart';

@JsonSerializable(explicitToJson: true)
class ChangeTracking {
  DateTime privateNameChangedAt;
  DateTime privatePhotoChangedAt;
  DateTime newsletterChangedAt;

  ChangeTracking({
    this.privateNameChangedAt,
    this.privatePhotoChangedAt,
    this.newsletterChangedAt,
  });

  factory ChangeTracking.fromJson(Map<String, dynamic> json) =>
      _$ChangeTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeTrackingToJson(this);
}
