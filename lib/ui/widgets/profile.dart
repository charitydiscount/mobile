import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/models/state.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  StateModel appState;
  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).getState();
    var data = EasyLocalizationProvider.of(context).data;

    if (appState.isLoading) {
      _loadingVisible = true;
    } else {
      _loadingVisible = false;
    }
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

    final signOutButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () => _signOut(context),
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('SIGN OUT', style: TextStyle(color: Colors.white)),
      ),
    );

    final userId = appState?.user?.userId ?? '';
    final email = appState?.user?.email ?? '';
    final firstName = appState?.user?.firstName ?? '';
    final lastName = appState?.user?.lastName ?? '';
    final userIdLabel = Text('App Id: ');
    final emailLabel = Text('Email: ');
    final firstNameLabel = Text('First Name: ');
    final lastNameLabel = Text('Last Name: ');

    return EasyLocalizationProvider(
      data: data,
      child: LoadingScreen(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    logo,
                    SizedBox(height: 48.0),
                    userIdLabel,
                    Text(userId, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.0),
                    emailLabel,
                    Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.0),
                    firstNameLabel,
                    Text(firstName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.0),
                    lastNameLabel,
                    Text(lastName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.0),
                    SizedBox(height: 12.0),
                    signOutButton,
                  ],
                ),
              ),
            ),
          ),
          inAsyncCall: _loadingVisible),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await userController.signOut();
    await Navigator.pushNamed(context, '/signin');
  }
}
