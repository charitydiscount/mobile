import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/ui/theme.dart';
import 'package:charity_discount/ui/screens/home.dart';
import 'package:charity_discount/ui/screens/sign_in.dart';
import 'package:charity_discount/ui/screens/sign_up.dart';
import 'package:charity_discount/ui/screens/forgot_password.dart';

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
        data: data,
        child: MaterialApp(
          title: 'Charity Discount',
          theme: buildTheme(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            EasylocaLizationDelegate(
                locale: data.locale ?? Locale('en'), path: 'assets/i18n'),
          ],
          supportedLocales: [Locale('en'), Locale('ro')],
          locale: data.locale,
          routes: {
            '/': (context) => HomeScreen(),
            '/signin': (context) => SignInScreen(),
            '/signup': (context) => SignUpScreen(),
            '/forgot-password': (context) => ForgotPasswordScreen(),
          },
        ));
  }
}

void main() => runApp(EasyLocalization(child: StateWidget(child: Main())));
