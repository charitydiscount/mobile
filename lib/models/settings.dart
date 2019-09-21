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
  String lang;
  bool notifications = false;

  Settings({this.lang});

  factory Settings.fromJson(Map<String, dynamic> json) =>
      Settings(lang: json["lang"]);

  Map<String, dynamic> toJson() => {"lang": lang};

  factory Settings.fromDocument(DocumentSnapshot doc) {
    return Settings.fromJson(doc.data);
  }
}
