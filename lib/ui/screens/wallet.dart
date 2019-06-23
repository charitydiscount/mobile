import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/transactions.dart';
import 'package:charity_discount/ui/widgets/about_points.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Wallet>(
        future: charityService.getPoints(AppModel.of(context).user.userId),
        builder: (context, snapshot) {
          final loading = buildConnectionLoading(
            context: context,
            snapshot: snapshot,
          );
          if (loading != null) {
            return loading;
          }

          return ListView(
            primary: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AboutPointsWidget(
                  points: snapshot.data.charityPoints,
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
                    iconSize: 25,
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AboutPointsWidget(
                  points: snapshot.data.cashback,
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
                    iconSize: 25,
                    onPressed: () {},
                  ),
                  pendingTitle: 'Cashback in asteptare',
                  pendingDescription:
                      'Bani care urmeaza sa fie primiti pe baza cumparaturilor facute',
                ),
              ),
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
        });
  }
}
