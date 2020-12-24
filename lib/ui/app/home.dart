import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/challenges.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/products/products_screen.dart';
import 'package:charity_discount/ui/app/settings.dart';
import 'package:charity_discount/ui/promotions/promotions.dart';
import 'package:charity_discount/ui/referrals/referrals.dart';
import 'package:charity_discount/ui/wallet/wallet.dart';
import 'package:charity_discount/ui/user/profile.dart';
import 'package:charity_discount/ui/programs/programs.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:charity_discount/util/url.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/ui/charity/charity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  final Screen initialScreen;
  _HomeScreenState createState() => _HomeScreenState(
        selectedNavIndex: initialScreen,
      );
  HomeScreen({this.initialScreen = Screen.PROGRAMS});
}

class _HomeScreenState extends State<HomeScreen> {
  Screen selectedNavIndex;
  List<Widget> _widgets =
      List.generate(Screen.values.length, (_) => Container());
  List<bool> _loadedWidgets = List.generate(Screen.values.length, (_) => false);
  bool willExitApp = false;

  _HomeScreenState({this.selectedNavIndex});

  @override
  void initState() {
    super.initState();
    _configureFcm(context);
  }

  void _configureFcm(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (!mounted) {
        return;
      }
      final type = message.data['type'];
      bool needsButton = type == NotificationTypes.commission ||
          type == NotificationTypes.shop;

      Flushbar(
        title: message.notification.title,
        message: message.notification.body,
        mainButton: needsButton
            ? FlatButton(
                child: Text(
                  tr('open'),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () async {
                  switch (type) {
                    case NotificationTypes.commission:
                      setState(() {
                        selectedNavIndex = Screen.WALLET;
                      });
                      break;
                    case NotificationTypes.shop:
                      await navigateToShop(context, message.data['shopName']);
                      break;
                    default:
                  }
                },
              )
            : null,
      )?.show(context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotification);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then(_handleBackgroundNotification);
  }

  Future<dynamic> _handleBackgroundNotification(
    RemoteMessage message,
  ) async {
    if (message == null) {
      return;
    }

    final type = message.data['type'];
    switch (type) {
      case NotificationTypes.commission:
        setState(() {
          selectedNavIndex = Screen.WALLET;
        });
        break;
      case NotificationTypes.shop:
        await navigateToShop(context, message.data['shopName']);
        break;
      default:
    }

    return Future.value(true);
  }

  Widget build(BuildContext context) {
    var appState = AppModel.of(context);

    if (_loadedWidgets[selectedNavIndex.index] == false) {
      switch (selectedNavIndex) {
        case Screen.PROGRAMS:
          _widgets[selectedNavIndex.index] = ProgramsList();
          break;
        case Screen.PROMOTIONS:
          _widgets[selectedNavIndex.index] = PromotionsScreen();
          break;
        case Screen.PRODUCTS:
          _widgets[selectedNavIndex.index] = ProductsScreen();
          break;
        case Screen.CASES:
          _widgets[selectedNavIndex.index] = CharityWidget();
          break;
        case Screen.WALLET:
          _widgets[selectedNavIndex.index] = WalletScreen();
          break;
        default:
      }
      _loadedWidgets[selectedNavIndex.index] = true;
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
              icon: Icon(Icons.access_time),
              label: tr('promotion.promotions'),
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
          currentIndex: selectedNavIndex.index,
          onTap: _onItemTapped,
        ),
        body: IndexedStack(
          children: _widgets,
          index: selectedNavIndex.index,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedNavIndex = Screen.values[index];
      if (willExitApp) {
        willExitApp = false;
      }
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
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
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

          ListTile achievements = ListTile(
            leading: SvgPicture.asset(
              'assets/icons/trophy.svg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.grey,
            ),
            title: Text(
              '${tr('leaderboard')} & ${tr('achievements')}',
              style: titleStyle,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ChallengesScreen(),
                  settings: RouteSettings(name: 'Achievements'),
                ),
              );
            },
          );
          menuTiles.add(achievements);

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
            onTap: () => UrlHelper.launchTerms(),
          );
          menuTiles.add(terms);

          ListTile privacy = ListTile(
            leading: Icon(Icons.verified_user),
            title: Text(
              tr('privacy'),
              style: titleStyle,
            ),
            onTap: () => UrlHelper.launchPrivacy(),
          );
          menuTiles.add(privacy);

          return Container(
            alignment: Alignment.center,
            height: ScreenUtil().screenHeight * 0.75,
            child: ListView.separated(
              padding: EdgeInsets.all(12.0),
              primary: false,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) => menuTiles[index],
              itemCount: menuTiles.length,
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: logoImage,
      ),
    );
  }

  String getUserName(User user) =>
      user.name != null && user.name.isNotEmpty ? user.name : user.email;

  Future<bool> _onBackPressed() async {
    if (willExitApp) {
      return true;
    }

    setState(() {
      willExitApp = true;
    });

    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {
        willExitApp = false;
      });
    });

    Fluttertoast.showToast(msg: tr('doubleBack'));

    return false;
  }
}

enum Screen { PROGRAMS, PROMOTIONS, PRODUCTS, CASES, WALLET }
