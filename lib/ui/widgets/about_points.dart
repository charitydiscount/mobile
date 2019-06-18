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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListTile pointsDescription = ListTile(
      leading: Container(
        child: headingLeading,
        width: 30,
      ),
      title: Text(
        heading,
        style: Theme.of(context).textTheme.headline,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
    ListTile availablePoints = ListTile(
      leading: Container(
        width: 80,
        alignment: Alignment.center,
        child: Text(
          points.acceptedAmount.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, color: Colors.green),
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
          width: 80,
          alignment: Alignment.center,
          child: Text(
            points.pendingAmount.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, color: Colors.yellow),
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
    //'Acumuleaza puncte si beneficiezi de acces la oferte speciale'));
  }
}
