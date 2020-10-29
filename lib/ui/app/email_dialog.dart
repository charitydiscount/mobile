import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/app/auth_dialog.dart';
import 'package:charity_discount/util/validator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailDialog extends StatefulWidget {
  EmailDialog({Key key}) : super(key: key);

  @override
  _EmailDialogState createState() => _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailFilledIn = false;
  bool _subscribeToNewsletter = false;
  bool _invalidEmail = false;
  bool _emailAlreadyTaken = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailFilledIn != _emailController.text.isNotEmpty) {
        if (_emailFilledIn == false && Validator.validateEmail(_emailController.text) != null) {
          return;
        }
        setState(() {
          _emailFilledIn = _emailController.text.isNotEmpty;
        });
      }
      if (_invalidEmail) {
        setState(() {
          _invalidEmail = false;
        });
      }
      if (_emailAlreadyTaken) {
        setState(() {
          _emailAlreadyTaken = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailExplanation = Text(tr('emailRequiredExplanation'));

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _emailController,
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

    final newsletterExplanation = Text(tr('emailNewsletterExplanation'));

    final newsletter = CheckboxListTile(
      title: Text(tr('emailNewsletterCheckbox')),
      value: _subscribeToNewsletter,
      onChanged: (value) {
        setState(() {
          _subscribeToNewsletter = value;
        });
      },
    );

    Widget controls = ButtonBar(
      children: [
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          color: Theme.of(context).primaryColor,
          child: Text(
            tr('send').toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _emailFilledIn
              ? () async {
                  try {
                    await locator<AuthService>().updateUserEmail(_emailController.text);
                  } catch (e) {
                    if (e is FirebaseAuthException) {
                      switch (e.code) {
                        case 'requires-recent-login':
                          await showDialog(
                            context: context,
                            builder: reAuthDialogBuilder,
                          );
                          await userController.signOut();
                          return;
                        case 'invalid-email':
                          setState(() {
                            _invalidEmail = true;
                          });
                          return;
                        case 'email-already-in-use':
                          setState(() {
                            _emailAlreadyTaken = true;
                          });
                          return;
                        default:
                      }
                    }
                  }
                  await locator<MetaService>().setEmailNotifications(_subscribeToNewsletter);
                  Navigator.pop(context, true);
                }
              : null,
        ),
      ],
    );

    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
      children: [
        Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: emailExplanation,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: email,
              ),
              _buildError(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: newsletterExplanation,
              ),
              newsletter,
              controls,
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  Widget _buildError() {
    if (_emailAlreadyTaken) {
      return Text(tr('emailAlreadyTaken'));
    }
    if (_invalidEmail) {
      return Text(tr('emailInvalid'));
    }

    return Container(
      width: 0,
      height: 0,
    );
  }
}
