import 'package:charity_discount/services/shops.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/ui/screens/shop_details.dart';
import 'package:charity_discount/util/url.dart';

class ShopWidget extends StatelessWidget {
  final models.Program program;
  final String userId;

  ShopWidget({Key key, this.program, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Image.network(
      program.logoPath,
      width: 120,
      height: 30,
      fit: BoxFit.contain,
    );
    final linkButton = MaterialButton(
      color: Colors.red,
      textColor: Colors.white,
      child: Text(
        'Acceseaza magazin',
        style: TextStyle(fontSize: 12.0),
      ),
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
            color: Colors.red,
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

    return Card(
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
            )),
            subtitle: Center(child: Text(cashback)),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                favoriteButton,
                FlatButton(
                  child: const Icon(
                    Icons.details,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ShopDetails(program: program),
                            settings: RouteSettings(name: 'ShopDetails')));
                  },
                ),
                linkButton,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setFavorite(models.Program program, bool favorite) async {
    await getShopsService(userId).setFavoriteShop(userId, program, favorite);
  }
}
