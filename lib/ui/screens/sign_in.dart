import 'package:charity_discount/util/url.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:charity_discount/util/validator.dart';
import 'package:charity_discount/util/social_icons.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/util/firebase_errors.dart';
import 'package:charity_discount/state/state_model.dart';

class SignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _autoValidate = false;
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

    final tr = AppLocalizations.of(context).tr;

    final logo = Hero(
      tag: 'hero',
      child: Image.asset('assets/icons/icon.png', scale: 3, height: 120),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _email,
      validator: Validator.validateEmail,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
            color: Colors.grey,
          ),
        ),
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: _password,
      validator: Validator.validatePassword,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        hintText: tr('password'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () async => _emailLogin(
            email: _email.text, password: _password.text, context: context),
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(
          tr('signIn').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    final forgotLabel = FlatButton(
      padding: EdgeInsets.only(left: 200),
      child: Text(
        tr('forgotPassword'),
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
    );

    final signUpLabel = FlatButton(
      child: Text(
        tr('createAccount'),
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
    );

    final socialDivider = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        horizontalLine,
        Text('Social Login', style: TextStyle(fontSize: 16.0)),
        horizontalLine,
      ],
    );
    final socialMethods = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          shape: CircleBorder(),
          onPressed: () async => _googleLogin(context),
          color: Color(0xffdd4b39),
          height: 65,
          elevation: 0,
          child: Icon(SocialIcons.google, color: Colors.white),
        ),
        MaterialButton(
          shape: CircleBorder(),
          onPressed: () async => _facebookLogin(context),
          color: Color(0xff3b5998),
          height: 65,
          elevation: 0,
          child: Icon(SocialIcons.facebook, color: Colors.white),
        )
      ],
    );

    final termsButton = FlatButton(
      child: Row(
        children: <Widget>[Text(tr('terms')), Icon(Icons.launch)],
      ),
      onPressed: () => launchURL('https://charitydiscount.ro/tos'),
    );

    final privacyButton = FlatButton(
      child: Row(
        children: <Widget>[Text(tr('privacy')), Icon(Icons.launch)],
      ),
      onPressed: () => launchURL('https://charitydiscount.ro/privacy'),
    );

    return Scaffold(
      body: LoadingScreen(
        child: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    logo,
                    SizedBox(height: 12.0),
                    email,
                    SizedBox(height: 12.0),
                    password,
                    SizedBox(height: 12.0),
                    loginButton,
                    forgotLabel,
                    SizedBox(height: 12.0),
                    socialDivider,
                    SizedBox(height: 12.0),
                    socialMethods,
                    SizedBox(height: 12.0),
                    signUpLabel,
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        termsButton,
                        privacyButton,
                      ],
                    ),
                  ],
                ),
              ),
            ),
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

  void _emailLogin({
    String email,
    String password,
    BuildContext context,
  }) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _toggleLoadingVisible();
        await userController.signIn(
          Strategy.EmailAndPass,
          credentials: {"email": email, "password": password},
        );
        AppModel.of(context).createListeners();
        _toggleLoadingVisible();
        await Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      } catch (e) {
        if (!(e is Error)) {
          String exception = getExceptionText(e);
          _toggleLoadingVisible();
          Flushbar(
            title: "Sign In Error",
            message: exception,
            duration: Duration(seconds: 5),
          )..show(context);
        }
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }

  void _googleLogin(BuildContext context) async {
    _toggleLoadingVisible();
    try {
      await userController.signIn(Strategy.Google);
      AppModel.of(context).createListeners();
      _toggleLoadingVisible();
      await Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    } catch (e) {
      _toggleLoadingVisible();
      if (!(e is Error)) {
        String exception = getExceptionText(e);
        Flushbar(
          title: "Sign In Error",
          message: exception,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    }
  }

  void _facebookLogin(BuildContext context) async {
    _toggleLoadingVisible();
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          await userController.signIn(
            Strategy.Facebook,
            facebookResult: result,
          );
          _toggleLoadingVisible();
          await Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        } catch (e) {
          _toggleLoadingVisible();
          if (!(e is Error)) {
            String exception = getExceptionText(e);
            Flushbar(
              title: "Sign In Error",
              message: exception,
              duration: Duration(seconds: 5),
            )..show(context);
          }
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        _toggleLoadingVisible();
        break;
      case FacebookLoginStatus.error:
        _toggleLoadingVisible();
        Flushbar(
          title: "Sign In Error",
          message: result.errorMessage,
          duration: Duration(seconds: 5),
        )..show(context);
        break;
    }
  }
}
