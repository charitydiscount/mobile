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
  AsyncMemoizer<List<Product>> _searchMemoizer = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    _state = AppModel.of(context);
  }

  void _search() {
    if (_query.compareTo(_editingController.text) != 0) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {
        _searchMemoizer = AsyncMemoizer();
        _query = _editingController.text ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget programs = _query.isEmpty ? _featuredProducts : _foundProducts;

    Widget searchInput = Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _editingController,
            onEditingComplete: _search,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
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
          color: Colors.red,
          onPressed: _search,
        ),
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

  Widget get _foundProducts => FutureBuilder<List<Product>>(
        future: _searchMemoizer
            .runOnce(() => widget.searchService.searchProducts(_query)),
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

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _editingController.dispose();
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
                                      // fontWeight: FontWeight.bold,
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
