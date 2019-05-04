import 'package:charity_discount/models/points.dart';
import 'package:flutter/material.dart';

class AboutPointsWidget extends StatelessWidget {
  final Points points;

  const AboutPointsWidget({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget pointsDisplay = Container(
        height: 300,
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Center(
                  child: Text(
                points.acceptedAmount.toString(),
                style: TextStyle(fontSize: 50, color: Colors.green),
              )),
            ),
            Expanded(
              child: Center(
                  child: Text(
                points.pendingAmount.toString(),
                style: TextStyle(fontSize: 50, color: Colors.yellow),
              )),
            ),
          ],
        ));

    return Padding(padding: EdgeInsets.all(12.0), child: pointsDisplay); //Text(
    //'Acumuleaza puncte si beneficiezi de acces la oferte speciale'));
  }
}
