import 'dart:io';
import 'package:charity_discount/app.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/http.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = CustomHttpOverrides();
  await Firebase.initializeApp();

  String host = Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
  FirebaseFirestore.instance.settings = Settings(
    host: host,
    sslEnabled: false,
    persistenceEnabled: false,
  );

  setupTestLocator();

  runApp(
    EasyLocalization(
      path: 'assets/i18n',
      supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
      child: ScopedModel(
        model: locator<AppModel>(),
        child: ScreenUtilInit(
          designSize: Size(750, 1334),
          allowFontScaling: false,
          child: Main(),
        ),
      ),
    ),
  );
}
