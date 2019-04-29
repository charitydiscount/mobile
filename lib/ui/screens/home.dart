import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:charity_discount/models/state.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/ui/screens/sign_in.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/profile.dart';
import 'package:charity_discount/ui/widgets/charity.dart';
import 'package:charity_discount/ui/widgets/shops.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  int _selectedNavIndex = 0;
  final _widgets = [CharityWidget(), Shops(), Profile()];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).getState();
    var data = EasyLocalizationProvider.of(context).data;
    if (!appState.isLoading &&
        (appState.user == null ||
            appState.user.userId == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }

      return EasyLocalizationProvider(
          data: data,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    title: Text(AppLocalizations.of(context).tr('charity'))),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_shopping_cart),
                    title: Text(AppLocalizations.of(context).tr('shops'))),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    title: Text(AppLocalizations.of(context).tr('profile'))),
              ],
              currentIndex: _selectedNavIndex,
              fixedColor: Colors.red,
              onTap: _onItemTapped,
            ),
            body: LoadingScreen(
                child: _widgets.elementAt(_selectedNavIndex),
                inAsyncCall: _loadingVisible),
          ));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }
}
