import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String photoUrl;
  @JsonKey(defaultValue: false)
  final bool privateName;
  @JsonKey(defaultValue: false)
  final bool privatePhoto;

  UserProfile({
    this.userId,
    this.name,
    this.email,
    this.photoUrl,
    this.privateName,
    this.privatePhoto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
