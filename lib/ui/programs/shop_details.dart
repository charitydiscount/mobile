import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/product.dart';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/models/rating.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/app/access_button.dart';
import 'package:charity_discount/ui/products/product.dart';
import 'package:charity_discount/ui/programs/promotion.dart';
import 'package:charity_discount/ui/programs/rate_shop.dart';
import 'package:charity_discount/ui/programs/rating.dart';
import 'package:charity_discount/ui/programs/reviews.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:async/async.dart';

class ShopDetails extends StatefulWidget {
  final models.Program program;

  const ShopDetails({Key key, @required this.program}) : super(key: key);

  @override
  _ShopDetailsState createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  final _promotionsMemoizer = AsyncMemoizer<List<Promotion>>();
  AsyncMemoizer _reviewsMemoizer = AsyncMemoizer<List<Review>>();
  final _productsMemoizer = AsyncMemoizer<ProductSearchResult>();

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'shopLogo-${widget.program.id}',
      child: CachedNetworkImage(
        imageUrl: widget.program.logoPath,
        height: 80,
        fit: BoxFit.contain,
      ),
    );

    final appState = AppModel.of(context);

    double sectionTitleSize = Theme.of(context).textTheme.headline5.fontSize * 0.7;

    final reviewsFuture =
        _reviewsMemoizer.runOnce(() => locator<ShopsService>().getProgramRating(widget.program.uniqueCode));
    Widget ratingBuilder = FutureBuilder<List<Review>>(
      future: reviewsFuture,
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          waitingDisplay: Text(tr('review.loading')),
        );
        if (loading != null) {
          return SliverToBoxAdapter(child: loading);
        }

        final titleColor = snapshot.data.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800;
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
          orElse: () => null,
        );
        bool alreadyReviewed = thisUserReview != null;

        Widget addReview = locator<AuthService>().isActualUser()
            ? _buildProvideRating(alreadyReviewed, context, thisUserReview)
            : Container();

        snapshot.data.sort((r1, r2) => r2.createdAt.compareTo(r1.createdAt));

        List<Widget> reviewsWidgets = snapshot.data.take(3).map((rating) => RatingWidget(rating: rating)).toList();

        List<Widget> reviewSection = [
          Container(
            width: MediaQuery.of(context).size.width,
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

        reviewSection.addAll(reviewsWidgets);

        if (snapshot.data.length > 3) {
          reviewSection.add(
            Center(
              child: FlatButton(
                child: Text(tr('seeAll')),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProgramReviewsScreen(
                        reviews: snapshot.data,
                      ),
                      settings: RouteSettings(name: 'Reviews'),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return reviewSection[index];
            },
            childCount: reviewSection.length,
          ),
        );
      },
    );

    final promotionsFuture = _promotionsMemoizer.runOnce(
      () => locator<AffiliateService>().getPromotions(
        affiliateUniqueCode: appState.affiliateMeta.uniqueCode,
        programId: widget.program.id,
        programUniqueCode: widget.program.uniqueCode,
      ),
    );

    Widget promotionsBuilder = FutureBuilder<List<Promotion>>(
      future: promotionsFuture,
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
          waitingDisplay: Text(tr('promotion.loading')),
        );
        if (loading != null) {
          return SliverToBoxAdapter(child: loading);
        }

        var promotions = snapshot.data;
        final titleColor = promotions.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800;
        final promotionsTitle = Text(
          tr('promotion.promotions'),
          style: TextStyle(
            fontSize: sectionTitleSize,
            color: titleColor,
          ),
          textAlign: TextAlign.left,
        );

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return promotionsTitle;
              } else {
                return PromotionWidget(promotion: promotions[index - 1]);
              }
            },
            childCount: (promotions?.length ?? 0) + 1,
          ),
        );
      },
    );

    final productsFuture = _productsMemoizer.runOnce(() => Future.delayed(Duration(milliseconds: 500))
        .then((_) => AppModel.of(context).getProductsForProgram(program: widget.program)));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.name),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AccessButton(
        buttonType: AccessButtonType.FLOATING,
        url: widget.program.actualAffiliateUrl,
        programId: widget.program.id,
        programName: widget.program.name,
        eventScreen: 'program_details',
      ),
      body: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: logo),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            sliver: SliverToBoxAdapter(
              child: _buildInfo(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            sliver: promotionsBuilder,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            sliver: ratingBuilder,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            sliver: SliverToBoxAdapter(
              child: Divider(height: 2.0),
            ),
          ),
          FutureBuilder<ProductSearchResult>(
            future: productsFuture,
            builder: (context, snapshot) {
              final loading = buildConnectionLoading(
                context: context,
                snapshot: snapshot,
              );
              if (loading != null) {
                return SliverToBoxAdapter(child: loading);
              }

              return _ShopProducts(products: snapshot.data.products);
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
                top: 24.0,
                left: 12.0,
                right: 48.0,
              ),
              child: Text(
                tr('completeOffer'),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 50),
          ),
        ],
      ),
    );
  }

  ClipOval _buildProvideRating(bool alreadyReviewed, BuildContext context, Review thisUserReview) {
    return ClipOval(
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
                  existingReview: thisUserReview,
                ),
                settings: RouteSettings(name: 'ProvideRating'),
              ),
            ).then(
              (createdReview) {
                if (createdReview != null && createdReview) {
                  Flushbar(
                    icon: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    title: tr('review.thankYou'),
                    message: tr('review.itIsImportant'),
                    reverseAnimationCurve: Curves.linear,
                  ).show(context).then((value) {
                    setState(() {
                      _reviewsMemoizer = AsyncMemoizer<List<Review>>();
                    });
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfo(context) {
    final category = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${plural('category', 1)}',
          style: Theme.of(context).textTheme.caption,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            widget.program.category,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    );

    final commission = Tooltip(
      showDuration: Duration(milliseconds: 2000),
      message: widget.program.defaultSaleCommissionType == 'percent' ||
              widget.program.defaultSaleCommissionType == 'variable'
          ? tr('commissionDisclaimer')
          : '',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${capitalize(tr('commission'))} ',
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
              style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: 130,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: category),
              Expanded(child: _buildSellingCountries(context)),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: commission,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellingCountries(BuildContext context) {
    return Center(
      child: Tooltip(
        showDuration: Duration(seconds: 5),
        message: widget.program.sellingCountries.map((country) => country.name).join(', '),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              tr('sellingIn'),
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              widget.program.sellingCountries.map((country) => country.name).join(', '),
              style: Theme.of(context).textTheme.subtitle1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopProducts extends StatelessWidget {
  _ShopProducts({
    Key key,
    @required this.products,
  }) : super(key: key);

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products == null || products.length == 0) {
      return SliverToBoxAdapter(
        child: Container(height: 0, width: 0),
      );
    }

    return SliverGrid(
      gridDelegate: getGridDelegate(context, aspectRatioFactor: 0.95),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => ProductCard(
          product: products[index],
          showShopLogo: false,
        ),
        childCount: products?.length ?? 0,
      ),
    );
  }
}
