import 'package:flutter/material.dart';
import 'package:charity_discount/models/market.dart';

class ShopWidget extends StatelessWidget {
  final Program program;

  ShopWidget({Key key, this.program});

  @override
  Widget build(BuildContext context) {
    print(program.logoPath);
    final logo = Image.network(program.logoPath, width: 150);
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
            subtitle: Center(
                child: Text('${program.category.commission.toString()}%')),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.favorite_border),
                  onPressed: () {/* ... */},
                ),
                FlatButton(
                  child: const Text('DETAILS'),
                  onPressed: () {/* ... */},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
