import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/util/url.dart';

class PromotionWidget extends StatelessWidget {
  final Promotion promotion;

  PromotionWidget({Key key, this.promotion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            onTap: () {
              print(promotion.actualAffiliateUrl);
              launchURL(promotion.actualAffiliateUrl);
            },
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.attach_money, color: Colors.green),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                '${formatDateTime(promotion.promotionStart.toLocal())} - ${formatDateTime(promotion.promotionEnd.toLocal())}',
              ),
            ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Center(
                    child: Text(
                      promotion.name,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
