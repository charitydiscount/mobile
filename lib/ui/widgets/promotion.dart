import 'package:charity_discount/models/promotion.dart';
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
            onTap: () => launchURL(promotion.affilitateUrl),
            title: Row(
              children: <Widget>[
                Icon(Icons.attach_money, color: Colors.green),
                Flexible(
                  child: Center(
                    child: Text(
                      promotion.name,
                      style: TextStyle(
                        fontSize: 24.0,
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
