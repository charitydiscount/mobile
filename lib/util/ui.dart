import 'package:charity_discount/models/program.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget buildConnectionLoading({
  @required BuildContext context,
  @required AsyncSnapshot snapshot,
  Widget waitingDisplay,
  bool handleError = true,
}) {
  if (snapshot.hasError) {
    if (!handleError) {
      return null;
    }
    print(snapshot.error);
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            Icons.signal_wifi_off,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              AppLocalizations.of(context).tr('connectionError'),
            ),
          ),
        ),
      ],
    );
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    Widget waitingAdditionalWidget =
        waitingDisplay != null ? waitingDisplay : Container();
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: waitingAdditionalWidget,
            ),
          ],
        ),
      ),
    );
  }

  if (!snapshot.hasData) {
    return Text('No data available');
  }

  return null;
}

String getProgramCommission(Program program) {
  String commission = '';
  if (program.saleCommissionRate != null) {
    switch (getCommissionTypeEnum(program.defaultSaleCommissionType)) {
      case CommissionType.fixed:
        commission = _buildCommissionForDisplay(
            commission, '${program.saleCommissionRate}RON');
        break;
      case CommissionType.variable:
        commission = _buildCommissionForDisplay(
            commission, '~${program.saleCommissionRate}%');
        break;
      case CommissionType.percent:
        commission = _buildCommissionForDisplay(
            commission, '${program.saleCommissionRate}%');
        break;
    }
  }

  if (program.leadCommissionAmount != null &&
      program.saleCommissionRate == null) {
    switch (getCommissionTypeEnum(program.defaultLeadCommissionType)) {
      case CommissionType.fixed:
        commission = _buildCommissionForDisplay(
            commission, '${program.leadCommissionAmount}RON');
        break;
      case CommissionType.variable:
        commission = _buildCommissionForDisplay(
            commission, '~${program.leadCommissionAmount}RON');
        break;
      default:
    }
  }

  return commission;
}

String _buildCommissionForDisplay(
    String currentCommission, String toBeAddedCommission) {
  return currentCommission.isEmpty
      ? toBeAddedCommission
      : '$currentCommission + $toBeAddedCommission';
}
