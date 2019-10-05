import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/services/factory.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/news.dart';
import 'package:charity_discount/ui/screens/settings.dart';
import 'package:charity_discount/ui/screens/wallet.dart';
import 'package:charity_discount/ui/screens/profile.dart';
import 'package:charity_discount/ui/widgets/programs.dart';
import 'package:charity_discount/ui/widgets/user_avatar.dart';
import 'package:charity_discount/util/url.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/charity.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loadingVisible = false;
  int _selectedNavIndex = 0;
  List<Widget> _widgets = [];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    var appState = AppModel.of(context);
    if (_widgets.isEmpty) {
      final CharityWidget charityList = CharityWidget(
        charityService: getFirebaseCharityService(),
      );
      final ProgramsList programsList = ProgramsList(
        searchService: SearchService(),
        shopsService: getFirebaseShopsService(appState.user.userId),
      );
      final WalletScreen walletScreen = WalletScreen(
        charityService: getFirebaseCharityService(),
      );

      appState.setServices(
        getFirebaseShopsService(appState.user.userId),
        getFirebaseCharityService(),
      );

      _widgets.addAll([
        charityList,
        programsList,
        walletScreen,
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Charity Discount'),
        primary: true,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          _buildProfileButton(context: context, user: appState.user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text(
              AppLocalizations.of(context).tr('charity'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            title: Text(
              AppLocalizations.of(context).tr('shops'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            title: Text(
              AppLocalizations.of(context).tr('wallet'),
            ),
          ),
        ],
        currentIndex: _selectedNavIndex,
        onTap: _onItemTapped,
      ),
      body: LoadingScreen(
        child: _widgets.elementAt(_selectedNavIndex),
        inAsyncCall: _loadingVisible,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  Widget _buildProfileButton({BuildContext context, User user}) {
    final logoImage = UserAvatar(photoUrl: user.photoUrl);
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            TextStyle titleStyle = Theme.of(context).textTheme.title;

            List<ListTile> menuTiles = [];
            ListTile profileTile = ListTile(
              leading: CircleAvatar(
                child: logoImage,
                radius: 12,
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                '${user.firstName} ${user.lastName}',
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

            ListTile news = ListTile(
              leading: Icon(Icons.update),
              title: Text(
                'Noutati',
                style: titleStyle,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => NewsScreen(
                      charityService: getFirebaseCharityService(),
                    ),
                    settings: RouteSettings(name: 'News'),
                  ),
                );
              },
            );
            menuTiles.add(news);

            ListTile settings = ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Setari',
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
                'Termeni si conditii',
                style: titleStyle,
              ),
              onTap: () => launchURL('https://charitydiscount.ro/tos'),
            );
            menuTiles.add(terms);

            ListTile privacy = ListTile(
              leading: Icon(Icons.verified_user),
              title: Text(
                'Confidentialitate',
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
}
