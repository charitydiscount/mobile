import 'dart:io';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

final FirebaseAnalytics analytics = FirebaseAnalytics();

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  ThemeOption _theme;

  @override
  void initState() {
    super.initState();

    final state = AppModel.of(context);
    state.addListener(() {
      if (state.settings.theme != _theme) {
        setState(() {
          _theme = state.settings.theme;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;

    if (data.locale != null) {
      return _buildMain(
        context: context,
        locale: data.locale,
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

  Widget _buildDefaultWidget({int initialScreen = 0}) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, appModel) {
        if (appModel.introCompleted == false) {
          return Intro();
        }

        if (appModel.user != null && appModel.user.userId != null) {
          return StreamBuilder<bool>(
            stream: AppModel.of(context).loading,
            builder: (context, snapshot) {
              final loading = buildConnectionLoading(
                context: context,
                snapshot: snapshot,
              );
              if (loading != null) {
                return Scaffold(
                  body: Stack(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/splashscreen.png',
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      loading,
                    ],
                  ),
                );
              }
              return HomeScreen(initialScreen: initialScreen);
            },
          );
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.pushNamedAndRemoveUntil(
              context, '/signin', (r) => false),
        );

        return Scaffold(
          body: Stack(
            children: <Widget>[
              Image.asset(
                'assets/images/splashscreen.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              buildLoading(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMain({BuildContext context, Locale locale}) {
    var state = AppModel.of(context);
    return EasyLocalizationProvider(
      data: EasyLocalizationProvider.of(context).data,
      child: MaterialApp(
        title: 'CharityDiscount',
        theme: buildTheme(dark: state.settings.theme == ThemeOption.DARK),
        darkTheme: buildTheme(dark: state.settings.theme != ThemeOption.LIGHT),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          EasyLocalizationDelegate(
            locale: locale,
            path: 'assets/i18n',
          ),
        ],
        supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
        locale: locale,
        initialRoute: '/',
        routes: {
          '/': (context) => SafeArea(child: _buildDefaultWidget()),
          '/signin': (context) => SafeArea(child: SignInScreen()),
          '/signup': (context) => SafeArea(child: SignUpScreen()),
          '/forgot-password': (context) =>
              SafeArea(child: ForgotPasswordScreen()),
          '/wallet': (context) =>
              SafeArea(child: _buildDefaultWidget(initialScreen: 3)),
        },
        navigatorKey: state.navigatorKey,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => UndefinedView(
            name: settings.name,
          ),
        ),
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = CustomHttpOverrides();
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(
    EasyLocalization(
      child: ScopedModel(
        model: AppModel(),
        child: Main(),
      ),
    ),
  );
}

class UndefinedView extends StatelessWidget {
  final String name;
  const UndefinedView({Key key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Route for $name is not defined'),
      ),
    );
  }
}

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
