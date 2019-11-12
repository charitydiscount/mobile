import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/screens/cashout.dart';
import 'package:charity_discount/ui/screens/transactions.dart';
import 'package:charity_discount/ui/widgets/about_points.dart';
import 'package:charity_discount/ui/widgets/charity.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum CashbackAction { CANCEL, DONATE, CASHOUT }

class WalletScreen extends StatelessWidget {
  final CharityService charityService;

  WalletScreen({Key key, @required this.charityService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).tr;

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

        AppModel state = AppModel.of(context);
        state.wallet = snapshot.data;
        state.wallet.transactions.sort((t1, t2) => t2.date.compareTo(t1.date));

        return ListView(
          primary: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: <Widget>[
                  AboutPointsWidget(
                    points: state.wallet.charityPoints,
                    headingLeading: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    heading: tr('wallet.points.title'),
                    subtitle: tr('wallet.points.subtitle'),
                    acceptedTitle: tr('wallet.points.available'),
                    acceptedDescription: tr('wallet.points.description'),
                    acceptedAction: IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).accentColor,
                      ),
                      iconSize: 25,
                      onPressed: () {},
                    ),
                  ),
                  Positioned.fill(
                    child: Card(
                      color: Colors.transparent,
                      child: Container(
                        color: Colors.grey.withOpacity(0.65),
                        child: Center(
                          child: RotationTransition(
                            turns: AlwaysStoppedAnimation(15 / 360),
                            child: Text(
                              tr('soon'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AboutPointsWidget(
                points: state.wallet.cashback,
                headingLeading: Icon(
                  Icons.monetization_on,
                  color: Colors.green,
                ),
                heading: tr('wallet.cashback.title'),
                subtitle: tr('wallet.cashback.subtitle'),
                acceptedTitle: tr('wallet.cashback.available.title'),
                acceptedDescription:
                    tr('wallet.cashback.available.description'),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              maintainState: true,
                              builder: (context) =>
                                  CashoutScreen(charityService: charityService),
                              settings: RouteSettings(name: 'Cashout'),
                            ),
                          );
                          break;
                        default:
                          return;
                      }
                    });
                  },
                ),
                pendingTitle: tr('wallet.cashback.pending.title'),
                pendingDescription: tr('wallet.cashback.pending.description'),
              ),
            ),
            FlatButton(
              child: Text(
                tr('wallet.history'),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TransactionsScreen(
                      transactions: state.wallet.transactions,
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
    final tr = AppLocalizations.of(context).tr;
    final wallet = AppModel.of(context).wallet;
    final minAmount = AppModel.of(context).minimumWithdrawalAmount;
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              tr('wallet.cashback.dialog.title'),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(tr('wallet.cashback.dialog.description')),
          Divider(),
          Text(
            tr(
              'wallet.cashback.dialog.minimumAmount',
              args: ['${minAmount}RON'],
            ),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
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
                tr('donate'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop(CashbackAction.DONATE);
          },
        ),
        wallet.cashback.acceptedAmount >= minAmount
            ? FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.monetization_on,
                      color: Colors.green,
                    ),
                    Text(
                      tr('withdraw'),
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop(CashbackAction.CASHOUT);
                },
                disabledTextColor: Colors.black,
              )
            : Container()
      ],
    );
  }

  Widget _donateViewBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('donate')),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CharityWidget(charityService: charityService),
          ),
        ],
      ),
    );
  }
}
