import 'package:charity_discount/ui/widgets/profile.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).tr('profile'),
        ),
      ),
      body: Profile(),
    );
  }
}
