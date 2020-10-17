import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/promotions/promotion.dart';
import 'package:flutter/material.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Promotion>>(
      future: AppModel.of(context).loadPromotions(),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );
        if (loading != null) {
          return loading;
        }

        final promotions = snapshot.data;

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: getGridDelegate(context),
          itemCount: promotions.length,
          itemBuilder: (context, index) => PromotionCard(
            promotion: promotions[index],
          ),
        );
      },
    );
  }
}
