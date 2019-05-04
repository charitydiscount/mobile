import 'package:flutter/material.dart';
import 'package:charity_discount/models/promotions.dart'
    show AdvertiserPromotion;
import 'package:charity_discount/util/url.dart';

class PromotionWidget extends StatelessWidget {
  final AdvertiserPromotion promotion;

  PromotionWidget({Key key, this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            onTap: () => launchURL(promotion.landingPageLink),
            title: Row(children: <Widget>[
              Icon(Icons.attach_money, color: Colors.green),
              Flexible(
                  child: Center(
                      child: Text(
                promotion.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              )))
            ]),
            subtitle: Center(child: Text(promotion.description)),
          ),
        ],
      ),
    );
  }
}