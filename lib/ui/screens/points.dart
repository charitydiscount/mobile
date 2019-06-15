import 'package:charity_discount/models/points.dart';
import 'package:charity_discount/ui/screens/transactions.dart';
import 'package:charity_discount/ui/widgets/about_points.dart';
import 'package:flutter/material.dart';

class PointsScreen extends StatelessWidget {
  final Points points;

  PointsScreen({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: true,
      children: <Widget>[
        AboutPointsWidget(
          points: Points(acceptedAmount: 150),
          headingLeading: Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          heading: 'Charity Points',
          subtitle: 'Puncte dobandite in schimbul donatiilor',
          acceptedTitle: 'Puncte disponibile',
          acceptedDescription:
              'Acestea pot fi folosite in magazinele partenere',
          acceptedAction: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            iconSize: 30,
            onPressed: () {},
          ),
        ),
        Divider(),
        AboutPointsWidget(
          points: Points(acceptedAmount: 35, pendingAmount: 120),
          headingLeading: Icon(
            Icons.monetization_on,
            color: Colors.green,
          ),
          heading: 'Cashback',
          subtitle: 'Banii primiti in urma cumparaturilor',
          acceptedTitle: 'Cashback disponibil',
          acceptedDescription: 'Bani care pot fi donati sau retrasi',
          acceptedAction: IconButton(
            icon: Icon(
              Icons.payment,
              color: Theme.of(context).accentColor,
            ),
            iconSize: 30,
            onPressed: () {},
          ),
          pendingTitle: 'Cashback in asteptare',
          pendingDescription:
              'Bani care urmeaza sa fie primiti pe baza cumparaturilor facute',
        ),
        Divider(),
        FlatButton(
          child: Text(
            'Istoric tranzactii',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => TransactionsScreen(),
                settings: RouteSettings(name: 'Transactions'),
              ),
            );
          },
        ),
      ],
    );
  }
}
