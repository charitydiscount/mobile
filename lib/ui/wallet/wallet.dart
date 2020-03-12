import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/wallet/cashout.dart';
import 'package:charity_discount/ui/wallet/commissions.dart';
import 'package:charity_discount/ui/wallet/transactions.dart';
import 'package:charity_discount/ui/wallet/about_points.dart';
import 'package:charity_discount/ui/charity/charity.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum CashbackAction { CANCEL, DONATE, CASHOUT }

class WalletScreen extends StatelessWidget {
  final CharityService charityService;

  WalletScreen({Key key, @required this.charityService}) : super(key: key);

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

        AppModel state = AppModel.of(context);
        state.wallet = snapshot.data;
        state.wallet.transactions.sort((t1, t2) => t2.date.compareTo(t1.date));

        return ListView(
          primary: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AboutPointsWidget(
                points: state.wallet.cashback,
                currency: 'RON',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AboutPointsWidget(
                points: state.wallet.charityPoints,
                currency: 'Charity Points',
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
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: tr('wallet.points.description'));
                  },
                ),
              ),
            ),
            FlatButton(
              child: Text(
                tr('wallet.commissions'),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CommissionsScreen(
                      charityService: charityService,
                    ),
                    settings: RouteSettings(name: 'Commissions'),
                  ),
                );
              },
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
              args: ['${minAmount}Lei'],
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
        FlatButton(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.monetization_on,
                color: wallet.cashback.acceptedAmount >= minAmount
                    ? Colors.green
                    : Colors.grey,
              ),
              Text(
                tr('withdraw'),
                style: TextStyle(
                    color: wallet.cashback.acceptedAmount >= minAmount
                        ? Colors.green
                        : Colors.grey),
              ),
            ],
          ),
          onPressed: wallet.cashback.acceptedAmount >= minAmount
              ? () {
                  Navigator.of(context).pop(CashbackAction.CASHOUT);
                }
              : null,
          disabledTextColor: Colors.black,
        ),
      ],
    );
  }

  Widget _donateViewBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('donate')),
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
