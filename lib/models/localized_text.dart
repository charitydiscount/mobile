import 'package:json_annotation/json_annotation.dart';

part 'localized_text.g.dart';

@JsonSerializable()
class LocalizedText {
  final String en;
  final String ro;

  LocalizedText(this.en, this.ro);

  factory LocalizedText.fromJson(Map<String, dynamic> json) => _$LocalizedTextFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);
}
