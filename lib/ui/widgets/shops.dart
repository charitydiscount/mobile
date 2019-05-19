import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/services/shops.dart';
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

  int _totalPages;
  AppModel _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);
    getShopsService(_appState.user.userId).getProgramsMeta().then((pMeta) {
      meta = pMeta;
    });
    _addMarketStream(1);
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
              getShopsService(_appState.user.userId).refreshCache();
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
    int subjectIndex = _marketSubjects.length;
    _marketStreams
        .add(getShopsService(_appState.user.userId).getProgramsFull());
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
