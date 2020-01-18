import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/models/rating.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/ui/programs/promotion.dart';
import 'package:charity_discount/ui/programs/rate_shop.dart';
import 'package:charity_discount/ui/programs/rating.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/util/url.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:async/async.dart';

class ShopDetails extends StatefulWidget {
  final models.Program program;
  final ShopsService shopsService;

  const ShopDetails({
    Key key,
    @required this.program,
    @required this.shopsService,
  }) : super(key: key);

  @override
  _ShopDetailsState createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  AsyncMemoizer _promotionsMemoizer = AsyncMemoizer();

  @override
  Widget build(BuildContext context) {
    var tr = AppLocalizations.of(context).tr;

    final logo = Hero(
      tag: 'shopLogo-${widget.program.id}',
      child: CachedNetworkImage(
        imageUrl: widget.program.logoPath,
        height: 80,
        fit: BoxFit.contain,
      ),
    );

    final appState = AppModel.of(context);

    double sectionTitleSize =
        Theme.of(context).textTheme.headline.fontSize * 0.7;

    Widget ratingBuilder = FutureBuilder<List<Review>>(
      future: widget.shopsService.getProgramRating(widget.program.uniqueCode),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          waitingDisplay: Text(tr('review.loading')),
        );
        if (loading != null) {
          return loading;
        }
        final titleColor =
            snapshot.data.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800;
        final reviewsTitle = Text(
          tr('review.reviews'),
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: sectionTitleSize,
            color: titleColor,
          ),
        );
        Widget overallRating = ProgramRating(
          rating: widget.program.rating,
          iconSize: 25,
        );

        Review thisUserReview = snapshot.data.firstWhere(
            (r) => r.reviewer.userId == appState.user.userId,
            orElse: () => null);
        bool alreadyReviewed = thisUserReview != null;

        Widget addReview = ClipOval(
          child: Container(
            color: Colors.green,
            child: IconButton(
              color: Colors.white,
              icon: alreadyReviewed ? Icon(Icons.edit) : Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    maintainState: true,
                    builder: (BuildContext context) => RateScreen(
                      program: widget.program,
                      shopsService: widget.shopsService,
                      existingReview: thisUserReview,
                    ),
                    settings: RouteSettings(name: 'ProvideRating'),
                  ),
                ).then((createdReview) {
                  if (createdReview != null && createdReview) {
                    Flushbar(
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      title: tr('review.thankYou'),
                      message: tr('review.itIsImportant'),
                      reverseAnimationCurve: Curves.linear,
                    ).show(context);
                  }
                });
              },
            ),
          ),
        );

        List<Widget> reviewsWidgets = snapshot.data
            .map((rating) => RatingWidget(rating: rating))
            .toList();

        List<Widget> reviewSection = [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                reviewsTitle,
                Expanded(child: overallRating),
                addReview,
              ],
            ),
          ),
        ];

        if (reviewsWidgets.isNotEmpty) {
          reviewSection.add(
            Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: reviewsWidgets,
                shrinkWrap: true,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviewSection,
        );
      },
    );

    Widget promotionsBuilder = FutureBuilder(
      future: _promotionsMemoizer.runOnce(
        () => affiliateService.getPromotions(
          affiliateUniqueCode: appState.affiliateMeta.uniqueCode,
          programId: widget.program.id,
          programUniqueCode: widget.program.uniqueCode,
          userId: appState.user.userId,
        ),
      ),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          waitingDisplay: Text(tr('promotion.loading')),
        );
        if (loading != null) {
          return loading;
        }
        var promotions = snapshot.data as List<Promotion>;
        final titleColor =
            promotions.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800;
        final promotionsTitle = Text(
          tr('promotion.promotions'),
          style: TextStyle(
            fontSize: sectionTitleSize,
            color: titleColor,
          ),
        );
        List<Widget> promotionsWidgets = [promotionsTitle];
        promotionsWidgets.addAll(
          promotions.map((p) => PromotionWidget(promotion: p)).toList(),
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
        title: Text(widget.program.name),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launchURL(widget.program.affilitateUrl);
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: logo,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildInfo(context),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: promotionsBuilder,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ratingBuilder,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(context) {
    final category = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${AppLocalizations.of(context).plural('category', 1)}',
          style: Theme.of(context).textTheme.caption,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            widget.program.category,
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
      ],
    );

    final commission = Tooltip(
      showDuration: Duration(milliseconds: 2000),
      message: widget.program.defaultSaleCommissionType == 'percent' ||
              widget.program.defaultSaleCommissionType == 'variable'
          ? AppLocalizations.of(context).tr('commissionDisclaimer')
          : '',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${capitalize(AppLocalizations.of(context).tr('commission'))} ',
                style: Theme.of(context).textTheme.caption,
              ),
              widget.program.defaultSaleCommissionType == 'percent' ||
                      widget.program.defaultSaleCommissionType == 'variable'
                  ? Icon(
                      Icons.info,
                      color: Colors.grey,
                      size: Theme.of(context).textTheme.caption.fontSize,
                    )
                  : Container(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              getProgramCommission(widget.program),
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: category),
          Expanded(child: commission),
        ],
      ),
    );
  }
}