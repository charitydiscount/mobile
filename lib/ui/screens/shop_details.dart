import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:charity_discount/models/market.dart';
import 'package:charity_discount/models/promotions.dart'
    show AdvertiserPromotion;
import 'package:charity_discount/ui/widgets/promotion.dart';
import 'package:charity_discount/services/affiliate.dart';

class ShopDetails extends StatelessWidget {
  final Program program;

  ShopDetails({Key key, this.program});

  @override
  Widget build(BuildContext context) {
    final logo = Image.network(program.logoPath, width: 150);
    final description = Flexible(
        child: Text(
      program.description,
      softWrap: true,
    ));
    final detailsContainer = Container(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: <Widget>[
          description,
        ],
      ),
    );

    final promotionsBuilder = FutureBuilder<List<AdvertiserPromotion>>(
      future: affiliateService.getPromotions(program.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shopWidgets =
              snapshot.data.map((p) => PromotionWidget(promotion: p)).toList();
          return Column(mainAxisSize: MainAxisSize.min, children: shopWidgets);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner
        return CircularProgressIndicator();
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(program.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchURL(program.mainUrl),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add_shopping_cart),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 12.0),
        children: <Widget>[logo, promotionsBuilder],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
