import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/commission.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class CommissionsScreen extends StatelessWidget {
  final CharityService charityService;

  const CommissionsScreen({Key key, this.charityService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).tr('wallet.commissions'),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyText1.color,
        ),
      ),
      body: FutureBuilder<List<Program>>(
        future: AppModel.of(context).programsFuture,
        builder: (context, programsSnapshot) {
          final loading = buildConnectionLoading(
            context: context,
            snapshot: programsSnapshot,
          );
          if (loading != null) {
            return loading;
          }
          return FutureBuilder<List<Commission>>(
            future: charityService.getUserCommissions(),
            builder: (context, snapshot) {
              final loading = buildConnectionLoading(
                context: context,
                snapshot: snapshot,
              );
              if (loading != null) {
                return loading;
              }

              return CommissionsWidget(
                commissions: snapshot.data,
                programs: programsSnapshot.data,
              );
            },
          );
        },
      ),
    );
  }
}

class CommissionsWidget extends StatelessWidget {
  final List<Commission> commissions;
  final List<Program> programs;

  CommissionsWidget({
    Key key,
    @required this.commissions,
    @required this.programs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TimelineModel> items = commissions.map((commission) {
      final program = programs.firstWhere((p) => p.id == commission.shopId,
          orElse: () => null);
      return TimelineModel(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CommissionDetails(
            commission: commission,
            program: program,
          ),
        ),
        position: TimelineItemPosition.right,
        iconBackground: _getcommissionColor(commission),
        icon: Icon(Icons.monetization_on, color: Colors.white),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Timeline(
        children: items,
        position: TimelinePosition.Left,
        lineColor: Theme.of(context).textTheme.bodyText1.color,
        shrinkWrap: true,
      ),
    );
  }
}

Color _getcommissionColor(Commission commission) {
  switch (parseCommissionStatus(commission.status)) {
    case CommissionStatus.pending:
      return Colors.yellowAccent.shade700;
    case CommissionStatus.accepted:
      return Colors.blueGrey;
    case CommissionStatus.paid:
      return Colors.green;
    case CommissionStatus.rejected:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _getcommissionStatusName(Commission commission, BuildContext context) {
  return AppLocalizations.of(context).tr(commission.status.toLowerCase());
}

class CommissionDetails extends StatelessWidget {
  final Commission commission;
  final Program program;

  const CommissionDetails({
    Key key,
    @required this.commission,
    @required this.program,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = commission?.program?.logo ?? program?.logoPath;
    return Card(
      child: ListTile(
        isThreeLine: true,
        title: Text(
            '${commission.amount.toStringAsFixed(2)} ${commission.currency}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _getcommissionStatusName(commission, context),
              style: TextStyle(color: _getcommissionColor(commission)),
            ),
            commission.reason != null
                ? Text(
                    commission.reason,
                    style: Theme.of(context).textTheme.caption,
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                formatDateTime(commission.createdAt),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
        trailing: logo != null
            ? CachedNetworkImage(
                imageUrl: logo,
                width: 100,
                alignment: Alignment.center,
                fit: BoxFit.fitHeight,
              )
            : Container(width: 0),
      ),
    );
  }
}
