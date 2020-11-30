import 'package:charity_discount/models/localized_text.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';

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

Future<SupportedLanguage> getDefaultLanguage() async {
  String deviceLocale = await Devicelocale.currentLocale;
  List<String> localeTokens = deviceLocale.split(RegExp(r'[_\-]+'));
  return supportedLanguages.firstWhere(
    (l) => l.code == localeTokens[0],
    orElse: () => supportedLanguages.first,
  );
}

String getLocalizedText(Locale locale, LocalizedText localizedText) {
  switch (locale.languageCode) {
    case 'en':
      return localizedText.en;
    case 'ro':
      return localizedText.ro;
    default:
      return localizedText.ro;
  }
}
