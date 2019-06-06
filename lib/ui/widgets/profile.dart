import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/state/state_model.dart';

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    var appState = AppModel.of(context);
    var data = EasyLocalizationProvider.of(context).data;

    final logoImage = appState.user.photoUrl != null
        ? CachedNetworkImage(
            imageUrl: appState.user.photoUrl,
            fit: BoxFit.fill,
            width: 120.0,
            height: 120.0,
          )
        : Image.asset(
            'assets/images/default.png',
            fit: BoxFit.cover,
            width: 120.0,
            height: 120.0,
          );
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: ClipOval(
          child: logoImage,
        ),
      ),
    );

    final signOutButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () => _signOut(context),
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('SIGN OUT', style: TextStyle(color: Colors.white)),
      ),
    );

    final email = appState?.user?.email ?? '';
    final firstName = appState?.user?.firstName ?? '';
    final lastName = appState?.user?.lastName ?? '';
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
