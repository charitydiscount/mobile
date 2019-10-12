import 'package:charity_discount/util/locale.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charity_discount/ui/theme.dart';
import 'package:charity_discount/ui/screens/home.dart';
import 'package:charity_discount/ui/screens/sign_in.dart';
import 'package:charity_discount/ui/screens/sign_up.dart';
import 'package:charity_discount/ui/screens/forgot_password.dart';
import 'package:charity_discount/ui/screens/intro.dart';
import 'package:charity_discount/state/state_model.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;

    Widget defaultWidget = ScopedModelDescendant<AppModel>(
      builder: (context, child, appModel) {
        if (appModel.introCompleted == false) {
          return Intro();
        }
        if (appModel.user != null && appModel.user.userId != null) {
          return HomeScreen();
        }

        return SignInScreen();
      },
    );

    var defaultLocale = data.savedLocale ?? getDefaultLanguage().locale;

    return EasyLocalizationProvider(
      data: data,
      child: MaterialApp(
        title: 'Charity Discount',
        theme: buildTheme(),
        darkTheme: buildTheme(dark: true),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          EasylocaLizationDelegate(
            locale: defaultLocale,
            path: 'assets/i18n',
          ),
        ],
        supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
        locale: defaultLocale,
        routes: {
          '/': (context) => SafeArea(child: defaultWidget),
          '/signin': (context) => SafeArea(child: SignInScreen()),
          '/signup': (context) => SafeArea(child: SignUpScreen()),
          '/forgot-password': (context) =>
              SafeArea(child: ForgotPasswordScreen()),
        },
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EasyLocalization(
      child: ScopedModel(
        model: AppModel(),
        child: Main(),
      ),
    ),
  );
}
