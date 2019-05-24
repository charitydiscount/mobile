import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/util/url.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:charity_discount/models/program.dart' as models;
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
  List<Observable<List<models.Program>>> _marketStreams = List();
  List<BehaviorSubject<List<models.Program>>> _marketSubjects = List();
  ProgramMeta meta = ProgramMeta(count: 0, categories: []);
  ShopsService _service;

  int _totalPages;
  AppModel _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);
    _service = getShopsService(_appState.user.userId);
    metaService.getProgramsMeta().then((pMeta) {
      meta = pMeta;
    });
    _addMarketStream(1);
  }

  @override
  void dispose() {
    super.dispose();
    _service.refreshCache();
  }

  Widget _loadPrograms(int pageNumber) {
    if (_totalPages != null && pageNumber > _totalPages) {
      return null;
    }

    if (_marketStreams.length < pageNumber) {
      _addMarketStream(pageNumber);
    }

    return StreamBuilder<List<models.Program>>(
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

        final List<models.Program> programs = snapshot.data;

        final userPercentage = _appState.affiliateMeta.percentage;
        programs.forEach((program) {
          program.leadCommissionAmount =
              program.defaultLeadCommissionAmount != null
                  ? (program.defaultLeadCommissionAmount * userPercentage)
                      .toStringAsFixed(2)
                  : null;
          program.saleCommissionRate = program.defaultSaleCommissionRate != null
              ? (program.defaultSaleCommissionRate * userPercentage)
                  .toStringAsFixed(2)
              : null;
          program.affilitateUrl = convertAffiliateUrl(
              program.mainUrl,
              _appState.affiliateMeta.uniqueCode,
              program.uniqueCode,
              _appState.user.userId);
        });

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
            addAutomaticKeepAlives: true,
            primary: false);
      },
    );
  }

  Widget build(BuildContext context) {
    super.build(context);

    Widget categoriesButton = Expanded(
        child: FlatButton(
      child: const Text(
        'Categorii',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {/* ... */},
    ));
    Widget favoritesButton = Expanded(
        child: IconButton(
      icon: const Icon(Icons.favorite),
      color: Colors.white,
      onPressed: () {},
    ));

    Widget toolbar = Container(
      child: Row(children: <Widget>[categoriesButton, favoritesButton]),
      color: Colors.redAccent.shade700,
    );

    return LoadingScreen(
        child: RefreshIndicator(
            onRefresh: () {
              _loadingCompleter = Completer<Null>();
              _service.refreshCache();
              setState(() {});
              return _loadingCompleter.future;
            },
            color: Colors.red,
            child: Column(children: [
              toolbar,
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                primary: true,
                itemCount: _totalPages,
                addAutomaticKeepAlives: true,
                itemBuilder: (context, pageIndex) =>
                    _loadPrograms(pageIndex + 1),
              ))
            ])),
        inAsyncCall: _loadingVisible);
  }

  @override
  bool get wantKeepAlive => true;

  void _addMarketStream(int page) {
    _marketSubjects.add(BehaviorSubject());
    int subjectIndex = _marketSubjects.length;
    _marketStreams.add(_service.getProgramsFull());
    _marketStreams.last.listen((market) {
      if (_totalPages == null) {
        if (market.length == 0) {
          _totalPages = 0;
        } else {
          _totalPages = (meta.count / market.length).ceil();
        }
      }
      _marketSubjects[subjectIndex - 1].add(market);
    });
  }
}
