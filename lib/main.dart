import 'dart:io';
import 'package:charity_discount/app.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/util/http.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charity_discount/state/state_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = CustomHttpOverrides();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  setupServices();

  runApp(
    EasyLocalization(
      path: 'assets/i18n',
      supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
      child: ScopedModel(
        model: locator<AppModel>(),
        child: ScreenUtilInit(
          designSize: Size(750, 1334),
          builder: () => Main(),
        ),
      ),
    ),
  );
}
