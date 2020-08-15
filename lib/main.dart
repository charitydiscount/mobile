import 'dart:io';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/services/analytics.dart';
import 'package:charity_discount/ui/app/welcome.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charity_discount/ui/app/theme.dart';
import 'package:charity_discount/ui/app/home.dart';
import 'package:charity_discount/ui/user/sign_in.dart';
import 'package:charity_discount/ui/user/sign_up.dart';
import 'package:charity_discount/ui/user/forgot_password.dart';
import 'package:charity_discount/state/state_model.dart';

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
    _initDynamicLinks();
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
    var currentLocale = EasyLocalization.of(context).locale;

    if (currentLocale != null) {
      return _buildMain(
        context: context,
        locale: currentLocale,
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
          return WelcomeScreen();
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
                return AppLoading(child: loading);
              }
              if (snapshot.data == true) {
                return AppLoading(child: buildLoading(context));
              }
              return HomeScreen(initialScreen: initialScreen);
            },
          );
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.pushNamedAndRemoveUntil(
              context, '/signin', (r) => false),
        );

        return AppLoading(child: buildLoading(context));
      },
    );
  }

  Widget _buildMain({BuildContext context, Locale locale}) {
    var state = AppModel.of(context);
    var theme = buildTheme(dark: state.settings.theme == ThemeOption.DARK);

    bool isDark = state.settings.theme == ThemeOption.DARK;
    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: theme.primaryColor)
          : SystemUiOverlayStyle.light
              .copyWith(statusBarColor: theme.primaryColor),
    );

    return MaterialApp(
      title: 'CharityDiscount',
      theme: theme,
      darkTheme: buildTheme(dark: state.settings.theme != ThemeOption.LIGHT),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        EasyLocalization.of(context).delegate,
      ],
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      locale: locale,
      initialRoute: '/',
      routes: {
        '/': (context) => SafeArea(
              child: _buildDefaultWidget(),
              top: false,
            ),
        '/signin': (context) => SafeArea(
              child: SignInScreen(),
              top: false,
            ),
        '/signup': (context) => SafeArea(
              child: SignUpScreen(),
              top: false,
            ),
        '/forgot-password': (context) => SafeArea(
              child: ForgotPasswordScreen(),
              top: false,
            ),
        '/wallet': (context) => SafeArea(
              child: _buildDefaultWidget(initialScreen: 3),
              top: false,
            ),
      },
      navigatorKey: state.navigatorKey,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => UndefinedView(
          name: settings.name,
        ),
      ),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }

  void _initDynamicLinks() {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        return _handleDeepLinks(dynamicLink?.link);
      },
      onError: (OnLinkErrorException e) async {
        print(e.message);
      },
    );
  }

  void _handleDeepLinks(Uri deepLink) {
    if (deepLink == null) {
      return;
    }

    switch (deepLink.pathSegments.first) {
      case 'referral':
        AppModel.of(context).setReferralCode(deepLink.pathSegments.last);
        break;
      default:
    }
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Image.asset(
            'assets/images/splashscreen.png',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          child,
        ],
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
      path: 'assets/i18n',
      supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
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
