import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SupportedLanguage {
  final String name;
  final String code;
  final String countryCode;
  final String iconPath;

  SupportedLanguage(this.name, this.code, this.countryCode, this.iconPath);

  Locale get locale => Locale(code, countryCode);
}

List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage('Română', 'ro', 'RO', 'assets/icons/ro.svg'),
  SupportedLanguage('English', 'en', 'US', 'assets/icons/us.svg'),
];

SupportedLanguage getDefaultLanguage() {
  return supportedLanguages.firstWhere(
      (l) => l.code == ui.window.locale?.languageCode,
      orElse: () => supportedLanguages.first);
}
