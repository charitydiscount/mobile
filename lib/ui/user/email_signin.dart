import 'package:charity_discount/util/url.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:charity_discount/ui/app/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/state/state_model.dart';

class EmailSignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<EmailSignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loadingVisible = false;
  bool _emailFilledIn = false;
  bool _passFilledIn = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(() {
      if (_emailFilledIn != _email.text.isNotEmpty) {
        setState(() {
          _emailFilledIn = _email.text.isNotEmpty;
        });
      }
    });
    _password.addListener(() {
      if (_passFilledIn != _password.text.isNotEmpty) {
        setState(() {
          _passFilledIn = _password.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  Widget get horizontalLine => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(0.2),
        ),
      );

  Widget build(BuildContext context) {
    ScreenUtil.init(context);

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
      onPressed: () => UrlHelper.launchTerms(),
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
      onPressed: () => UrlHelper.launchPrivacy(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('CharityDiscount'),
        primary: true,
        automaticallyImplyLeading: false,
      ),
      body: LoadingScreen(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
                maxWidth: 600,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: _buildLoginForm(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        termsButton,
                        privacyButton,
                      ],
                    ),
                    FlatButton(
                      child: Text(
                        tr('useOtherAuthMethods'),
                        style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
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

  Widget _buildLoginForm() {
    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _email,
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
      child: Container(
        width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onPressed: _emailFilledIn && _passFilledIn
              ? () {
                  _emailLogin(
                    email: _email.text,
                    password: _password.text,
                    context: context,
                  );
                }
              : null,
          padding: EdgeInsets.all(12),
          color: Theme.of(context).primaryColor,
          child: Text(
            tr('signIn').toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        tr('forgotPassword'),
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
    );

    final signUpButton = FlatButton(
      child: Text(
        tr('createAccount'),
        style: TextStyle(
          color: Theme.of(context).secondaryHeaderColor,
          fontSize: 16,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: email,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: password,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: loginButton,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [signUpButton, forgotLabel],
        )
      ],
    );
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
        AppModel.of(context).createListeners();
        await userController.signIn(
          Strategy.EmailAndPass,
          credentials: {'email': email, 'password': password},
        );
        _toggleLoadingVisible();
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      } catch (e) {
        _handleAuthError(e);
      }
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
    }
  }
}
