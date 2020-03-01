import 'dart:math';

import 'package:charity_discount/models/program.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget buildLoading(BuildContext context, {Widget waitingDisplay}) {
  Widget waitingAdditionalWidget = waitingDisplay ?? Container();

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
              tr('connectionError'),
            ),
          ),
        ),
      ],
    );
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    return buildLoading(context, waitingDisplay: waitingDisplay);
  }

  if (!snapshot.hasData) {
    return Container();
  }

  return null;
}

String getProgramCommission(Program program) {
  String commission = '';
  if (program.saleCommissionRate != null) {
    switch (getCommissionTypeEnum(program.defaultSaleCommissionType)) {
      case CommissionType.fixed:
        commission = _buildCommissionForDisplay(
            commission, '${program.saleCommissionRate} ${program.currency}');
        break;
      case CommissionType.variable:
        commission =
            program.commissionMin != null && program.commissionMax != null
                ? program.commissionMinDisplay +
                    ' - ' +
                    program.commissionMaxDisplay +
                    '%'
                : _buildCommissionForDisplay(
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
            commission, '${program.leadCommissionAmount} ${program.currency}');
        break;
      case CommissionType.variable:
        commission = _buildCommissionForDisplay(
            commission, '~${program.leadCommissionAmount} ${program.currency}');
        break;
      default:
    }
  }

  return commission;
}

String _buildCommissionForDisplay(
  String currentCommission,
  String toBeAddedCommission,
) {
  return currentCommission.isEmpty
      ? toBeAddedCommission
      : '$currentCommission + $toBeAddedCommission';
}

SliverGridDelegate getGridDelegate(
  BuildContext context, {
  double aspectRatioFactor = 1.0,
  int rowDisplacement = 0,
  int maxPerRow,
}) {
  final width = MediaQuery.of(context).size.width;
  int perRow;
  double aspectRatio;
  if (width < 600.0) {
    perRow = 2;
    aspectRatio = 0.9;
  } else if (width < 1024.0) {
    perRow = 3;
    aspectRatio = MediaQuery.of(context).size.aspectRatio > 1.5 ? 1.0 : 1.3;
  } else {
    perRow = 4;
    aspectRatio = 1.4;
  }
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: maxPerRow != null
        ? min(maxPerRow, perRow + rowDisplacement)
        : perRow + rowDisplacement,
    childAspectRatio: aspectRatio * aspectRatioFactor,
  );
}
