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
      fit: BoxFit.fitHeight,
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
                FlatButton(
                  child: const Icon(Icons.favorite_border),
                  onPressed: () {/* ... */},
                ),
                FlatButton(
                  child: const Icon(Icons.details),
                  onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ShopDetails(program: program)))
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
}
