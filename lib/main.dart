import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/util/message_handler.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charity_discount/ui/app/theme.dart';
import 'package:charity_discount/ui/app/home.dart';
import 'package:charity_discount/ui/user/sign_in.dart';
import 'package:charity_discount/ui/user/sign_up.dart';
import 'package:charity_discount/ui/user/forgot_password.dart';
import 'package:charity_discount/ui/app/intro.dart';
import 'package:charity_discount/state/state_model.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;

    if (data.savedLocale != null) {
      return _buildMain(
        context: context,
        locale: data.savedLocale,
      );
    } else {
      return FutureBuilder(
        future: getDefaultLanguage(),
        builder: (context, snapshot) {
          var loading = buildConnectionLoading(
            context: context,
            snapshot: snapshot,
          );
          if (loading != null) {
            return loading;
          }

          return _buildMain(
            context: context,
            locale: snapshot.data.locale,
          );
        },
      );
    }
  }

  Widget _buildMain({BuildContext context, Locale locale}) {
    Widget defaultWidget = ScopedModelDescendant<AppModel>(
      builder: (context, child, appModel) {
        if (appModel.introCompleted == false) {
          return Intro();
        }
        if (appModel.user != null && appModel.user.userId != null) {
          return MessageHandler(
            child: StreamBuilder<bool>(
              stream: AppModel.of(context).loading,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Container());
                }
                return HomeScreen();
              },
            ),
          );
        }

        return SignInScreen();
      },
    );

    return EasyLocalizationProvider(
      data: EasyLocalizationProvider.of(context).data,
      child: MaterialApp(
        title: 'CharityDiscount',
        theme: buildTheme(),
        darkTheme: buildTheme(dark: true),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          EasylocaLizationDelegate(
            locale: locale,
            path: 'assets/i18n',
          ),
        ],
        supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
        locale: locale,
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
