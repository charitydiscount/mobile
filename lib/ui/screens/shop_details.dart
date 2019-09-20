import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/models/rating.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/ui/widgets/rating.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/ui/widgets/promotion.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/util/url.dart';
import 'package:charity_discount/state/state_model.dart';

class ShopDetails extends StatelessWidget {
  final models.Program program;
  final ShopsService shopsService;

  const ShopDetails({
    Key key,
    @required this.program,
    @required this.shopsService,
  }) : super(key: key);

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

    final appState = AppModel.of(context);

    double sectionTitleSize =
        Theme.of(context).textTheme.headline.fontSize * 0.7;

    Widget ratingBuilder = FutureBuilder<List<Rating>>(
      future: shopsService.getProgramRating(program.uniqueCode),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          waitingDisplay: Text('Cautam recenziile magazinului'),
        );
        if (loading != null) {
          return loading;
        }
        final titleColor =
            snapshot.data.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800;
        final reviewsTitle = Text(
          'Recenzii',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: sectionTitleSize,
            color: titleColor,
          ),
        );
        Widget overallRating = ProgramRating(
          rating: program.rating,
          iconSize: 25,
        );
        Widget addReview = MaterialButton(
          color: Colors.green,
          textColor: Colors.white,
          child: Text('Add review'),
          onPressed: () {},
        );

        List<Widget> reviewsWidgets = snapshot.data
            .map((rating) => RatingWidget(rating: rating))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  reviewsTitle,
                  Expanded(child: overallRating),
                  addReview,
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: reviewsWidgets,
                shrinkWrap: true,
              ),
            ),
          ],
        );
      },
    );

    Widget promotionsBuilder = FutureBuilder<List<Promotion>>(
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
        final titleColor =
            snapshot.data.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800;
        final promotionsTitle = Text(
          'Promotii',
          style: TextStyle(
            fontSize: sectionTitleSize,
            color: titleColor,
          ),
        );
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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: logo,
          ),
          category,
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ratingBuilder,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: promotionsBuilder,
          ),
        ],
      ),
    );
  }
}
