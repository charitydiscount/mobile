import 'package:charity_discount/state/state_model.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    List<Widget> settingTiles = [];
    AppModel state = AppModel.of(context);

    Widget language = ExpansionTile(
      leading: Icon(Icons.language),
      title: Text('Limba'),
      children: <Widget>[
        ListTile(
          leading: Padding(
            padding: const EdgeInsets.all(6.0),
            child: SvgPicture.asset(
              'assets/icons/ro.svg',
              fit: BoxFit.cover,
              width: 16,
              alignment: Alignment.center,
            ),
          ),
          title: Text('Romana'),
          trailing: state.settings.lang == 'ro' ? Icon(Icons.check) : null,
          onTap: () {
            var newSettings = state.settings;
            newSettings.lang = 'ro';
            setState(() {
              state.setSettings(newSettings);
            });
          },
        ),
        ListTile(
          leading: Padding(
            padding: const EdgeInsets.all(6.0),
            child: SvgPicture.asset(
              'assets/icons/gb.svg',
              fit: BoxFit.cover,
              width: 16,
              alignment: Alignment.center,
            ),
          ),
          title: Text('English'),
          trailing: state.settings.lang == 'en' ? Icon(Icons.check) : null,
          onTap: () {
            var newSettings = state.settings;
            newSettings.lang = 'en';
            setState(() {
              state.setSettings(newSettings);
            });
          },
        ),
      ],
    );
    settingTiles.add(language);

    Widget notifications = ListTile(
      leading: Icon(Icons.notifications),
      title: Text('Notificari'),
      trailing: Switch.adaptive(
        value: state.settings.notifications,
        onChanged: (bool newValue) {
          var newSettings = state.settings;
          newSettings.notifications = newValue;
          setState(() {
            state.setSettings(newSettings);
          });
        },
      ),
    );

    settingTiles.add(notifications);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).tr('settings'),
        ),
      ),
      body: ListView.separated(
        primary: true,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          return settingTiles[index];
        },
        itemCount: settingTiles.length,
      ),
    );
  }
}
