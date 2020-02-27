import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppModel _state;

  @override
  void initState() {
    super.initState();
    _state = AppModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> settingTiles = [];
    Widget language = ExpansionTile(
      leading: Icon(Icons.language),
      title: Text(tr('language')),
      children:
          supportedLanguages.map((lang) => _buildLanguageTile(lang)).toList(),
    );
    settingTiles.add(language);
    Widget notifications = ListTile(
      leading: Icon(Icons.notifications),
      title: Text(tr('notifications')),
      trailing: Switch.adaptive(
        value: _state.settings.notifications || false,
        onChanged: (bool newValue) {
          var newSettings = _state.settings;
          newSettings.notifications = newValue;
          setState(() {
            _state.setSettings(newSettings, storeLocal: true);
          });
          fcm.getToken().then(
                (token) => metaService.setNotifications(token, newValue),
              );
        },
      ),
    );
    settingTiles.add(notifications);

    Widget theme = ExpansionTile(
      leading: Icon(Icons.color_lens),
      title: Text(tr('theme.name')),
      children: ThemeOption.values
          .map((themeOption) => _buildThemeRadioButton(themeOption))
          .toList(),
    );
    settingTiles.add(theme);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('settings'),
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

  Widget _buildLanguageTile(SupportedLanguage language) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset(
          language.iconPath,
          fit: BoxFit.cover,
          width: 16,
          alignment: Alignment.center,
        ),
      ),
      title: Text(language.name),
      trailing: EasyLocalizationProvider.of(context).data.locale.languageCode ==
              language.code
          ? Icon(Icons.check)
          : null,
      onTap: () {
        var newSettings = _state.settings;
        newSettings.lang = language.code;
        setState(() {
          _state.setSettings(newSettings);
          EasyLocalizationProvider.of(context)
              .data
              .changeLocale(locale: language.locale);
        });
      },
    );
  }

  Widget _buildThemeRadioButton(ThemeOption value) => ListTile(
        title: Text(
          tr('theme.${describeEnum(value).toLowerCase()}'),
        ),
        leading: Radio(
          value: value,
          groupValue: _state.settings.theme,
          onChanged: (ThemeOption newValue) {
            var newSettings = _state.settings;
            newSettings.theme = newValue;
            setState(() {
              _state.setSettings(newSettings, storeLocal: true);
            });
          },
        ),
      );
}
