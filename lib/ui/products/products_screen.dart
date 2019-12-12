import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter/services.dart';

class ProductsScreen extends StatefulWidget {
  final SearchServiceBase searchService;

  const ProductsScreen({Key key, @required this.searchService})
      : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _query = '';
  ScrollController _scrollController = ScrollController();
  TextEditingController _editingController = TextEditingController();
  AppModel _state;
  AsyncMemoizer<List<Product>> _featuredMemoizer = AsyncMemoizer();
  int _totalProducts = 1;
  int _perPage = 50;
  ScrollController _productsScrollController;
  List<Product> _products = [];
  bool _searchInitiated = false;
  _SortStrategy _sortStrategy = _SortStrategy.relevance;

  @override
  void initState() {
    super.initState();
    _state = AppModel.of(context);
    _productsScrollController = ScrollController();
    _productsScrollController.addListener(() {
      if (_searchInitiated == false && _products.length < _totalProducts) {
        if (_productsScrollController.position.pixels >
            0.9 * _productsScrollController.position.maxScrollExtent) {
          _searchInitiated = true;
          _searchProducts(_products.length);
        }
      }
    });
  }

  void _searchProducts(int from) {
    widget.searchService.searchProducts(_query, from: from).then(
          (searchResult) => setState(() {
            if (_products.length <= _perPage) {
              _totalProducts = searchResult.totalFound;
            }
            _products.addAll(_prepareProducts(searchResult.products));
            _searchInitiated = false;
          }),
        );
  }

  void _search() {
    if (_query.compareTo(_editingController.text) != 0) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {
        _query = _editingController.text ?? '';
        _products = [];
        _totalProducts = 1;
        _searchProducts(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget programs = _query.isEmpty ? _featuredProducts : _productsList;

    Widget searchInput = Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _editingController,
            onEditingComplete: _search,
            textInputAction: TextInputAction.search,
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              labelStyle: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle.fontSize,
              ),
              labelText:
                  AppLocalizations.of(context).tr('product.searchPlaceholder'),
              hasFloatingPlaceholder: false,
              suffixIcon: IconButton(
                icon: Icon(Icons.close),
                color: Colors.grey,
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _editingController.clear(),
                  );
                },
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search),
          color: Theme.of(context).primaryColor,
          onPressed: _search,
        ),
        _buildSortButton(context),
      ],
    );

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: searchInput,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            primary: false,
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
          ),
        ];
      },
      body: programs,
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final tr = AppLocalizations.of(context).tr;
    return PopupMenuButton<_SortStrategy>(
      icon: Icon(
        Icons.sort,
        color: Theme.of(context).primaryColor,
      ),
      onSelected: (_SortStrategy sortStrategy) {
        setState(() {
          _sortStrategy = sortStrategy;
        });
      },
      itemBuilder: (context) => <PopupMenuEntry<_SortStrategy>>[
        _buildMenuItem(_SortStrategy.relevance, tr('sort.relevance')),
        _buildMenuItem(_SortStrategy.priceAscending, tr('sort.priceAsc')),
        _buildMenuItem(_SortStrategy.priceDescending, tr('sort.priceDesc')),
      ],
    );
  }

  PopupMenuItem<_SortStrategy> _buildMenuItem(
          _SortStrategy value, String text) =>
      PopupMenuItem<_SortStrategy>(
        value: value,
        child: Text(text),
        textStyle: TextStyle(
            color: _sortStrategy == value
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.body1.color),
      );

  List<Product> _prepareProducts(Iterable<Product> products) => products
      .map((product) {
        final program = _state.programs.firstWhere(
              (program) => program.id == product.programId,
              orElse: () => null,
            ) ??
            _state.programs.firstWhere(
              (program) =>
                  program.uniqueCode.compareTo(product.programName) == 0,
              orElse: () => null,
            );
        if (program == null) {
          return null;
        }
        return product.copyWith(
          programLogo: program.logoPath,
          affiliateUrl: convertAffiliateUrl(
            product.url,
            _state.affiliateMeta.uniqueCode,
            program.uniqueCode,
            _state.user.userId,
          ),
        );
      })
      .where((product) => product != null)
      .toList();

  Widget get _featuredProducts => FutureBuilder<List<Product>>(
        future: _featuredMemoizer
            .runOnce(() => widget.searchService.getFeaturedProducts(
                  userId: _state.user.userId,
                )),
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          final loadingWidget = buildConnectionLoading(
            snapshot: snapshot,
            context: context,
          );
          if (loadingWidget != null) {
            return loadingWidget;
          }

          List products = _prepareProducts(snapshot.data);
          final productsWidget = products.map(
            (product) => ProductCard(product: product),
          );

          return ListView.builder(
            shrinkWrap: true,
            primary: true,
            itemCount:
                productsWidget.length > 1 ? productsWidget.length ~/ 2 : 1,
            itemBuilder: (context, index) => IntrinsicHeight(
              child: Row(
                children: productsWidget.skip(index * 2).take(2).toList(),
              ),
            ),
          );
        },
      );

  Widget get _productsList => ListView.builder(
        shrinkWrap: true,
        primary: false,
        controller: _productsScrollController,
        itemCount: _products.length > 1 ? _products.length ~/ 2 : 1,
        itemBuilder: (context, index) => _products.length - 1 >= index
            ? IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    _getProductCard(index),
                    _getProductCard(index + 1),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).accentColor,
                  ),
                ),
              ),
      );

  Widget _getProductCard(index) => _products.length - 1 >= index
      ? ProductCard(product: _products[index])
      : Container();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _editingController.dispose();
    _productsScrollController.dispose();
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'productLogo-${product.id}',
      child: CachedNetworkImage(
        imageUrl: product.imageUrl,
        height: 80,
        fit: BoxFit.contain,
      ),
    );

    final shopLogo = CachedNetworkImage(
      imageUrl: product.programLogo,
      width: 40,
      fit: BoxFit.contain,
    );

    final linkButton = IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.add_shopping_cart),
      color: Theme.of(context).primaryColor,
      onPressed: () {
        launchURL(product.affiliateUrl);
      },
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: InkWell(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: logo),
                      shopLogo,
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    product.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            product.oldPrice != null &&
                                    product.price != null &&
                                    product.oldPrice > product.price
                                ? Text(
                                    '${product.oldPrice.toString()}RON',
                                    style: TextStyle(
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )
                                : Container(),
                            product.price != null
                                ? Center(
                                    child: Text(
                                      '${product.price.toString()}RON',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                    linkButton,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SortStrategy { priceAscending, priceDescending, relevance }
