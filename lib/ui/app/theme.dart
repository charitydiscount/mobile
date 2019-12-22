import 'package:flutter/material.dart';

ThemeData buildTheme({bool dark = false}) {
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        color: dark ? Colors.grey.shade100 : Colors.grey.shade700,
      ),
      title: base.title.copyWith(
        color: dark ? Colors.grey.shade100 : Colors.grey.shade700,
      ),
    );
  }

  final ThemeData base = dark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme),
    primaryColor: const Color(0xFFE32029),
    accentColor: const Color(0xFFA80000),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: const Color(0xFFA80000),
        foregroundColor: Colors.white),
  );
}
