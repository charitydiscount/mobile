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
  ProgramMeta _meta = ProgramMeta(count: 0, categories: []);
  ShopsService _service;

  int _totalPages = 1;
  AppModel _appState;
  bool _onlyFavorites = false;
  String _category;

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);
    _service = getShopsService(_appState.user.userId);
    metaService.getProgramsMeta().then((pMeta) {
      _meta = pMeta;
      _displayNextPrograms(1);
    });
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

    if (_marketStreams.length == 0) {
      return null;
    }

    if (_onlyFavorites == false && _marketStreams.length < pageNumber) {
      _displayNextPrograms(pageNumber);
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
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).accentColor),
                ),
              ),
            )
          ];
          placeholders.addAll(List.generate(
              _perPage,
              (int index) => Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Placeholder(
                      fallbackHeight: 100.0,
                      color: Theme.of(context).scaffoldBackgroundColor))));
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

        if (_onlyFavorites == true) {
          programs.removeWhere((p) => p.favorited != true);
        }

        if (_category != null) {
          programs.removeWhere((p) => p.category != _category);
        }

        if (programs.length == 0) {
          return Container(width: 0, height: 0);
        }

        programs.sort((p1, p2) => p1.name.compareTo(p2.name));

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

  Widget _buildCategoryButton(context, category) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: FlatButton(
        child: Text(category),
        onPressed: () {
          Navigator.pop(context, category);
        },
      ),
    );
  }

  Widget _dialogBuilder(BuildContext context) {
    List<Widget> categories = [_buildCategoryButton(context, 'Toate')];
    categories.addAll(
        _meta.categories.map((c) => _buildCategoryButton(context, c)).toList());
    return SimpleDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: categories);
  }

  Widget build(BuildContext context) {
    super.build(context);
    Widget categoriesButton = Expanded(
      child: FlatButton(
        child: Text(
          _category == null ? 'Categorii' : _category,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          showDialog(context: context, builder: _dialogBuilder)
              .then((category) {
            if (category != null) {
              if (category == 'Toate' || category == 'All') {
                _category = null;
              } else {
                _category = category;
              }
              var controller = PrimaryScrollController.of(context);
              controller.animateTo(
                controller.position.minScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
              _displayNextPrograms(1);
            }
          });
        },
      ),
    );
    Widget favoritesButton = Expanded(
      child: IconButton(
        icon: _onlyFavorites
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
        color: Colors.white,
        onPressed: () {
          setState(() {
            _onlyFavorites = !_onlyFavorites;
          });
          var controller = PrimaryScrollController.of(context);
          controller.animateTo(
            controller.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          if (_onlyFavorites == true) {
            _displayFavoritePrograms();
          } else {
            _displayNextPrograms(1);
          }
        },
      ),
    );

    Widget toolbar = Container(
      child: Row(children: <Widget>[categoriesButton, favoritesButton]),
      color: Theme.of(context).accentColor,
    );

    return LoadingScreen(
        child: RefreshIndicator(
          onRefresh: () {
            _loadingCompleter = Completer<Null>();
            _service.refreshCache();
            setState(() {});
            return _loadingCompleter.future;
          },
          color: Theme.of(context).primaryColor,
          child: Column(
            children: [
              toolbar,
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  primary: true,
                  itemCount: _totalPages,
                  shrinkWrap: true,
                  itemBuilder: (context, pageIndex) =>
                      _loadPrograms(pageIndex + 1),
                ),
              )
            ],
          ),
        ),
        inAsyncCall: _loadingVisible);
  }

  @override
  bool get wantKeepAlive => true;

  void _displayNextPrograms(int page) {
    if (page == 1) {
      _service.refreshCache();
      _totalPages = 1;
      _clearMarketStreams();
      setState(() {});
    }
    if (_category == null) {
      _addMarketStream(_service.getProgramsFull());
    } else {
      _addMarketStream(_service.getProgramsForCategory(_category));
    }
  }

  void _displayFavoritePrograms() {
    _clearMarketStreams();
    _totalPages = 1;
    _addMarketStream(
        _service.favoritePrograms.asyncMap((favShop) => favShop.programs));
  }

  void _addMarketStream(Observable<List<models.Program>> programsObs) {
    _marketSubjects.add(BehaviorSubject());
    int subjectIndex = _marketSubjects.length;
    _marketStreams.add(programsObs);
    _marketStreams.last.listen((market) {
      if (_totalPages == 1) {
        if (market.length == 0) {
          _totalPages = 0;
        } else {
          if (_meta.count < market.length) {
            _totalPages = (_meta.count / market.length).ceil();
          }
        }
      }
      _marketSubjects[subjectIndex - 1].add(market);
    });
  }

  void _clearMarketStreams() {
    _marketSubjects.clear();
    _marketStreams.clear();
  }
}
