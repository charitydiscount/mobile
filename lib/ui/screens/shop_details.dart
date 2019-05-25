import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/models/promotions.dart'
    show AdvertiserPromotion;
import 'package:charity_discount/ui/widgets/promotion.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/util/url.dart';
import 'package:charity_discount/state/state_model.dart';

class ShopDetails extends StatelessWidget {
  final models.Program program;

  ShopDetails({Key key, this.program});

  @override
  Widget build(BuildContext context) {
    final logo = Image.network(program.logoPath,
        width: 150, height: 40, fit: BoxFit.contain);
    final category = Padding(
        padding: EdgeInsets.all(12),
        child: Chip(
          label: Text(program.category),
        ));
    final promotionsTitle = Text(
      'Promotii',
      style: TextStyle(fontSize: 24.0),
    );
    final promotionsBuilder = FutureBuilder<List<AdvertiserPromotion>>(
      future: affiliateService.getPromotions(
          program.id, program.uniqueCode, AppModel.of(context).user.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.red),
              )));
        }
        if (snapshot.data.length == 0) {
          return Text('');
        }
        List<Widget> shopWidgets = [promotionsTitle];
        shopWidgets.addAll(
            snapshot.data.map((p) => PromotionWidget(promotion: p)).toList());
        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: shopWidgets);
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(program.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => launchURL(program.affilitateUrl),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add_shopping_cart),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        children: <Widget>[logo, category, promotionsBuilder],
      ),
    );
  }
}
