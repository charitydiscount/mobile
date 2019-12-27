import 'dart:async';
import 'dart:io';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flushbar/flushbar.dart';
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
  StreamSubscription _iosSubscription;

  @override
  void initState() {
    super.initState();

    final state = AppModel.of(context);
    if (state.isNewDevice) {
      if (Platform.isIOS) {
        _iosSubscription = fcm.onIosSettingsRegistered.listen((data) {
          _registerFcmToken();
        });
        fcm.requestNotificationPermissions();
      } else {
        _registerFcmToken();
      }
      state.setKnownDevice();
    }

    if (state.settings.notifications) {
      fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (mounted) {
            Flushbar(
              title: message['notification']['title'],
              message: message['notification']['body'],
            )?.show(context);
          }
        },
        onLaunch: _handleBackgroundNotification,
        onResume: _handleBackgroundNotification,
      );
    }
  }

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
                return loading;
              }
              return HomeScreen(initialScreen: initialScreen);
            },
          );
        }

        return SignInScreen();
      },
    );
  }

  Widget _buildMain({BuildContext context, Locale locale}) {
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
        navigatorKey: AppModel.of(context).navigatorKey,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => UndefinedView(
            name: settings.name,
          ),
        ),
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      ),
    );
  }

  void _registerFcmToken() async {
    final token = await fcm.getToken();
    metaService.addFcmToken(AppModel.of(context).user.userId, token);
  }

  @override
  void dispose() {
    super.dispose();
    _iosSubscription?.cancel();
  }

  Future<dynamic> _handleBackgroundNotification(Map<String, dynamic> message) {
    if (message['data']['type'] == 'COMMISSION') {
      return AppModel.of(context)
          .navigatorKey
          .currentState
          .pushReplacementNamed('/wallet');
    } else {
      return AppModel.of(context)
          .navigatorKey
          .currentState
          .pushReplacementNamed('/');
    }
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
