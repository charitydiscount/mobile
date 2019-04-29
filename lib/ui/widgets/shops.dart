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

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).getState();

    if (appState.isLoading) {
      _loadingVisible = true;
    } else {
      _loadingVisible = false;
    }

    final shopsBuilder = FutureBuilder<Market>(
      future: affiliateService.getMarket(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shopWidgets =
              snapshot.data.programs.map((p) => ShopWidget(program: p)).toList();
          return Column(mainAxisSize: MainAxisSize.min, children: shopWidgets);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner
        return CircularProgressIndicator();
      },
    );

    return LoadingScreen(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              shopsBuilder
            ],
          ),
        ),
        inAsyncCall: _loadingVisible);
  }
}
