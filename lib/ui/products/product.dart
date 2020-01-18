import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/util/url.dart';
import 'package:flutter/material.dart';

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
                Expanded(
                  child: ButtonBar(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
