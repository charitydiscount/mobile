import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';

class CaseWidget extends StatelessWidget {
  final Charity charityCase;

  CaseWidget({Key key, this.charityCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Image.network(
      charityCase.images[0].url,
      width: 120,
      height: 120,
      fit: BoxFit.fill,
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
              charityCase.title,
              style: TextStyle(
                fontSize: 24.0,
              ),
            )),
            subtitle: Center(child: Text('')),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
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
