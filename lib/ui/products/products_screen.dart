import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/products/product.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool _searchInProgress = false;
  SortStrategy _sortStrategy = SortStrategy.relevance;
  double _minPrice;
  double _maxPrice;

  @override
  void initState() {
    super.initState();
    _state = AppModel.of(context);
    _productsScrollController = ScrollController();
    _productsScrollController.addListener(() {
      if (_searchInProgress == false && _products.length < _totalProducts) {
        if (_productsScrollController.position.pixels >
            0.9 * _productsScrollController.position.maxScrollExtent) {
          setState(() {
            _searchInProgress = true;
          });
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
            _searchInProgress = false;
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
        _searchInProgress = true;
      });
      _searchProducts(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget searchInput = Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _editingController,
            onEditingComplete: _search,
            textInputAction: TextInputAction.search,
            cursorColor: Theme.of(context).accentColor,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 12.0),
              labelStyle: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
              ),
              labelText: tr('product.searchPlaceholder'),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              suffixIcon: IconButton(
                icon: Icon(Icons.close),
                color: Colors.grey,
                onPressed: () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  FocusScope.of(context).requestFocus(FocusNode());
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
      body: _query.isEmpty ? _featuredProducts : _productsList,
    );
  }

  Widget _buildSortButton(BuildContext context) {
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
              : Theme.of(context).textTheme.bodyText2.color,
        ),
      );

  List<Product> _prepareProducts(Iterable<Product> products) =>
      prepareProducts(products, _state);

  Widget get _featuredProducts => FutureBuilder<List<Product>>(
        future: _featuredMemoizer.runOnce(
          () => widget.searchService.getFeaturedProducts(
            userId: _state.user.userId,
          ),
        ),
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
            gridDelegate: getGridDelegate(context, aspectRatioFactor: 0.95),
            itemCount: productsWidget.length,
            itemBuilder: (context, index) => productsWidget.elementAt(index),
          );
        },
      );

  Widget get _productsList {
    if (_products.isEmpty && _searchInProgress) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      controller: _productsScrollController,
      gridDelegate: getGridDelegate(context, aspectRatioFactor: 0.95),
      itemCount: _products.length + (_searchInProgress ? 1 : 0),
      itemBuilder: (context, index) => index < _products.length
          ? _getProductCard(index)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      children: [
        Container(
          height: 200,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  FlatButton(
                    child: Text(tr('apply')),
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

List<Product> prepareProducts(Iterable<Product> products, AppModel state) =>
    products
        .map((product) {
          final program = state.programs.firstWhere(
                (program) => program.id == product.programId,
                orElse: () => null,
              ) ??
              state.programs.firstWhere(
                (program) =>
                    program.uniqueCode.compareTo(product.programName) == 0,
                orElse: () => null,
              );
          if (program == null) {
            return null;
          }
          return product.copyWith(
            program: program,
            affiliateUrl: convertAffiliateUrl(
              product.url,
              state.affiliateMeta.uniqueCode,
              program.uniqueCode,
              state.user.userId,
            ),
          );
        })
        .where((product) => product != null)
        .toList();
