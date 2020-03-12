import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/ui/app/image_carousel.dart';

class ProductDetails extends StatelessWidget {
  final Product product;

  ProductDetails({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launchURL(product.affiliateUrl);
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          child: _buildProductHeader(context),
        ),
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

    final oldPrice = this.product.oldPrice != null &&
            this.product.price != null &&
            this.product.oldPrice > this.product.price
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
              style: textTheme.headline5
                  .copyWith(color: Theme.of(context).primaryColor),
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
              Expanded(
                child: Text(
                  product.category ?? '-',
                  style: textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
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
        Expanded(child: meta),
      ],
    );
  }

  Widget _buildShopInfo(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CachedNetworkImage(
            imageUrl: product.program.logoPath,
            width: 60,
            fit: BoxFit.contain,
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
                  ? Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.green)
                  : Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasCommissionInterval =>
      product.program.commissionMin != null &&
      product.program.commissionMax != null;

  Widget _buildSellingCountries(BuildContext context) {
    return Text(
      product.program.sellingCountries
          .map((country) => country.name)
          .join(', '),
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
