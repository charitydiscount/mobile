import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:charity_discount/ui/user/email_signin.dart';
import 'package:charity_discount/util/url.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:charity_discount/ui/app/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class SignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget get horizontalLine => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(0.2),
        ),
      );

  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);

    final logo = Hero(
      tag: 'hero',
      child: Image.asset('assets/icons/logo.png', scale: 5, height: 50),
    );

    final termsButton = FlatButton(
      child: Row(
        children: <Widget>[
          Text(
            tr('terms'),
            style: TextStyle(fontSize: 12),
          ),
          Icon(Icons.launch)
        ],
      ),
      onPressed: () => launchURL('https://charitydiscount.ro/tos'),
    );

    final privacyButton = FlatButton(
      child: Row(
        children: <Widget>[
          Text(
            tr('privacy'),
            style: TextStyle(fontSize: 12),
          ),
          Icon(Icons.launch)
        ],
      ),
      onPressed: () => launchURL('https://charitydiscount.ro/privacy'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('CharityDiscount'),
        primary: true,
        automaticallyImplyLeading: false,
      ),
      body: LoadingScreen(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: logo,
                flex: 1,
              ),
              Expanded(
                child: _buildPlatformSpecificSocial(),
                flex: 2,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    termsButton,
                    privacyButton,
                  ],
                ),
              ),
            ],
          ),
        ),
        inAsyncCall: _loadingVisible,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleLoadingVisible() {
    if (mounted) {
      setState(() {
        _loadingVisible = !_loadingVisible;
      });
    }
  }

  void _googleLogin(BuildContext context) async {
    _toggleLoadingVisible();
    try {
      AppModel.of(context).createListeners();
      await userController.signIn(Strategy.Google);
      _toggleLoadingVisible();
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    } catch (e) {
      _handleAuthError(e);
    }
  }

  void _appleSignIn(BuildContext context) async {
    _toggleLoadingVisible();

    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        try {
          AppModel.of(context).createListeners();
          await userController.signIn(
            Strategy.Apple,
            appleResult: result,
          );
          _toggleLoadingVisible();
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        } catch (e) {
          _handleAuthError(e);
        }
        break;
      case AuthorizationStatus.error:
        _toggleLoadingVisible();
        Flushbar(
          title: 'Sign In Error',
          message: result.error.localizedDescription,
          duration: Duration(seconds: 5),
        )..show(context);
        break;

      case AuthorizationStatus.cancelled:
        _toggleLoadingVisible();
        break;
    }
  }

  void _facebookLogin(BuildContext context) async {
    _toggleLoadingVisible();
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          AppModel.of(context).createListeners();
          await userController.signIn(
            Strategy.Facebook,
            facebookResult: result,
          );
          _toggleLoadingVisible();
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        } catch (e) {
          _handleAuthError(e);
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        _toggleLoadingVisible();
        break;
      case FacebookLoginStatus.error:
        _toggleLoadingVisible();
        Flushbar(
          title: tr('authError'),
          message: result.errorMessage,
          duration: Duration(seconds: 5),
        )..show(context);
        break;
    }
  }

  void _handleAuthError(Exception e) {
    _toggleLoadingVisible();
    if (e is FirebaseException) {
      Flushbar(
        title: tr('authError'),
        message: e.message,
        duration: Duration(seconds: 5),
      )..show(context);
    } else {
      Flushbar(
        title: tr('authError'),
        message: e.toString(),
        duration: Duration(seconds: 5),
      )..show(context);
      throw e;
    }
  }

  Widget _buildPlatformSpecificSocial() {
    if (Platform.isAndroid) {
      return _buildSocialFragmet(includeApple: false);
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return FutureBuilder<IosDeviceInfo>(
      future: deviceInfo.iosInfo,
      builder: (context, snapshop) {
        if (snapshop.connectionState == ConnectionState.waiting ||
            snapshop.hasError ||
            !_isAppleSignInSupported(snapshop.data)) {
          return Container(
            width: 0,
            height: 0,
          );
        }

        return _buildSocialFragmet();
      },
    );
  }

  bool _isAppleSignInSupported(IosDeviceInfo deviceInfo) {
    int majorVersion = int.parse(deviceInfo.systemVersion.substring(0, 2));
    return majorVersion >= 13;
  }

  Widget _buildSocialFragmet({bool includeApple = true}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    List<Widget> buttons = [
      SignInButton(
        Buttons.Email,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EmailSignInScreen(),
            settings: RouteSettings(name: 'EmailSignIn'),
          ),
        ),
      ),
      SignInButton(
        isDark ? Buttons.Google : Buttons.GoogleDark,
        onPressed: () => _googleLogin(context),
      ),
      SignInButton(
        Buttons.FacebookNew,
        onPressed: () => _facebookLogin(context),
      ),
    ];
    if (includeApple == true) {
      buttons.add(
        SignInButton(
          isDark ? Buttons.Apple : Buttons.AppleDark,
          onPressed: () => _appleSignIn(context),
        ),
      );
    }
    final socialMethods = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        socialMethods,
      ],
    );
  }
}
