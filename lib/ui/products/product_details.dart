import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/ui/app/image_carousel.dart';

class ProductDetails extends StatelessWidget {
  final Product product;

  const ProductDetails({Key key, this.product}) : super(key: key);

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
          height: 600,
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

    final soldBy = Text(
      '${tr('product.soldBy')}: ${this.product.programName}',
      style: textTheme.subtitle1,
    );

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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: soldBy,
        ),
        Expanded(child: meta),
      ],
    );
  }
}
