import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/services/analytics.dart';
import 'package:charity_discount/services/search.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/ui/programs/rating.dart';
import 'package:charity_discount/ui/programs/shop_details.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/tutorial/access_explanation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/util/url.dart';

class ShopHalfTile extends StatelessWidget {
  final models.Program program;
  final String userId;
  final ShopsService shopsService;
  final SearchService searchService;

  ShopHalfTile({
    Key key,
    this.program,
    this.userId,
    this.shopsService,
    this.searchService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'shopLogo-${program.id}',
      child: CachedNetworkImage(
        imageUrl: program.logoPath,
        height: 30,
        fit: BoxFit.contain,
      ),
    );
    final linkButton = FlatButton(
      padding: EdgeInsets.zero,
      child: Text(tr('access')),
      onPressed: () async {
        analytics.logEvent(
          name: 'access_shop',
          parameters: {
            'id': program.id,
            'name': program.name,
            'screen': 'programs',
          },
        );

        bool continueToShop = await showExplanationDialog(context);
        if (continueToShop != true) {
          return;
        }

        launchURL(program.actualAffiliateUrl);
      },
    );

    Widget cashback = Text(
      getProgramCommission(program),
      style: Theme.of(context).textTheme.subtitle2,
    );

    Widget rating = ProgramRating(rating: program.rating, iconSize: 20);

    Widget favoriteButton = program.favorited
        ? IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.favorite),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _setFavorite(program, false);
            },
          )
        : IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.favorite_border),
            color: Colors.grey,
            onPressed: () {
              _setFavorite(program, true);
            },
          );

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      height: double.infinity,
      child: Card(
        child: InkWell(
          onTap: () {
            analytics.logViewItem(
              itemId: program.id,
              itemName: program.name,
              itemCategory: 'program',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ShopDetails(
                  program: program,
                  shopsService: shopsService,
                  searchService: searchService,
                ),
                settings: RouteSettings(name: 'ShopDetails'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: logo,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      program.name,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Center(
                    child: rating,
                  ),
                ),
                Center(child: cashback),
                ButtonBar(
                  children: <Widget>[
                    favoriteButton,
                    linkButton,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setFavorite(models.Program program, bool favorite) async {
    await shopsService.setFavoriteShop(userId, program, favorite);
  }
}
