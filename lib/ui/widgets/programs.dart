import 'dart:async';
import 'package:async/async.dart';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/settings.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/widgets/shop.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProgramsList extends StatefulWidget {
  final ShopsService shopsService;
  final SearchServiceBase searchService;

  ProgramsList({
    Key key,
    @required this.shopsService,
    @required this.searchService,
  }) : super(key: key);

  _ProgramsListState createState() => _ProgramsListState();
}

class _ProgramsListState extends State<ProgramsList>
    with AutomaticKeepAliveClientMixin {
  AppModel _appState;
  bool _onlyFavorites = false;
  String _category;
  Completer<Null> _loadingCompleter = Completer<Null>();
  AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget categoriesButton = _buildCategoriesButton(context);
    Widget favoritesButton = _buildFavoritesButton(context);
    Widget searchButton = _buildSearchButton(context);
    Widget layoutButton = _buildLayoutButton(context);

    Widget toolbar = Container(
      child: Row(
        children: <Widget>[
          categoriesButton,
          favoritesButton,
          searchButton,
          layoutButton,
        ],
      ),
      color: Theme.of(context).accentColor,
    );

    return RefreshIndicator(
      onRefresh: () {
        _loadingCompleter = Completer<Null>();
        _appState.clearFavoriteShops();
        _appState.refreshPrograms().then((done) => setState(() {
              _loadingCompleter.complete();
              _asyncMemoizer = AsyncMemoizer();
            }));
        return _loadingCompleter.future;
      },
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          toolbar,
          FutureBuilder(
            future: _asyncMemoizer.runOnce(() => _appState.programsFuture),
            builder: (context, snapshot) {
              final loading = buildConnectionLoading(
                context: context,
                snapshot: snapshot,
              );
              if (loading != null) {
                return loading;
              }

              final List<Program> programs = List.of(snapshot.data);
              return Expanded(
                child: ShopsWidget(
                  key: Key('PrimaryProgramsList'),
                  appState: _appState,
                  programs: programs,
                  category: _category,
                  onlyFavorites: _onlyFavorites,
                  searchService: widget.searchService,
                  shopsService: widget.shopsService,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Expanded _buildSearchButton(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: Icon(Icons.search),
        color: Colors.white,
        onPressed: () {
          showSearch(
            context: context,
            delegate: ProgramsSearch(
              appState: _appState,
              searchService: widget.searchService,
              shopsService: widget.shopsService,
            ),
          );
        },
      ),
    );
  }

  Expanded _buildFavoritesButton(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: _onlyFavorites
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
        color: Colors.white,
        onPressed: () {
          setState(() {
            _onlyFavorites = !_onlyFavorites;
          });
          _scrollToTop(context);
        },
      ),
    );
  }

  Expanded _buildLayoutButton(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: _displayAsGrid
            ? const Icon(Icons.view_headline)
            : const Icon(Icons.view_module),
        color: Colors.white,
        onPressed: () {
          setState(() {
            var newSettings = _appState.settings;
            newSettings.displayMode =
                _displayAsGrid ? DisplayMode.LIST : DisplayMode.GRID;
            _appState.setSettings(newSettings, storeLocal: true);
          });
          _scrollToTop(context);
        },
      ),
    );
  }

  Expanded _buildCategoriesButton(BuildContext context) {
    return Expanded(
      child: FlatButton(
        child: Text(
          _category == null
              ? AppLocalizations.of(context).plural('category', 2)
              : _category,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          showDialog(context: context, builder: _categoriesDialogBuilder)
              .then((category) {
            if (category != null) {
              if (category == 'Toate' || category == 'All') {
                setState(() {
                  _category = null;
                });
              } else {
                setState(() {
                  _category = category;
                });
              }
              _scrollToTop(context);
            }
          });
        },
      ),
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

  Widget _categoriesDialogBuilder(BuildContext context) {
    List<Widget> categories = [
      _buildCategoryButton(context, AppLocalizations.of(context).tr('all')),
    ];
    categories.addAll(
      _appState.programsMeta.categories
          .map((c) => _buildCategoryButton(context, c))
          .toList(),
    );
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: categories,
    );
  }

  void _scrollToTop(BuildContext context) {
    ScrollController controller = PrimaryScrollController.of(context);
    controller.animateTo(
      controller.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  bool get wantKeepAlive => true;

  bool get _displayAsGrid => _appState.settings.displayMode == DisplayMode.GRID;
}

class ShopsWidget extends StatefulWidget {
  final List<Program> programs;
  final AppModel appState;
  final bool onlyFavorites;
  final String category;
  final ShopsService shopsService;
  final SearchServiceBase searchService;

  const ShopsWidget({
    Key key,
    @required this.programs,
    @required this.appState,
    this.onlyFavorites = false,
    this.category,
    @required this.shopsService,
    @required this.searchService,
  }) : super(key: key);

  @override
  _ShopsWidgetState createState() => _ShopsWidgetState();
}

class _ShopsWidgetState extends State<ShopsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      initialData: widget.appState.favoriteShops,
      stream: widget.shopsService.favoritePrograms,
      builder: (context, snapshot) {
        FavoriteShops favoriteShops = snapshot.data;
        widget.appState.setFavoriteShops(favoriteShops);

        final favoritePrograms = List.of(favoriteShops.programs).toList();
        return StreamBuilder<ProgramMeta>(
          stream: metaService.programsMetaStream,
          builder: (context, snapshot) {
            return _buildShopList(
              widget.programs,
              widget.appState,
              favorites: favoritePrograms,
              onlyFavorites: widget.onlyFavorites,
              category: widget.category,
              overallRatings: snapshot.data?.ratings ?? {},
            );
          },
        );
      },
    );
  }

  Widget _buildShopList(
    List<Program> programs,
    AppModel appState, {
    bool onlyFavorites = false,
    List<Program> favorites = const [],
    String category,
    Map<String, OverallRating> overallRatings,
  }) {
    programs.forEach((p) {
      if (favorites.firstWhere(
            (f) => f.uniqueCode == p.uniqueCode,
            orElse: () => null,
          ) !=
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

    bool displayAsGrid = appState.settings.displayMode == DisplayMode.GRID;

    int itemCount =
        displayAsGrid ? (programs.length / 2).ceil() : programs.length;

    return ListView.builder(
      key: Key('ProgramsListView${widget.key.toString()}'),
      addAutomaticKeepAlives: true,
      shrinkWrap: true,
      primary: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        int rangeStart = displayAsGrid ? index * 2 : index;
        List<Program> programsToDisplay = programs
            .skip(rangeStart)
            .take(displayAsGrid ? 2 : 1)
            .map((p) => _prepareProgram(appState, p, overallRatings))
            .toList();

        return Row(
          children: programsToDisplay
              .map(
                (p) => Expanded(
                  child: displayAsGrid
                      ? ShopHalfTile(
                          key: Key(p.uniqueCode),
                          program: p,
                          userId: appState.user.userId,
                          shopsService: widget.shopsService,
                        )
                      : ShopFullTile(
                          key: Key(p.uniqueCode),
                          program: p,
                          userId: appState.user.userId,
                          shopsService: widget.shopsService,
                        ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Program _prepareProgram(
    AppModel appState,
    Program program,
    Map<String, OverallRating> overallRatings,
  ) {
    final userPercentage = appState.affiliateMeta.percentage;
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
    if (overallRatings.containsKey(program.uniqueCode)) {
      program.rating = overallRatings[program.uniqueCode];
    }

    return program;
  }

  @override
  bool get wantKeepAlive => true;
}

class ProgramsSearch extends SearchDelegate<String> {
  final AppModel appState;
  bool _exactMatch = false;
  AsyncMemoizer _asyncMemoizer = AsyncMemoizer();
  String _previousQuery;
  bool _previousExact;
  final ShopsService shopsService;
  final SearchServiceBase searchService;

  ProgramsSearch({
    this.appState,
    @required this.shopsService,
    @required this.searchService,
  });

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
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          handleError: false,
        );
        if (loading != null) {
          return loading;
        }

        List<Program> programs;
        if (snapshot.hasError || _exactMatch) {
          programs = appState.programs
              .where((p) =>
                  _exactMatch ? p.name == query : p.name.startsWith(query))
              .toList();
        } else {
          programs = List.of(snapshot.data);
        }
        return ShopsWidget(
          programs: programs,
          appState: appState,
          searchService: searchService,
          shopsService: shopsService,
        );
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
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          handleError: false,
        );
        if (loading != null) {
          return loading;
        }

        List<Widget> suggestions;
        if (snapshot.hasError) {
          suggestions = appState.programs
              .where((p) =>
                  _exactMatch ? p.name == query : p.name.startsWith(query))
              .map((p) => Suggestion(name: p.name, query: query))
              .map((Suggestion hit) => _buildSuggestionWidget(hit, context))
              .toList();
        } else {
          var map = snapshot.data.map(
            (Suggestion hit) => _buildSuggestionWidget(hit, context),
          );
          suggestions = List<Widget>.from(
            map,
          );
        }

        return ListView(
          children: suggestions,
          shrinkWrap: true,
          primary: false,
        );
      },
    );
  }

  Widget _buildSuggestionWidget(Suggestion hit, BuildContext context) =>
      InkWell(
        onTap: () {
          query = hit.name;
          _exactMatch = true;
          showResults(context);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: RichText(
            text: TextSpan(
              text: hit.query,
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: hit.name.split(hit.query)[1],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: DefaultTextStyle.of(context).style.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
