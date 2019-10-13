import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/ui/widgets/history_points.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionsScreen({Key key, this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).tr('transactionHistory'),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.body2.color,
        ),
      ),
      body: HistoryPointsWidget(transactions: transactions),
    );
  }
}
