import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/settings.dart';
import 'package:charity_discount/ui/screens/wallet.dart';
import 'package:charity_discount/ui/screens/profile.dart';
import 'package:charity_discount/ui/widgets/programs.dart';
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
  final _widgets = [CharityWidget(), ProgramsList(), WalletScreen()];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    var appState = AppModel.of(context);
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
    final image = user.photoUrl != null
        ? CachedNetworkImage(
            imageUrl: user.photoUrl,
            fit: BoxFit.scaleDown,
          )
        : Image.asset(
            'assets/images/default.png',
            fit: BoxFit.scaleDown,
          );
    final logoImage = ClipOval(
      child: image,
    );
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
                radius: 16,
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
            );
            menuTiles.add(terms);

            ListTile privacy = ListTile(
              leading: Icon(Icons.verified_user),
              title: Text(
                'Confidentialitate',
                style: titleStyle,
              ),
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
