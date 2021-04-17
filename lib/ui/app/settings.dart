import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/util/social_icons.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';

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
    Widget notifications = ExpansionTile(
      leading: Icon(Icons.notifications),
      title: Text(tr('notifications')),
      children: [
        ListTile(
          title: Text(capitalize(tr('commission'))),
          trailing: Switch.adaptive(
            value: _state.settings.notificationsForCashback || false,
            onChanged: (bool newValue) {
              var newSettings = _state.settings;
              newSettings.notificationsForCashback = newValue;
              setState(() {
                _state.setSettings(newSettings, storeLocal: true);
              });
              FirebaseMessaging.instance.getToken().then(
                    (token) => locator<MetaService>().setNotifications(
                      token,
                      newValue,
                    ),
                  );
            },
          ),
        ),
        ListTile(
          title: Text(tr('promotion.promotions')),
          trailing: Switch.adaptive(
            value: _state.settings.notificationsForPromotions || false,
            onChanged: (bool newValue) {
              var newSettings = _state.settings;
              newSettings.notificationsForPromotions = newValue;
              setState(() {
                _state.setSettings(newSettings, storeLocal: true);
              });
              FirebaseMessaging.instance.getToken().then(
                    (token) =>
                        locator<MetaService>().setNotificationsForPromotions(
                      token,
                      newValue,
                    ),
                  );
            },
          ),
        ),
        StreamBuilder<bool>(
          stream: locator<MetaService>().subscribedToNewsletter,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(width: 0, height: 0);
            }
            return ListTile(
              title: Text('Email Newsletter'),
              trailing: Switch.adaptive(
                value: !snapshot.data || false,
                onChanged: (bool newValue) {
                  locator<MetaService>().setEmailNotifications(!newValue);
                },
              ),
            );
          },
        )
      ],
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

    settingTiles.add(_buildSocialTile(
      icon: SocialIcons.facebook,
      title: 'Facebook',
      url: 'https://www.facebook.com/charitydiscount',
    ));

    settingTiles.add(_buildSocialTile(
      icon: SocialIcons.instagram,
      title: 'Instagram',
      url: 'https://www.instagram.com/charitydiscount',
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('settings'),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.separated(
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
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, infoSnap) {
              if (infoSnap.connectionState == ConnectionState.waiting) {
                return Container(width: 0, height: 0);
              }

              return Positioned(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      infoSnap.data.version,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTile({
    IconData icon,
    String title,
    String url,
  }) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          launchURL(url);
        },
      );

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
      trailing:
          EasyLocalization.of(context).locale.languageCode == language.code
              ? Icon(Icons.check)
              : null,
      onTap: () {
        EasyLocalization.of(context).setLocale(language.locale);
        FirebaseAuth.instance.setLanguageCode(language.locale.languageCode);
        setState(() {});
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
