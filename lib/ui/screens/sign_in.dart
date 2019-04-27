import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/util/validator.dart';
import 'package:charity_discount/util/social_icons.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/util/firebase_errors.dart';

class SignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  bool _autoValidate = false;
  bool _loadingVisible = false;
  @override
  void initState() {
    super.initState();
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);

    final logo = Hero(
        tag: 'hero',
        child: Image.asset('assets/icons/icon.png', scale: 3, height: 120));

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
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
        hintText: AppLocalizations.of(context).tr('password'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
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
        child: Text(AppLocalizations.of(context).tr('signIn').toUpperCase(),
            style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      padding: EdgeInsets.only(left: 200),
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
    );

    final signUpLabel = FlatButton(
      child: Text(
        'Create an account',
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
    );

    final socialDivider = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        horizontalLine(),
        Text("Social Login", style: TextStyle(fontSize: 16.0)),
        horizontalLine()
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
            child: Icon(SocialIcons.google, color: Colors.white)),
        MaterialButton(
            shape: CircleBorder(),
            onPressed: () => {},
            color: Color(0xff3b5998),
            height: 65,
            elevation: 0,
            child: Icon(SocialIcons.facebook, color: Colors.white))
      ],
    );

    return EasyLocalizationProvider(
        data: data,
        child: Scaffold(
          backgroundColor: Colors.white,
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
                        children: <Widget>[
                          SizedBox(height: 12.0),
                          logo,
                          SizedBox(height: 24.0),
                          email,
                          SizedBox(height: 12.0),
                          password,
                          SizedBox(height: 12.0),
                          loginButton,
                          forgotLabel,
                          SizedBox(height: 18.0),
                          socialDivider,
                          SizedBox(height: 12.0),
                          socialMethods,
                          SizedBox(height: 24.0),
                          signUpLabel
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              inAsyncCall: _loadingVisible),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _toggleLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _emailLogin(
      {String email, String password, BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _toggleLoadingVisible();
        await userController.signIn(
            Strategy.EmailAndPass,
            StateWidget.of(context).getState().settings.lang,
            {"email": email, "password": password});
        await Navigator.pushNamed(context, '/');
      } catch (e) {
        if (!(e is Error)) {
          await _toggleLoadingVisible();
          String exception = getExceptionText(e);
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
    await _toggleLoadingVisible();
    try {
      await userController.signIn(
          Strategy.Google, StateWidget.of(context).getState().settings.lang);
      await Navigator.pushNamed(context, '/');
    } catch (e) {
      await _toggleLoadingVisible();
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
}
