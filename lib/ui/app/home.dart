import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/products/products_screen.dart';
import 'package:charity_discount/ui/app/settings.dart';
import 'package:charity_discount/ui/referrals/referrals.dart';
import 'package:charity_discount/ui/wallet/wallet.dart';
import 'package:charity_discount/ui/user/profile.dart';
import 'package:charity_discount/ui/programs/programs.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:charity_discount/util/url.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/ui/charity/charity.dart';

class HomeScreen extends StatefulWidget {
  final int initialScreen;
  _HomeScreenState createState() => _HomeScreenState(
        selectedNavIndex: initialScreen,
      );
  HomeScreen({this.initialScreen = 0});
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedNavIndex = 0;
  List<Widget> _widgets = [Container(), Container(), Container(), Container()];
  List<bool> _loadedWidgets = [false, false, false, false];

  _HomeScreenState({this.selectedNavIndex});

  @override
  void initState() {
    super.initState();
    _configureFcm(context);
  }

  void _configureFcm(BuildContext context) {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (mounted) {
          Flushbar(
            title: message['notification']['title'],
            message: message['notification']['body'],
          )?.show(context);
        }
      },
      onLaunch: _handleBackgroundNotification,
      onResume: _handleBackgroundNotification,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  static Future<dynamic> backgroundMessageHandler(
    Map<String, dynamic> message,
  ) async {
    return Future.value(true);
  }

  Future<dynamic> _handleBackgroundNotification(Map<String, dynamic> message) {
    if (message['data']['type'] == 'COMMISSION') {
      setState(() {
        selectedNavIndex = 3;
      });
    }

    return Future.value(true);
  }

  Widget build(BuildContext context) {
    var appState = AppModel.of(context);

    if (_loadedWidgets[selectedNavIndex] == false) {
      switch (selectedNavIndex) {
        case 0:
          _widgets[selectedNavIndex] = ProgramsList();
          break;
        case 1:
          _widgets[selectedNavIndex] = ProductsScreen();
          break;
        case 2:
          _widgets[selectedNavIndex] = CharityWidget();
          break;
        case 3:
          _widgets[selectedNavIndex] = WalletScreen();
          break;
        default:
      }
      _loadedWidgets[selectedNavIndex] = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('CharityDiscount'),
        primary: true,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          _buildProfileButton(context: context, user: appState.user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: tr('shops'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: tr('product.title'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: tr('charity'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: tr('wallet.name'),
          ),
        ],
        currentIndex: selectedNavIndex,
        onTap: _onItemTapped,
      ),
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(content: Text(tr('doubleBack'))),
        child: IndexedStack(
          children: _widgets,
          index: selectedNavIndex,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedNavIndex = index;
    });
  }

  Widget _buildProfileButton({BuildContext context, User user}) {
    if (!locator<AuthService>().isActualUser()) {
      return FlatButton(
        child: Text(
          tr('signIn').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.pushNamed(context, Routes.signIn);
        },
      );
    }

    final logoImage = UserAvatar(photoUrl: user.photoUrl);
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            TextStyle titleStyle = Theme.of(context).textTheme.headline6;

            List<ListTile> menuTiles = [];
            ListTile profileTile = ListTile(
              leading: CircleAvatar(
                child: logoImage,
                radius: 12,
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                getUserName(user),
                style: titleStyle,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ProfileScreen(),
                    settings: RouteSettings(name: 'Profile'),
                  ),
                );
              },
            );
            menuTiles.add(profileTile);

            ListTile referrals = ListTile(
              leading: Icon(Icons.people),
              title: Text(
                tr('referralsLabel'),
                style: titleStyle,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ReferralsScreen(
                      charityService: locator<CharityService>(),
                    ),
                    settings: RouteSettings(name: 'Referrals'),
                  ),
                );
              },
            );
            menuTiles.add(referrals);

            ListTile settings = ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                tr('settings'),
                style: titleStyle,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SettingsScreen(),
                    settings: RouteSettings(name: 'Settings'),
                  ),
                );
              },
            );
            menuTiles.add(settings);

            ListTile terms = ListTile(
              leading: Icon(Icons.help_outline),
              title: Text(
                tr('terms'),
                style: titleStyle,
              ),
              onTap: () => launchURL('https://charitydiscount.ro/tos'),
            );
            menuTiles.add(terms);

            ListTile privacy = ListTile(
              leading: Icon(Icons.verified_user),
              title: Text(
                tr('privacy'),
                style: titleStyle,
              ),
              onTap: () => launchURL('https://charitydiscount.ro/privacy'),
            );
            menuTiles.add(privacy);

            return Container(
              alignment: Alignment.center,
              child: ListView.separated(
                padding: EdgeInsets.all(12.0),
                primary: false,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, index) {
                  return menuTiles[index];
                },
                itemCount: menuTiles.length,
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: logoImage,
      ),
    );
  }

  String getUserName(User user) =>
      user.name != null && user.name.isNotEmpty ? user.name : user.email;
}
