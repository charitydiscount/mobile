import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/services/notifications.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/products/products_screen.dart';
import 'package:charity_discount/ui/app/settings.dart';
import 'package:charity_discount/ui/referrals/referrals.dart';
import 'package:charity_discount/ui/wallet/wallet.dart';
import 'package:charity_discount/ui/user/profile.dart';
import 'package:charity_discount/ui/programs/programs.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
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
  bool _showNotifications = true;

  _HomeScreenState({this.selectedNavIndex});

  @override
  void initState() {
    super.initState();
    _configureFcm(context);
    var state = AppModel.of(context);
    state.addListener(() {
      if (_showNotifications != state.settings.notifications) {
        _configureFcm(context);
        _showNotifications = state.settings.notifications;
      }
    });
  }

  void _configureFcm(BuildContext context) {
    _showNotifications = AppModel.of(context).settings.notifications;
    if (_showNotifications) {
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
    } else {
      fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (mounted) {
            Flushbar(
              title: message['notification']['title'],
              message: message['notification']['body'],
            )?.show(context);
          }
        },
      );
    }
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
          _widgets[selectedNavIndex] = ProgramsList(
            searchService: locator<SearchServiceBase>(),
            shopsService: locator<ShopsService>(),
          );
          break;
        case 1:
          _widgets[selectedNavIndex] =
              ProductsScreen(searchService: locator<SearchServiceBase>());
          break;
        case 2:
          _widgets[selectedNavIndex] = CharityWidget(
            charityService: locator<CharityService>(),
          );
          break;
        case 3:
          _widgets[selectedNavIndex] = WalletScreen(
            charityService: locator<CharityService>(),
          );
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
            title: Text(
              tr('shops'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            title: Text(
              tr('product.title'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text(
              tr('charity'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            title: Text(
              tr('wallet.name'),
            ),
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

  String getUserName(User user) => user.name ?? user.email;
}
