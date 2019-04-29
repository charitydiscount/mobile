import 'package:flutter/material.dart';
import 'package:charity_discount/models/state.dart';
import 'package:charity_discount/models/market.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/shop.dart';
import 'package:charity_discount/services/affiliate.dart';

class Shops extends StatefulWidget {
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  StateModel appState;
  bool _loadingVisible = false;
  Future<Market> _market = affiliateService.getMarket();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).getState();

    _loadingVisible = true;

    final shopsBuilder = FutureBuilder<Market>(
      future: _market,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            backgroundColor: Colors.black,
          );
        }

        final shopWidgets =
            snapshot.data.programs.map((p) => ShopWidget(program: p)).toList();
        return RefreshIndicator(
            onRefresh: () {
              final marketFuture = affiliateService.getMarket();
              setState(() {
                _market = marketFuture;
              });
              return marketFuture;
            },
            color: Colors.red,
            child: ListView(children: shopWidgets, shrinkWrap: true));
      },
    );

    _loadingVisible = false;

    return LoadingScreen(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[shopsBuilder],
          ),
        ),
        inAsyncCall: _loadingVisible);
  }
}
