import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData buildTheme({bool dark = false}) {
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith();
  }

  final ThemeData base = dark ? ThemeData.dark() : ThemeData.light();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: const Color(0xFFE32029),
    statusBarBrightness: base.brightness,
  ));

  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme),
    primaryColor: const Color(0xFFE32029),
    accentColor: const Color(0xFFA80000),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: const Color(0xFFA80000),
      foregroundColor: Colors.white,
    ),
  );
}
