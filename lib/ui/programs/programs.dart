import 'dart:async';
import 'package:async/async.dart';
import 'package:charity_discount/models/favorite_shops.dart';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/suggestion.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/programs/shop.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';

class ProgramsList extends StatefulWidget {
  ProgramsList({Key key}) : super(key: key);

  _ProgramsListState createState() => _ProgramsListState();
}

class _ProgramsListState extends State<ProgramsList>
    with AutomaticKeepAliveClientMixin {
  AppModel _appState;
  bool _onlyFavorites = false;
  String _category;
  Completer<Null> _loadingCompleter = Completer<Null>();
  AsyncMemoizer _asyncMemoizer = AsyncMemoizer();
  _SortStrategy _sortStrategy = _SortStrategy.relevance;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _appState = AppModel.of(context);
    locator<ShopsService>().listenToFavShops();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget toolbar = Container(
      child: Row(
        children: <Widget>[
          _buildCategoriesButton(context),
          _buildSortButton(context),
          locator<AuthService>().isActualUser()
              ? _buildFavoritesButton(context)
              : Container(
                  width: 0,
                  height: 0,
                ),
          _buildSearchButton(context),
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
                  sortStrategy: _sortStrategy,
                  scrollController: _scrollController,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      color: Colors.white,
      onPressed: () {
        showSearch(
          context: context,
          delegate: ProgramsSearch(appState: _appState),
        );
      },
    );
  }

  Widget _buildFavoritesButton(BuildContext context) {
    return IconButton(
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
    );
  }

  Expanded _buildCategoriesButton(BuildContext context) {
    return Expanded(
      child: FlatButton(
        child: Text(
          _category == null ? plural('category', 2) : _category,
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

  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<_SortStrategy>(
      icon: const Icon(
        Icons.sort,
        color: Colors.white,
      ),
      onSelected: (_SortStrategy sortStrategy) {
        setState(() {
          _sortStrategy = sortStrategy;
        });
      },
      itemBuilder: (context) => <PopupMenuEntry<_SortStrategy>>[
        PopupMenuItem<_SortStrategy>(
          value: _SortStrategy.relevance,
          child: Text(tr('sort.relevance')),
        ),
        PopupMenuItem<_SortStrategy>(
          value: _SortStrategy.aToZ,
          child: Text(tr('sort.aToZ')),
        ),
        PopupMenuItem<_SortStrategy>(
          value: _SortStrategy.zToA,
          child: Text(tr('sort.zToA')),
        ),
        PopupMenuItem<_SortStrategy>(
          value: _SortStrategy.commissionAscending,
          child: Text(tr('sort.commissionAsc')),
        ),
        PopupMenuItem<_SortStrategy>(
          value: _SortStrategy.commissionDescending,
          child: Text(tr('sort.commissionDesc')),
        ),
      ],
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
      _buildCategoryButton(context, tr('all')),
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
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

enum _SortStrategy {
  aToZ,
  zToA,
  commissionAscending,
  commissionDescending,
  relevance
}

class ShopsWidget extends StatefulWidget {
  final List<Program> programs;
  final AppModel appState;
  final bool onlyFavorites;
  final String category;
  final _SortStrategy sortStrategy;
  final ScrollController scrollController;

  const ShopsWidget({
    Key key,
    @required this.programs,
    @required this.appState,
    this.onlyFavorites = false,
    this.category,
    this.sortStrategy = _SortStrategy.relevance,
    this.scrollController,
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
      stream: locator<ShopsService>().favoritePrograms,
      builder: (context, snapshot) {
        FavoriteShops favoriteShops = snapshot.data;
        widget.appState.setFavoriteShops(favoriteShops);

        final favoritePrograms = favoriteShops.programs;
        return StreamBuilder<ProgramMeta>(
          stream: locator<MetaService>().programsMetaStream,
          builder: (context, snapshot) {
            return _buildShopList(
              List.of(widget.programs),
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

  int Function(Program p1, Program p2) get _getSortingFunction {
    switch (widget.sortStrategy) {
      case _SortStrategy.aToZ:
        return (p1, p2) =>
            p1.name.toLowerCase().compareTo(p2.name.toLowerCase());
      case _SortStrategy.zToA:
        return (p1, p2) =>
            p2.name.toLowerCase().compareTo(p1.name.toLowerCase());
      case _SortStrategy.commissionAscending:
        return (p1, p2) =>
            p1.defaultSaleCommissionRate
                ?.compareTo(p2.defaultSaleCommissionRate ?? 0) ??
            1;
      case _SortStrategy.commissionDescending:
        return (p1, p2) =>
            p2.defaultSaleCommissionRate
                ?.compareTo(p1.defaultSaleCommissionRate ?? 0) ??
            1;
      default:
        return (p1, p2) => 0;
    }
  }

  Widget _buildShopList(
    List<Program> programs,
    AppModel appState, {
    bool onlyFavorites = false,
    Map<String, Program> favorites,
    String category,
    Map<String, OverallRating> overallRatings,
  }) {
    programs.forEach((p) {
      if (favorites.containsKey(p.uniqueCode)) {
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

    if (widget.sortStrategy != _SortStrategy.relevance) {
      programs.sort(_getSortingFunction);
    }

    return GridView.builder(
      key: Key('ProgramsGridView${widget.key.toString()}'),
      shrinkWrap: true,
      gridDelegate: getGridDelegate(context),
      itemCount: programs.length,
      controller: widget.scrollController,
      itemBuilder: (context, index) {
        Program programForDisplay = _prepareProgram(
          appState,
          programs.elementAt(index),
          overallRatings,
        );
        return ShopHalfTile(
          key: Key(programForDisplay.uniqueCode),
          program: programForDisplay,
        );
      },
    );
  }

  Program _prepareProgram(
    AppModel appState,
    Program program,
    Map<String, OverallRating> overallRatings,
  ) {
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

  ProgramsSearch({this.appState});

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData appTheme = Theme.of(context);
    return appTheme.copyWith(
      textTheme: appTheme.textTheme.copyWith(
        headline6: TextStyle(color: Colors.white),
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

    List<Program> programs = appState.programs
        .where((p) => _exactMatch
            ? p.name.toLowerCase() == query.toLowerCase()
            : p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ShopsWidget(programs: programs, appState: appState);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == '' || query == null) {
      return Container();
    }
    _exactMatch = false;

    List<Program> suggestedPrograms = appState.programs
        .where((p) => _exactMatch
            ? p.name.toLowerCase() == query.toLowerCase()
            : p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    List<Widget> suggestions = suggestedPrograms
        .map((p) =>
            Suggestion(name: p.name.toLowerCase(), query: query.toLowerCase()))
        .map((Suggestion hit) => _buildSuggestionWidget(hit, context))
        .toList();

    return ListView(
      children: suggestions,
      shrinkWrap: true,
      primary: false,
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
          child: SubstringHighlight(
            text: hit.name,
            term: hit.query,
            textStyle: TextStyle(
              color: Colors.grey,
            ),
            textStyleHighlight: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
}
