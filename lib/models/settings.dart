import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

Settings settingsFromJson(String str) {
  final jsonData = json.decode(str);
  return Settings.fromJson(jsonData);
}

String settingsToJson(Settings data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Settings {
  String userId;

  Settings({
    this.userId,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => new Settings(
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
      };

  factory Settings.fromDocument(DocumentSnapshot doc) {
    return Settings.fromJson(doc.data);
  }
}
