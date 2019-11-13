import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:charity_discount/util/validator.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/util/firebase_errors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  bool _autoValidate = false;
  bool _loadingVisible = false;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: Image.asset(
              'assets/images/default.png',
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
            ),
          )),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );

    final forgotPasswordButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () {
          _forgotPassword(email: _email.text, context: context);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(
          AppLocalizations.of(context).tr('recoverPassword'),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    final signInLabel = FlatButton(
      child: Text(
        'Sign In',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signin');
      },
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    logo,
                    SizedBox(height: 48.0),
                    email,
                    SizedBox(height: 12.0),
                    forgotPasswordButton,
                    signInLabel
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

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _forgotPassword({String email, BuildContext context}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState.validate()) {
      try {
        await _changeLoadingVisible();
        await userController.resetPassword(email);
        await _changeLoadingVisible();
        Flushbar(
          title: AppLocalizations.of(context).tr('resetPassEmailSentTitle'),
          message: AppLocalizations.of(context).tr('resetPassEmailSentMessage'),
          duration: Duration(seconds: 20),
        )..show(context);
      } catch (e) {
        _changeLoadingVisible();
        print("Forgot Password Error: $e");
        String exception = getExceptionText(e);
        Flushbar(
          title: "Forgot Password Error",
          message: exception,
          duration: Duration(seconds: 10),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
