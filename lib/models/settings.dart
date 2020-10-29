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
  bool notificationsForCashback = true;
  bool notificationsForPromotions = true;
  bool notificationsEmail = false;
  DisplayMode displayMode = DisplayMode.LIST;
  ThemeOption theme;

  Settings({
    this.notificationsForCashback,
    this.notificationsForPromotions,
    this.notificationsEmail,
    this.displayMode,
    this.theme = ThemeOption.LIGHT,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        notificationsForCashback: json['notifications'] ?? true,
        notificationsForPromotions: json['notificationsForPromotions'] ?? true,
        notificationsEmail: json['notificationsEmail'] ?? false,
        displayMode: displayModeFromString(
          json['displayMode'] ?? DisplayMode.LIST.toString(),
        ),
        theme: json['theme'] != null
            ? themeOptionFromString(json['theme'])
            : ThemeOption.SYSTEM,
      );

  Map<String, dynamic> toJson() => {
        'notifications': notificationsForCashback,
        'notificationsForPromotions': notificationsForPromotions,
        'notificationsEmail': notificationsEmail,
        'displayMode': displayMode.toString(),
        'theme': theme.toString(),
      };

  factory Settings.fromDocument(DocumentSnapshot doc) {
    return Settings.fromJson(doc.data());
  }
}

enum ThemeOption {
  SYSTEM,
  LIGHT,
  DARK,
}

ThemeOption themeOptionFromString(String themeString) {
  return ThemeOption.values.firstWhere(
    (f) => f.toString() == themeString,
    orElse: () => null,
  );
}
