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

enum DisplayMode { LIST, GRID }

DisplayMode displayModeFromString(String displayModeString) {
  return DisplayMode.values.firstWhere(
    (f) => f.toString() == displayModeString,
    orElse: () => null,
  );
}

class Settings {
  String lang;
  bool notifications = true;
  DisplayMode displayMode = DisplayMode.LIST;

  Settings({this.lang, this.notifications, this.displayMode});

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        lang: json['lang'] ?? 'en',
        notifications: json['notifications'] ?? true,
        displayMode: displayModeFromString(
          json['displayMode'] ?? DisplayMode.LIST.toString(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'notifications': notifications,
        'displayMode': displayMode.toString(),
      };

  factory Settings.fromDocument(DocumentSnapshot doc) {
    return Settings.fromJson(doc.data);
  }
}
