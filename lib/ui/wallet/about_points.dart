import 'package:charity_discount/models/points.dart';
import 'package:flutter/material.dart';

class AboutPointsWidget extends StatelessWidget {
  final Points points;
  final Widget headingLeading;
  final String heading;
  final String subtitle;
  final String acceptedTitle;
  final String acceptedDescription;
  final Widget acceptedAction;
  final String pendingTitle;
  final String pendingDescription;
  final String currency;

  const AboutPointsWidget({
    Key key,
    this.points,
    this.headingLeading,
    this.heading = '',
    this.subtitle = '',
    this.acceptedTitle = '',
    this.acceptedDescription = '',
    this.acceptedAction,
    this.pendingTitle,
    this.pendingDescription,
    this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListTile pointsDescription = ListTile(
      leading: Container(
        child: headingLeading,
        width: 30,
      ),
      title: Tooltip(
        message: subtitle,
        showDuration: Duration(seconds: 5),
        child: Row(
          children: <Widget>[
            Text(
              heading,
              style: Theme.of(context).textTheme.headline5,
            ),
            Icon(
              Icons.info,
              color: Colors.grey,
              size: Theme.of(context).textTheme.bodyText1.fontSize,
            )
          ],
        ),
      ),
    );
    ListTile availablePoints = ListTile(
      leading: Container(
        width: 85,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text(
              points.acceptedAmount.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
              ),
            ),
            Text(
              currency,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
      title: Text(acceptedTitle),
      subtitle: Container(
        child: Text(acceptedDescription),
      ),
      trailing: acceptedAction,
      isThreeLine: true,
    );

    Widget pendingPoints;
    if (pendingTitle == null && pendingDescription == null) {
      pendingPoints = Container(
        height: 0,
        width: 0,
      );
    } else {
      pendingPoints = ListTile(
        leading: Container(
          width: 85,
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Text(
                points.pendingAmount.toStringAsFixed(2),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.yellowAccent.shade700,
                ),
              ),
              Text(
                currency,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
        title: Text(pendingTitle),
        subtitle: Text(pendingDescription),
        trailing: Container(
          height: 0,
          width: 30,
        ),
        isThreeLine: true,
      );
    }

    return Card(
      child: ListView(
        primary: false,
        shrinkWrap: true,
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            pointsDescription,
            availablePoints,
            pendingPoints,
          ],
        ).toList(),
      ),
    );
  }
}
