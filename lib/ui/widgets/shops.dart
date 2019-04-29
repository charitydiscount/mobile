import 'package:flutter/material.dart';
import 'dart:async';
import 'package:charity_discount/models/market.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/shop.dart';
import 'package:charity_discount/services/affiliate.dart';

class Shops extends StatefulWidget {
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> with AutomaticKeepAliveClientMixin {
  bool _loadingVisible = false;
  final _perPage = 10;
  Completer<Null> _loadingCompleter = Completer<Null>();
  int _totalPages;

  @override
  void initState() {
    super.initState();
  }

  Widget _loadPrograms(int pageNumber) {
    if (_totalPages != null && pageNumber > _totalPages) {
      return null;
    }
    return FutureBuilder<Market>(
      future: affiliateService.getMarket(page: pageNumber, perPage: _perPage),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView(
              primary: false,
              shrinkWrap: true,
              children: List.generate(
                  _perPage,
                  (int index) => Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Placeholder(
                        fallbackHeight: 100.0,
                        color: Colors.white,
                      ))));
        }
        if (!_loadingCompleter.isCompleted) {
          _loadingCompleter.complete();
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }

        _totalPages = snapshot.data.metadata.pagination.pages;

        final List<Program> programs = snapshot.data.programs;

        if (programs.length == 0) {
          return Container(width: 0, height: 0);
        }

        final List<Widget> shopWidgets =
            programs.map((p) => ShopWidget(program: p)).toList();
        return ListView(
            children: shopWidgets, shrinkWrap: true, primary: false);
      },
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    return LoadingScreen(
        child: RefreshIndicator(
            onRefresh: () {
              _loadingCompleter = Completer<Null>();
              setState(() {});
              return _loadingCompleter.future;
            },
            color: Colors.red,
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              primary: true,
              itemCount: _totalPages,
              addAutomaticKeepAlives: true,
              itemBuilder: (context, pageIndex) => _loadPrograms(pageIndex + 1),
            )),
        inAsyncCall: _loadingVisible);
  }

  @override
  bool get wantKeepAlive => true;
}
