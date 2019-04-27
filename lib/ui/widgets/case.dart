import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';

class CaseWidget extends StatelessWidget {
  final Charity charityCase;
  double contribution = 0.0;

  CaseWidget({Key key, this.charityCase});

  @override
  Widget build(BuildContext context) {
    print(charityCase.title);
    final logo = Image.network(charityCase.images[0].url, width: 150);
    return Card(
      margin: EdgeInsets.zero,
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
                new Slider(
                    value: contribution,
                    onChanged: (newValue) => contribution = newValue),
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
