import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/user/agreement.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:charity_discount/util/validator.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charity_discount/ui/app/loading.dart';

class SignUpScreen extends StatefulWidget {
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
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
        ),
      ),
    );

    final firstName = TextFormField(
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: _firstName,
      validator: Validator.validateName,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: tr('firstName'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );

    final lastName = TextFormField(
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: _lastName,
      validator: Validator.validateName,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: tr('lastName'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
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
          ), // icon is 48px widget.
        ), // icon is 48px widget.
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
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: tr('password'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
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

    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () async {
          bool agreed = await showDialog(
            context: context,
            builder: (context) => AgreementDialog(),
          );
          if (agreed) {
            _emailSignUp(
              firstName: _firstName.text,
              lastName: _lastName.text,
              email: _email.text,
              password: _password.text,
              context: context,
            );
          }
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(tr('createAccount'), style: TextStyle(color: Colors.white)),
      ),
    );

    final signInLabel = FlatButton(
      child: Text(
        tr('alreadyAccount'),
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signin');
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('CharityDiscount'),
        primary: true,
        automaticallyImplyLeading: false,
      ),
      body: LoadingScreen(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.95,
                    maxWidth: 600,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      logo,
                      SizedBox(height: 24.0),
                      firstName,
                      SizedBox(height: 16.0),
                      lastName,
                      SizedBox(height: 16.0),
                      email,
                      SizedBox(height: 16.0),
                      password,
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          termsButton,
                          privacyButton,
                        ],
                      ),
                      SizedBox(height: 12.0),
                      signUpButton,
                      signInLabel
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        inAsyncCall: _loadingVisible,
      ),
    );
  }

  void _toggleLoadingVisible() {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _emailSignUp({
    String firstName,
    String lastName,
    String email,
    String password,
    BuildContext context,
  }) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _toggleLoadingVisible();
        AppModel.of(context).createListeners();
        await userController.signUp(
          email.trim(),
          password.trim(),
          firstName.trim(),
          lastName.trim(),
        );
        _toggleLoadingVisible();
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
        );
      } catch (e) {
        _toggleLoadingVisible();
        if (e is FirebaseException) {
          Flushbar(
            title: tr('authError'),
            message: e.message,
            duration: Duration(seconds: 5),
          )..show(context);
        } else {
          if (e is PlatformException) {
            Flushbar(
              title: tr('authError'),
              message: e.toString(),
              duration: Duration(seconds: 5),
            )..show(context);
          } else {
            printError(e.toString());
          }
        }
      }
    }
  }
}
