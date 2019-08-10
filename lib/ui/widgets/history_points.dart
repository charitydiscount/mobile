import 'package:charity_discount/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class HistoryPointsWidget extends StatelessWidget {
  final List<Transaction> transactions;

  HistoryPointsWidget({Key key, this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TimelineModel> items = transactions.map((tx) {
      Icon txIcon;
      Color iconBackground;
      switch (tx.type) {
        case TxType.BONUS:
          txIcon = Icon(Icons.add_circle_outline, color: Colors.white);
          iconBackground = Colors.green;
          break;
        case TxType.CASHOUT:
          txIcon = Icon(Icons.file_upload, color: Colors.white);
          iconBackground = Colors.blueGrey;
          break;
        case TxType.DONATION:
          txIcon = Icon(Icons.favorite_border, color: Colors.white);
          iconBackground = Colors.red;
          break;
        default:
      }
      return TimelineModel(
        TransactionDetails(tx: tx),
        position: TimelineItemPosition.random,
        iconBackground: iconBackground,
        icon: txIcon,
      );
    }).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Timeline(
        children: items,
        position: TimelinePosition.Center,
        lineColor: Theme.of(context).textTheme.body2.color,
        shrinkWrap: true,
      ),
    );
  }
}

class TransactionDetails extends StatelessWidget {
  final Transaction tx;

  const TransactionDetails({Key key, this.tx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        child: ListTile(
          title: Text('${tx.amount.toString()} ${tx.currency}'),
          subtitle: Text(DateFormat.yMd('ro_RO').add_jm().format(tx.date)),
        ),
      ),
    );
  }
}
