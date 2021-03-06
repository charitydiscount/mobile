import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/access_button.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/products/product.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/ui/app/image_carousel.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ProductDetails extends StatelessWidget {
  final Product product;

  ProductDetails({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AccessButton(
        buttonType: AccessButtonType.FLOATING,
        url: product.actualAffiliateUrl,
        programId: product.program.id,
        programName: product.program.name,
        eventScreen: 'product_details',
      ),
      body: SingleChildScrollView(
        child: _buildProductHeader(context),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    final images = ImageCarousel(images: product.images);

    final textTheme = Theme.of(context).textTheme;

    final productTitle = Center(
      child: Text(
        this.product.title,
        style: textTheme.headline6,
        textAlign: TextAlign.center,
      ),
    );

    final oldPrice =
        this.product.oldPrice != null && this.product.price != null && this.product.oldPrice > this.product.price
            ? Text(
                '${this.product.oldPrice.toString()} Lei',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                ),
              )
            : Container();
    final price = product.price != null
        ? Center(
            child: Text(
              '${product.price.toString()} Lei',
              style: textTheme.headline5.copyWith(color: Theme.of(context).primaryColor),
            ),
          )
        : Container();

    final meta = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(plural('category', 1)),
              Text(
                product.category ?? '-',
                style: textTheme.subtitle2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Brand'),
              Expanded(
                child: Text(
                  product.brand ?? '-',
                  style: textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        images,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: productTitle,
        ),
        oldPrice,
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: price,
        ),
        _buildUpdatedAt(context),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: _buildShopInfo(context),
        ),
        Container(
          height: 100,
          child: Center(child: meta),
        ),
        Container(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr('product.history'),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Expanded(child: PriceChart(productId: product.id)),
              ],
            ),
          ),
        ),
        Container(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr('product.similarProducts'),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Expanded(child: SimilarProducts(product: product)),
              ],
            ),
          ),
        ),
        SizedBox(height: 50),
      ],
    );
  }

  Widget _buildShopInfo(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CachedNetworkImage(
            imageUrl: Uri.tryParse(product.program.logoPath) != null ? product.program.logoPath : null,
            width: 60,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) => Container(
              height: 80,
              child: Icon(
                Icons.error,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        title: Text('${product.program.name}'),
        subtitle: _buildSellingCountries(context),
        trailing: Container(
          width: 100,
          height: 100,
          child: _buildCommission(context),
        ),
      ),
    );
  }

  Widget _buildCommission(BuildContext context) {
    return Tooltip(
      showDuration: Duration(milliseconds: 2000),
      message: product.program.defaultSaleCommissionType == 'percent' ||
              product.program.defaultSaleCommissionType == 'variable'
          ? tr('commissionDisclaimer')
          : '',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${capitalize(tr('commission'))} ',
                style: Theme.of(context).textTheme.caption,
              ),
              product.program.defaultSaleCommissionType == 'percent' ||
                      product.program.defaultSaleCommissionType == 'variable'
                  ? Icon(
                      Icons.info,
                      color: Colors.grey,
                      size: Theme.of(context).textTheme.caption.fontSize,
                    )
                  : Container(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              getProgramCommission(product.program),
              style: _hasCommissionInterval
                  ? Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.green)
                  : Theme.of(context).textTheme.headline5.copyWith(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasCommissionInterval => product.program.commissionMin != null && product.program.commissionMax != null;

  Widget _buildSellingCountries(BuildContext context) {
    return Text(
      product.program.sellingCountries.map((country) => country.name).join(', '),
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildUpdatedAt(BuildContext context) {
    return Tooltip(
      showDuration: Duration(seconds: 5),
      message: tr('product.disclaimer'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${tr('product.updatedAt')} ${formatDateTime(product.timestamp)}',
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
          Icon(
            Icons.info,
            color: Colors.grey,
            size: Theme.of(context).textTheme.caption.fontSize,
          )
        ],
      ),
    );
  }
}

class PriceChart extends StatelessWidget {
  final String productId;

  PriceChart({Key key, this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductPriceHistory>(
      future: locator<SearchServiceBase>().getProductPriceHistory(productId),
      builder: (context, snapshot) {
        final loadingWidget = buildConnectionLoading(
          snapshot: snapshot,
          context: context,
        );
        if (loadingWidget != null) return loadingWidget;

        if (snapshot.data.history.isEmpty) return Text(tr('insufficientData'));

        return charts.TimeSeriesChart(
          _toSeries(snapshot.data),
          animate: true,
        );
      },
    );
  }

  List<charts.Series<ProductPriceHistoryEntry, DateTime>> _toSeries(ProductPriceHistory history) {
    return [
      charts.Series<ProductPriceHistoryEntry, DateTime>(
        id: 'priceHistory',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ProductPriceHistoryEntry entry, _) => entry.timestamp,
        measureFn: (ProductPriceHistoryEntry entry, _) => entry.price,
        data: history.history,
      ),
    ];
  }
}

class SimilarProducts extends StatelessWidget {
  final Product product;

  const SimilarProducts({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: AppModel.of(context).getSimilarProducts(product),
      builder: (context, snapshot) {
        final loadingWidget = buildConnectionLoading(
          snapshot: snapshot,
          context: context,
        );
        if (loadingWidget != null) return loadingWidget;

        if (snapshot.data.isEmpty) {
          return Container(
            height: 0,
            width: 0,
          );
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => ProductCard(
            product: snapshot.data[index],
          ),
        );
      },
    );
  }
}
