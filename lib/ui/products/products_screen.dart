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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editingController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final _priceFormKey = GlobalKey<FormState>();
  ScrollController _productsScrollController;
  AppModel _state;
  AsyncMemoizer<List<Product>> _featuredMemoizer = AsyncMemoizer();
  int _totalProducts = 1;
  int _perPage = 50;
  List<Product> _products = [];
  bool _searchInitiated = false;
  SortStrategy _sortStrategy = SortStrategy.relevance;
  double _minPrice;
  double _maxPrice;

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
    widget.searchService
        .searchProducts(
          _query,
          from: from,
          sort: _sortStrategy,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
        )
        .then(
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
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        _query = _editingController.text ?? '';
        _initializeResult();
        _searchProducts(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget products = _query.isEmpty ? _featuredProducts : _productsList;

    Widget searchInput = Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _editingController,
            onEditingComplete: _search,
            textInputAction: TextInputAction.search,
            cursorColor: Theme.of(context).accentColor,
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
        _buildFilterButton(context),
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
            forceElevated: innerBoxIsScrolled || _query.isNotEmpty,
          ),
        ];
      },
      body: products,
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final tr = AppLocalizations.of(context).tr;
    return PopupMenuButton<SortStrategy>(
      icon: Icon(
        Icons.sort,
        color: Theme.of(context).accentColor,
      ),
      onSelected: (SortStrategy sortStrategy) {
        setState(() {
          _sortStrategy = sortStrategy;
          _initializeResult();
          _searchProducts(0);
        });
      },
      itemBuilder: (context) => <PopupMenuEntry<SortStrategy>>[
        _buildMenuItem(SortStrategy.relevance, tr('sort.relevance')),
        _buildMenuItem(SortStrategy.priceAsc, tr('sort.priceAsc')),
        _buildMenuItem(SortStrategy.priceDesc, tr('sort.priceDesc')),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            showDialog(context: context, builder: _filterDialogBuilder)
                .then((priceRange) {
              if (priceRange == null) {
                // Dialog was closed
                return;
              }
              if (_minPrice != priceRange['minPrice'] ||
                  _maxPrice != priceRange['maxPrice']) {
                setState(() {
                  _minPrice = priceRange['minPrice'];
                  _maxPrice = priceRange['maxPrice'];
                  _initializeResult();
                  _searchProducts(0);
                });
              }
            });
          },
        ),
        _minPrice != null || _maxPrice != null
            ? Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  PopupMenuItem<SortStrategy> _buildMenuItem(SortStrategy value, String text) =>
      PopupMenuItem<SortStrategy>(
        value: value,
        child: Text(text),
        textStyle: TextStyle(
          color: _sortStrategy == value
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.body1.color,
        ),
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

          return GridView.builder(
            shrinkWrap: true,
            primary: true,
            gridDelegate: getGridDelegate(context),
            itemCount: productsWidget.length,
            itemBuilder: (context, index) => productsWidget.elementAt(index),
          );
        },
      );

  Widget get _productsList {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      controller: _productsScrollController,
      addAutomaticKeepAlives: true,
      gridDelegate: getGridDelegate(context),
      itemCount: _products.length,
      itemBuilder: (context, index) => _products.length - 1 >= index
          ? _getProductCard(index)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _getProductCard(index) => _products.length - 1 >= index
      ? ProductCard(product: _products[index])
      : Container();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _editingController.dispose();
    _productsScrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
  }

  void _initializeResult() {
    _products = [];
    _totalProducts = 1;
  }

  Widget _filterDialogBuilder(BuildContext context) {
    final tr = AppLocalizations.of(context).tr;
    final minPrice = TextFormField(
      autofocus: false,
      keyboardType: TextInputType.number,
      controller: _minPriceController,
      validator: (String value) {
        if (value.isEmpty) {
          return null;
        }

        double amount = double.tryParse(value);
        if (amount == null) {
          return 'Doar cifre';
        }

        if (_maxPriceController.text.isEmpty) {
          // Nothing to compare against
          return null;
        }
        double max = double.tryParse(_maxPriceController.text);
        if (max != null) {
          if (amount > max) {
            return tr('filter.minGreaterThanMax');
          }
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: tr('product.price.min'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
    final maxPrice = TextFormField(
      autofocus: false,
      keyboardType: TextInputType.number,
      controller: _maxPriceController,
      validator: (String value) {
        if (value.isEmpty) {
          return null;
        }

        double amount = double.tryParse(value);
        if (amount == null) {
          return 'Doar cifre';
        }

        if (_minPriceController.text.isEmpty) {
          // Nothing to compare against
          return null;
        }
        double min = double.tryParse(_minPriceController.text);
        if (min != null) {
          if (amount < min) {
            return tr('filter.maxLesserThanMin');
          }
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: tr('product.price.max'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );

    return SimpleDialog(
      title: Row(
        children: <Widget>[
          Expanded(child: Text(tr('filter.title'))),
          Flexible(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CloseButton(),
              ],
            ),
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 2.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: [
        Container(
          height: 200,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(tr('product.price.title')),
              Expanded(
                child: Form(
                  key: _priceFormKey,
                  child: Row(
                    children: <Widget>[
                      Flexible(child: minPrice),
                      Text(
                        ' - ',
                        style: TextStyle(fontSize: 30),
                      ),
                      Flexible(child: maxPrice),
                    ],
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      if (_priceFormKey.currentState.validate()) {
                        Navigator.of(context).pop({
                          'minPrice': double.tryParse(_minPriceController.text),
                          'maxPrice': double.tryParse(_maxPriceController.text),
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
        errorWidget: (context, url, error) => Container(
          height: 80,
          child: Icon(
            Icons.error,
            color: Colors.grey,
          ),
        ),
      ),
    );

    final shopLogo = CachedNetworkImage(
      imageUrl: product.programLogo,
      width: 40,
      fit: BoxFit.contain,
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        child: InkWell(
          onTap: () {
            launchURL(product.affiliateUrl);
          },
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            product.oldPrice != null &&
                                    product.price != null &&
                                    product.oldPrice > product.price
                                ? Text(
                                    '${product.oldPrice.toString()} Lei',
                                    style: TextStyle(
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )
                                : Container(),
                            product.price != null
                                ? Center(
                                    child: Text(
                                      '${product.price.toString()} Lei',
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
