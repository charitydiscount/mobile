import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/ui/screens/shop_details.dart';
import 'package:charity_discount/util/url.dart';

class ShopFullTile extends StatelessWidget {
  final models.Program program;
  final String userId;

  ShopFullTile({Key key, this.program, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'shopLogo-${program.id}',
      child: CachedNetworkImage(
        imageUrl: program.logoPath,
        width: 120,
        height: 30,
        fit: BoxFit.contain,
      ),
    );
    final linkButton = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: () {
        launchURL(program.affilitateUrl);
      },
      padding: EdgeInsets.all(12),
      color: Theme.of(context).primaryColor,
      child: Text(
        AppLocalizations.of(context).tr('accessShop'),
        style: TextStyle(color: Colors.white),
      ),
    );

    String cashback = program.leadCommissionAmount != null
        ? '${program.leadCommissionAmount} RON'
        : '${program.saleCommissionRate}%';

    Widget favoriteButton = program.favorited
        ? IconButton(
            icon: const Icon(Icons.favorite),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _setFavorite(program, false);
            },
          )
        : IconButton(
            icon: const Icon(Icons.favorite_border),
            color: Colors.grey,
            onPressed: () {
              _setFavorite(program, true);
            },
          );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            maintainState: true,
            builder: (BuildContext context) => ShopDetails(program: program),
            settings: RouteSettings(name: 'ShopDetails'),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: logo,
              title: Center(
                child: Text(
                  program.name,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              subtitle: Center(
                child: Text(cashback),
              ),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  favoriteButton,
                  linkButton,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFavorite(models.Program program, bool favorite) async {
    await getShopsService(userId).setFavoriteShop(userId, program, favorite);
  }
}

class ShopHalfTile extends StatelessWidget {
  final models.Program program;
  final String userId;

  ShopHalfTile({Key key, this.program, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'shopLogo-${program.id}',
      child: CachedNetworkImage(
        imageUrl: program.logoPath,
        width: 80,
        height: 20,
        fit: BoxFit.contain,
      ),
    );
    final linkButton = IconButton(
      icon: const Icon(Icons.add_shopping_cart),
      color: Theme.of(context).primaryColor,
      onPressed: () {
        launchURL(program.affilitateUrl);
      },
    );

    String cashback = program.leadCommissionAmount != null
        ? '${program.leadCommissionAmount} RON'
        : '${program.saleCommissionRate}%';

    Widget favoriteButton = program.favorited
        ? IconButton(
            icon: const Icon(Icons.favorite),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _setFavorite(program, false);
            },
          )
        : IconButton(
            icon: const Icon(Icons.favorite_border),
            color: Colors.grey,
            onPressed: () {
              _setFavorite(program, true);
            },
          );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            maintainState: true,
            builder: (BuildContext context) => ShopDetails(program: program),
            settings: RouteSettings(name: 'ShopDetails'),
          ),
        );
      },
      child: Card(
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
              Center(
                child: Text(
                  program.name,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: Text(
                    cashback,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    favoriteButton,
                    linkButton,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setFavorite(models.Program program, bool favorite) async {
    await getShopsService(userId).setFavoriteShop(userId, program, favorite);
  }
}
