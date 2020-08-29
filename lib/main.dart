import 'dart:io';
import 'package:async/async.dart';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/router.dart' as appRouter;
import 'package:charity_discount/services/analytics.dart';
import 'package:charity_discount/services/navigation.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/app/welcome.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
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
        if (appModel.loading) {
          return AppLoading(child: buildLoading(context));
        }

        if (!appModel.introCompleted) {
          return WelcomeScreen();
        }

        if (appModel.user != null && appModel.user.userId != null) {
          return HomeScreen(initialScreen: initialScreen);
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
      onGenerateRoute: appRouter.Router.generateRoute,
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
      navigatorKey: locator<NavigationService>().navigatorKey,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }

  void _initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        return _handleDeepLinks(dynamicLink?.link);
      },
      onError: (OnLinkErrorException e) async {
        print(e.message);
      },
    );

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      _handleDeepLinks(deepLink);
    }
  }

  void _handleDeepLinks(Uri deepLink) async {
    if (deepLink == null) {
      return;
    }

    switch (deepLink.pathSegments.first) {
      case DeepLinkPath.referral:
        AppModel.of(context).setReferralCode(deepLink.pathSegments.last);
        break;
      case DeepLinkPath.shop:
        if (AppModel.of(context).user == null) {
          return;
        }
        var programs = await AppModel.of(context).programsFuture;
        var program = programs.firstWhere(
          (p) =>
              p.name.toLowerCase() == deepLink.pathSegments.last.toLowerCase(),
          orElse: () => null,
        );

        if (program == null) {
          return;
        }

        analytics.logViewItem(
          itemId: program.id,
          itemName: program.name,
          itemCategory: 'program',
        );

        locator<NavigationService>().navigateTo(
          Routes.shopDetails,
          arguments: program,
        );
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
  AsyncMemoizer<FirebaseApp> _firebaseMemoizer = AsyncMemoizer();

  setupServices();

  runApp(
    EasyLocalization(
      path: 'assets/i18n',
      supportedLocales: supportedLanguages.map((l) => l.locale).toList(),
      child: FutureBuilder(
        future: _firebaseMemoizer.runOnce(() => Firebase.initializeApp()),
        builder: (context, snapshot) {
          var loading = buildConnectionLoading(
            context: context,
            snapshot: snapshot,
          );
          if (loading != null) {
            return loading;
          }
          return ScopedModel(
            model: AppModel(),
            child: Main(),
          );
        },
      ),
    ),
  );
}

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
