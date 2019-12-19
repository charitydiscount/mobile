import 'package:charity_discount/services/factory.dart';
import 'package:charity_discount/ui/widgets/user_avatar.dart';
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

    final logoImage = UserAvatar(
      photoUrl: appState.user.photoUrl,
      width: 120.0,
      height: 120.0,
    );
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: logoImage,
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
        child: Text(
          'LOG OUT',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    final emailLabel = Text('Email: ');
    final email = appState?.user?.email ?? '';

    final nameLabel = Text('${AppLocalizations.of(context).tr('name')}:');
    final name =
        '${appState?.user?.firstName ?? ''} ${appState?.user?.lastName ?? ''}';

    return LoadingScreen(
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
                nameLabel,
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12.0),
                SizedBox(height: 12.0),
                signOutButton,
              ],
            ),
          ),
        ),
      ),
      inAsyncCall: _loadingVisible,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await userController.signOut();
    await AppModel.of(context).closeListeners();
    AppModel.of(context).setUser(null);
    clearInstances();
    await Navigator.pushNamedAndRemoveUntil(context, '/signin', (r) => false);
  }
}
