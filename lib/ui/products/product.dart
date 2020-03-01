import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/ui/products/product_details.dart';
import 'package:charity_discount/util/url.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool showShopLogo;

  ProductCard({
    Key key,
    @required this.product,
    this.showShopLogo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'productLogo-${product.id}',
      child: CachedNetworkImage(
        imageUrl: product.images.first,
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

    final shopLogo = showShopLogo
        ? CachedNetworkImage(
            imageUrl: product.programLogo,
            width: 40,
            fit: BoxFit.contain,
          )
        : Container();

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                maintainState: true,
                builder: (BuildContext context) =>
                    ProductDetails(product: product),
                settings: RouteSettings(name: 'ProductDetails'),
              ),
            );
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
                Expanded(
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              _hasOldPrice
                                  ? Text(
                                      '${product.oldPrice.toString()} Lei',
                                      style: TextStyle(
                                        fontSize: 10,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    )
                                  : Container(),
                              product.price != null
                                  ? Center(child: _buildPriceText())
                                  : Container(),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              launchURL(product.affiliateUrl);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasOldPrice =>
      product.oldPrice != null &&
      product.price != null &&
      product.oldPrice > product.price;

  Widget _buildPriceText() => Text(
        '${product.price.toString()} Lei',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
}
