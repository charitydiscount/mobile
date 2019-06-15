import 'package:async/async.dart';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/util/url.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/shop.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rxdart/rxdart.dart';

class Shops extends StatefulWidget {
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> with AutomaticKeepAliveClientMixin {
  bool _loadingVisible = false;
  final _perPage = 50;
  Completer<Null> _loadingCompleter = Completer<Null>();
  List<Observable<List<models.Program>>> _marketStreams = List();
  List<BehaviorSubject<List<models.Program>>> _marketSubjects = List();
  ProgramMeta _meta = ProgramMeta(count: 0, categories: []);
  ShopsService _service;
  List<models.Program> _favoritePrograms;
  StreamSubscription _favListener;

  int _totalPages = 1;
  AppModel _appState;
  bool _onlyFavorites = false;
  String _category;

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);
    _service = getShopsService(_appState.user.userId);
    _favListener = _service.favoritePrograms.listen((favShops) {
      setState(() {
        _favoritePrograms = favShops.programs;
      });
    });
    metaService.getProgramsMeta().then((pMeta) {
      _meta = pMeta;
      _displayNextPrograms(1);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _clearMarketStreams();
    _service.refreshCache();
    _favListener.cancel();
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

    if (_marketSubjects.length < pageNumber) {
      return null;
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
          placeholders.addAll(
            List.generate(
              _perPage,
              (int index) => Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Placeholder(
                        fallbackHeight: 100.0,
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
            ),
          );
          return ListView(
              primary: false, shrinkWrap: true, children: placeholders);
        }
        if (!_loadingCompleter.isCompleted) {
          _loadingCompleter.complete();
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }

        final List<models.Program> programs = List.of(snapshot.data);

        return ShopsWidget(
          key: Key(pageNumber.toString()),
          appState: _appState,
          programs: programs,
          category: _category,
          onlyFavorites: _onlyFavorites,
        );
      },
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category) {
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
    List<Widget> categories = [
      _buildCategoryButton(context, 'Toate'),
    ];
    categories.addAll(
      _meta.categories.map((c) => _buildCategoryButton(context, c)).toList(),
    );
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: categories,
    );
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
            _totalPages = 1;
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

    Widget searchButton = Expanded(
      child: IconButton(
        icon: Icon(Icons.search),
        color: Colors.white,
        onPressed: () {
          showSearch(
            context: context,
            delegate: ProgramsSearch(appState: _appState),
          );
        },
      ),
    );

    Widget toolbar = Container(
      child: Row(
        children: <Widget>[
          categoriesButton,
          favoritesButton,
          searchButton,
        ],
      ),
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
      inAsyncCall: _loadingVisible,
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _displayNextPrograms(int page) {
    if (page == 1) {
      _service.refreshCache();
      _clearMarketStreams();
      setState(() {
        _totalPages = 1;
      });
    }
    if (_category == null) {
      _addMarketStream(_service.getPrograms());
    } else {
      _addMarketStream(_service.getProgramsForCategory(_category));
    }
  }

  void _displayFavoritePrograms() {
    _clearMarketStreams();
    _addMarketStream(BehaviorSubject.seeded(_favoritePrograms));
  }

  void _addMarketStream(Observable<List<models.Program>> programsObs) {
    _marketSubjects.add(BehaviorSubject());
    int subjectIndex = _marketSubjects.length;
    _marketStreams.add(programsObs);
    _marketStreams.last.listen((market) {
      if (mounted != true) {
        return null;
      }
      if (_totalPages == 1) {
        if (market.length == 0) {
          setState(() {
            _totalPages = 0;
          });
        } else {
          if (_meta.count > market.length && _category == null) {
            setState(() {
              _totalPages = (_meta.count / market.length).ceil();
            });
          } else {
            if (_totalPages != 1) {
              setState(() {
                _totalPages = 1;
              });
            }
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

class ProgramsSearch extends SearchDelegate<String> {
  final AppModel appState;
  bool _exactMatch = false;
  AsyncMemoizer _asyncMemoizer = AsyncMemoizer();
  String _previousQuery;
  bool _previousExact;

  ProgramsSearch({this.appState});

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData appTheme = Theme.of(context);
    return appTheme.copyWith(
      textTheme: appTheme.textTheme.copyWith(
        title: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query == '' || query == null) {
      return Container();
    }

    if (query != _previousQuery || _exactMatch != _previousExact) {
      _asyncMemoizer = AsyncMemoizer();
    }

    _previousQuery = query;
    _previousExact = _exactMatch;

    return FutureBuilder(
      future: _asyncMemoizer.runOnce(
        () => searchService.search(query, exact: _exactMatch),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).accentColor),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Text('No data available');
        }

        final List<models.Program> programs = List.of(snapshot.data);
        return ShopsWidget(programs: programs, appState: appState);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == '' || query == null) {
      return Container();
    }
    _exactMatch = false;
    return FutureBuilder(
      initialData: [],
      future: searchService.getSuggestions(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).accentColor),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Text('No data available');
        }

        List<Widget> suggestions = List<Widget>.from(
          snapshot.data.map(
            (hit) => InkWell(
                  onTap: () {
                    query = hit.name;
                    _exactMatch = true;
                    showResults(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Html(data: hit.formattedName),
                  ),
                ),
          ),
        );

        return ListView(
          children: suggestions,
          shrinkWrap: true,
          primary: false,
        );
      },
    );
  }
}

class ShopsWidget extends StatelessWidget {
  final List<models.Program> programs;
  final AppModel appState;
  final bool onlyFavorites;
  final String category;

  const ShopsWidget({
    Key key,
    this.programs,
    this.appState,
    this.onlyFavorites = false,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: [],
      stream: getShopsService(appState.user.userId).favoritePrograms,
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasData == false) {
          return Container();
        }

        FavoriteShops favoriteShops = snapshot.data;
        final favoritePrograms = List.of(favoriteShops.programs);
        return _buildShopList(
          programs,
          appState,
          favorites: favoritePrograms,
          onlyFavorites: onlyFavorites,
          category: category,
        );
      },
    );
  }

  ListView _buildShopList(
    List<models.Program> programs,
    AppModel appState, {
    bool onlyFavorites = false,
    List<models.Program> favorites = const [],
    String category,
  }) {
    programs.forEach((p) {
      if (favorites.firstWhere((f) => f.uniqueCode == p.uniqueCode,
              orElse: () => null) !=
          null) {
        p.favorited = true;
      } else {
        p.favorited = false;
      }
    });

    if (onlyFavorites == true) {
      programs.removeWhere((p) => p.favorited != true);
    }

    if (category != null) {
      programs.removeWhere((p) => p.category != category);
    }

    programs.sort((p1, p2) => p1.name.compareTo(p2.name));

    final userPercentage = appState.affiliateMeta.percentage;
    programs.forEach((program) {
      program.leadCommissionAmount = program.defaultLeadCommissionAmount != null
          ? (program.defaultLeadCommissionAmount * userPercentage)
              .toStringAsFixed(2)
          : null;
      program.saleCommissionRate = program.defaultSaleCommissionRate != null
          ? (program.defaultSaleCommissionRate * userPercentage)
              .toStringAsFixed(2)
          : null;
      program.affilitateUrl = convertAffiliateUrl(
          program.mainUrl,
          appState.affiliateMeta.uniqueCode,
          program.uniqueCode,
          appState.user.userId);
    });

    final List<Widget> shopWidgets = programs
        .map(
          (p) => ShopWidget(
                key: Key(p.uniqueCode),
                program: p,
                userId: appState.user.userId,
              ),
        )
        .toList();
    return ListView(
      key: Key('ProgramsListView${key.toString()}'),
      addAutomaticKeepAlives: true,
      children: shopWidgets,
      shrinkWrap: true,
      primary: false,
    );
  }
}
