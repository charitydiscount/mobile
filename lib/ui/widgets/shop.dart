import 'package:flutter/material.dart';
import 'package:charity_discount/models/market.dart';
import 'package:charity_discount/ui/screens/shop_details.dart';
import 'package:charity_discount/util/url.dart';

class ShopWidget extends StatelessWidget {
  final Program program;

  ShopWidget({Key key, this.program});

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
      onPressed: () => launchURL(program.mainUrl),
    );
    String cashback = program.defaultLeadCommissionAmount != null
        ? '${program.defaultLeadCommissionAmount} RON'
        : '${program.defaultSaleCommissionRate}%';

    Widget favoriteButton = program.favorited
        ? IconButton(
            icon: const Icon(Icons.favorite),
            color: Colors.red,
            onPressed: () {
              _toggleFavorite(program.uniqueCode);
            },
          )
        : IconButton(
            icon: const Icon(Icons.favorite_border),
            color: Colors.grey,
            onPressed: () {
              _toggleFavorite(program.uniqueCode);
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
                  child: const Icon(Icons.details),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ShopDetails(program: program)));
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

  void _toggleFavorite(String shopId) {}
}
