import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/transactions.dart';
import 'package:charity_discount/ui/widgets/about_points.dart';
import 'package:charity_discount/ui/widgets/charity.dart';
import 'package:charity_discount/ui/widgets/operations.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:flutter/material.dart';

enum CashbackAction { CANCEL, DONATE, CASHOUT }

class WalletScreen extends StatelessWidget {
  WalletScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Wallet>(
      stream:
          charityService.getPointsListener(AppModel.of(context).user.userId),
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
                              builder: _donateViewBuilder,
                              settings: RouteSettings(name: 'Donate'),
                            ),
                          );
                          break;
                        case CashbackAction.CASHOUT:
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return CashoutDialog();
                            },
                          ).then((txRef) => showTxResult(txRef, context));
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
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Ce doresti sa faci cu cashback-ul obtinut?',
              softWrap: true,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              CloseButton(),
            ],
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 2.0),
      content: Text(
        'Ai posibilitatea fie sa contribui la o lume mai buna, fie sa ii retragi (total sau partial).',
      ),
      actions: <Widget>[
        FlatButton(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              Text(
                'DONEAZA',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop(CashbackAction.DONATE);
          },
        ),
        FlatButton(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.monetization_on,
                color: Colors.green,
              ),
              Text(
                'RETRAGE',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop(CashbackAction.CASHOUT);
          },
        )
      ],
    );
  }

  Widget _donateViewBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doneaza'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: CharityWidget()),
        ],
      ),
    );
  }
}
