import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/transactions.dart';
import 'package:charity_discount/ui/widgets/about_points.dart';
import 'package:charity_discount/ui/widgets/charity.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:flutter/material.dart';

enum CashbackAction { CANCEL, DONATE, CASHOUT }

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

        snapshot.data.transactions.sort((t1, t2) => t2.date.compareTo(t1.date));

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
                  onPressed: () {
                    showDialog<CashbackAction>(
                      barrierDismissible: false,
                      context: context,
                      builder: _dialogCashbackBuilder,
                    ).then((cashbackAction) {
                      switch (cashbackAction) {
                        case CashbackAction.DONATE:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              maintainState: true,
                              builder: (BuildContext context) {
                                return Scaffold(
                                  appBar: AppBar(
                                    title: Text('Doneaza'),
                                  ),
                                  body: CharityWidget(),
                                );
                              },
                              settings: RouteSettings(name: 'Donate'),
                            ),
                          );
                          break;
                        case CashbackAction.CASHOUT:
                          break;
                        default:
                          return;
                      }
                    });
                  },
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
                    builder: (BuildContext context) => TransactionsScreen(
                      transactions: snapshot.data.transactions,
                    ),
                    settings: RouteSettings(name: 'Transactions'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _dialogCashbackBuilder(BuildContext context) {
    return AlertDialog(
      title: Text('Ce doresti sa faci cu cashback-ul obtinut?'),
      content: Text(
          'Ai posibilitatea fie sa contribui la o lume mai buna, fie sa ii retragi (total sau partial).'),
      actions: <Widget>[
        FlatButton(
          child: Text('RENUNTA'),
          onPressed: () {
            Navigator.of(context).pop(CashbackAction.CANCEL);
          },
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text('DONEAZA', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop(CashbackAction.DONATE);
          },
        ),
        RaisedButton(
          color: Colors.green,
          child: Text('RETRAGE', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop(CashbackAction.DONATE);
          },
        )
      ],
    );
  }
}
