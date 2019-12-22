import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class HistoryPointsWidget extends StatelessWidget {
  final List<Transaction> transactions;

  HistoryPointsWidget({Key key, this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TimelineModel> items = transactions.map((tx) {
      Icon txIcon;
      switch (tx.type) {
        case TxType.BONUS:
          txIcon = Icon(Icons.add_circle_outline, color: Colors.white);
          break;
        case TxType.CASHOUT:
          txIcon = Icon(Icons.file_upload, color: Colors.white);
          break;
        case TxType.DONATION:
          txIcon = Icon(Icons.favorite_border, color: Colors.white);
          break;
        case TxType.COMMISSION:
          txIcon = Icon(Icons.monetization_on, color: Colors.white);
          break;
        default:
      }
      return TimelineModel(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TransactionDetails(tx: tx),
        ),
        position: TimelineItemPosition.right,
        iconBackground: _getTxColor(tx),
        icon: txIcon,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Timeline(
        children: items,
        position: TimelinePosition.Left,
        lineColor: Theme.of(context).textTheme.body2.color,
        shrinkWrap: true,
      ),
    );
  }
}

Color _getTxColor(Transaction transaction) {
  switch (transaction.type) {
    case TxType.BONUS:
      return Colors.green;
    case TxType.CASHOUT:
      return Colors.blueGrey;
    case TxType.DONATION:
      return Colors.red;
    case TxType.COMMISSION:
      return Colors.cyan;
    default:
      return Colors.grey;
  }
}

String _getTxTypeName(Transaction transaction, BuildContext context) {
  return AppLocalizations.of(context)
      .tr(describeEnum(transaction.type).toLowerCase());
}

class TransactionDetails extends StatelessWidget {
  final Transaction tx;

  const TransactionDetails({Key key, this.tx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int decimalsToDisplay = tx.type == TxType.BONUS ? 4 : 2;
    return Card(
      child: ListTile(
        title: Text(
            '${tx.amount.toStringAsFixed(decimalsToDisplay)} ${tx.currency}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(formatDateTime(tx.date)),
          ],
        ),
        trailing: Text(
          _getTxTypeName(tx, context),
          style: TextStyle(color: _getTxColor(tx)),
        ),
      ),
    );
  }
}
