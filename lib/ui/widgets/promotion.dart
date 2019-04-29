import 'package:flutter/material.dart';
import 'package:charity_discount/models/promotions.dart'
    show AdvertiserPromotion;

class PromotionWidget extends StatelessWidget {
  final AdvertiserPromotion promotion;

  PromotionWidget({Key key, this.promotion});

  @override
  Widget build(BuildContext context) {
    final logo = Image.network(promotion.campaignLogo, width: 120);
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            leading: logo,
            title: Center(
                child: Text(
              promotion.name,
              style: TextStyle(
                fontSize: 24.0,
              ),
            )),
            subtitle: Center(child: Text(promotion.description)),
          ),
        ],
      ),
    );
  }
}
