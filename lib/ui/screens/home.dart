import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/wallet.dart';
import 'package:charity_discount/ui/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/charity.dart';
import 'package:charity_discount/ui/widgets/shops.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loadingVisible = false;
  int _selectedNavIndex = 0;
  final _widgets = [CharityWidget(), Shops(), WalletScreen()];

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
          _buildProfileButton(photoUrl: appState.user.photoUrl),
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

  Widget _buildProfileButton({String photoUrl}) {
    final logoImage = photoUrl != null
        ? CachedNetworkImage(
            imageUrl: photoUrl,
            fit: BoxFit.contain,
          )
        : Image.asset(
            'assets/images/default.png',
            fit: BoxFit.scaleDown,
          );
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ProfileScreen(),
            settings: RouteSettings(name: 'Profile'),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ClipOval(child: logoImage),
      ),
    );
  }
}
