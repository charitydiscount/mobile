import 'package:charity_discount/services/shops.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:charity_discount/models/market.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/shop.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:rxdart/rxdart.dart';

class Shops extends StatefulWidget {
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> with AutomaticKeepAliveClientMixin {
  bool _loadingVisible = false;
  final _perPage = 10;
  Completer<Null> _loadingCompleter = Completer<Null>();
  List<Observable<Market>> _marketStreams = List();
  List<BehaviorSubject<Market>> _marketSubjects = List();
  int _totalPages;
  AppModel _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);

    _addMarketStream(1);
  }

  Widget _loadPrograms(int pageNumber) {
    if (_totalPages != null && pageNumber > _totalPages) {
      return null;
    }

    if (_marketStreams.length < pageNumber) {
      _addMarketStream(pageNumber);
    }

    return StreamBuilder<Market>(
      stream: _marketSubjects[pageNumber - 1],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          List<Widget> placeholders = [
            Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                )))
          ];
          placeholders.addAll(List.generate(
              _perPage,
              (int index) => Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Placeholder(
                    fallbackHeight: 100.0,
                    color: Colors.white,
                  ))));
          return ListView(
              primary: false, shrinkWrap: true, children: placeholders);
        }
        if (!_loadingCompleter.isCompleted) {
          _loadingCompleter.complete();
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }

        final List<Program> programs = snapshot.data.programs;

        if (programs.length == 0) {
          return Container(width: 0, height: 0);
        }

        final List<Widget> shopWidgets = programs
            .map((p) => ShopWidget(
                key: Key(p.uniqueCode),
                program: p,
                userId: _appState.user.userId))
            .toList();
        return ListView(
            key: Key(pageNumber.toString()),
            children: shopWidgets,
            shrinkWrap: true,
            primary: false);
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

  void _addMarketStream(int page) {
    _marketSubjects.add(BehaviorSubject());
    _marketStreams.add(
        getShopsService(_appState.user.userId).getShopsFull(page, _perPage));
    _marketStreams.last.listen((market) {
      _totalPages = market.metadata.pagination.pages;
      _marketSubjects[market.metadata.pagination.currentPage - 1].add(market);
    });
  }
}
