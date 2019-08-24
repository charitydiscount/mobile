import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/ui/widgets/promotion.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/util/url.dart';
import 'package:charity_discount/state/state_model.dart';

class ShopDetails extends StatelessWidget {
  final models.Program program;

  const ShopDetails({Key key, this.program}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'shopLogo-${program.id}',
      child: CachedNetworkImage(
        imageUrl: program.logoPath,
        width: 150,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
    final category = Padding(
      padding: EdgeInsets.all(12),
      child: Chip(
        label: Text(program.category),
      ),
    );
    final promotionsTitle = Text(
      'Promotii',
      style: TextStyle(fontSize: 24.0),
    );

    final appState = AppModel.of(context);

    final promotionsBuilder = FutureBuilder<List<Promotion>>(
      future: affiliateService.getPromotions(
        affiliateUniqueCode: appState.affiliateMeta.uniqueCode,
        programId: program.id,
        programUniqueCode: program.uniqueCode,
        userId: appState.user.userId,
      ),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          waitingDisplay: Text('Cautam promotii active'),
        );
        if (loading != null) {
          return loading;
        }
        List<Widget> promotionsWidgets = [promotionsTitle];
        promotionsWidgets.addAll(
          snapshot.data.map((p) => PromotionWidget(promotion: p)).toList(),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: promotionsWidgets,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(program.name),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launchURL(program.affilitateUrl);
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        children: <Widget>[logo, category, promotionsBuilder],
      ),
    );
  }
}
