import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/services/analytics.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/programs/rating.dart';
import 'package:charity_discount/ui/programs/shop_details.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/util/url.dart';

class ShopHalfTile extends StatelessWidget {
  final models.Program program;

  ShopHalfTile({Key key, this.program}) : super(key: key);

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
      onPressed: () {
        openAffiliateLink(
          program.actualAffiliateUrl,
          context,
          program.id,
          program.name,
          'programs',
        );
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
                builder: (BuildContext context) =>
                    ShopDetails(program: program),
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
                    locator<AuthService>().isActualUser()
                        ? favoriteButton
                        : Container(
                            width: 0,
                            height: 0,
                          ),
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
    await locator<ShopsService>().setFavoriteShop(program, favorite);
  }
}
