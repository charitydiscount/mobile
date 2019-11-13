import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class DonateDialog extends StatefulWidget {
  final Charity charityCase;
  final CharityService charityService;

  DonateDialog({
    Key key,
    @required this.charityCase,
    @required this.charityService,
  }) : super(key: key);

  @override
  _DonateDialogState createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text(
        AppLocalizations.of(context).tr(
          'operation.contributeTo',
          args: [widget.charityCase.title],
        ),
      ),
      body: DonateWidget(
        charityCase: widget.charityCase,
        formKey: _formKey,
        charityService: widget.charityService,
      ),
    );
  }
}

class DonateWidget extends StatefulWidget {
  final Charity charityCase;
  final GlobalKey<FormState> formKey;
  final CharityService charityService;

  DonateWidget({
    Key key,
    @required this.charityCase,
    @required this.formKey,
    @required this.charityService,
  }) : super(key: key);

  @override
  _DonateWidgetState createState() => _DonateWidgetState();
}

class _DonateWidgetState extends State<DonateWidget> {
  Observable<Wallet> _pointsListener;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    _pointsListener = widget.charityService.getPointsListener(
      AppModel.of(context).user.userId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tr = AppLocalizations.of(context).tr;
    return StreamBuilder<Wallet>(
      stream: _pointsListener,
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );
        if (loading != null) {
          return loading;
        }

        double balance = snapshot.data.cashback.acceptedAmount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${tr('account.availableCashback')} ${balance.toStringAsFixed(2)} RON',
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Form(
                key: widget.formKey,
                autovalidate: true,
                child: TextFormField(
                  autofocus: true,
                  controller: _amountController,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return null;
                    }

                    double amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Doar cifre';
                    }

                    if (double.parse(value) > balance) {
                      return tr('account.insufficientCashback');
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                    labelText: tr('operation.donationHint'),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(
                      RegExp(r'^\d+\.?\d{0,2}$'),
                    ),
                  ],
                ),
              ),
            ),
            ButtonBar(
              children: [
                FlatButton(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      Text(
                        tr('send').toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (widget.formKey.currentState.validate() &&
                        _amountController.text.isNotEmpty) {
                      var txRef = widget.charityService.createTransaction(
                        AppModel.of(context).user.userId,
                        TxType.DONATION,
                        double.tryParse(_amountController.text),
                        'RON',
                        widget.charityCase.id,
                      );

                      Navigator.of(context).pop(txRef);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class OperationDialog extends StatelessWidget {
  final Text title;
  final Widget body;

  const OperationDialog({
    Key key,
    @required this.title,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: <Widget>[
          Expanded(child: title),
          Flexible(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CloseButton(),
              ],
            ),
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 2.0),
      contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 2.0),
      children: <Widget>[
        Container(
          child: body,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }
}

Future<Widget> _waitForTx(DocumentReference txRef, BuildContext context) async {
  DocumentSnapshot tx = await txRef.snapshots().skip(1).firstWhere((tx) {
    return tx.data.containsKey('status');
  });
  String title;
  String message;
  String status = tx.data['status'];
  IconData notificationIcon;
  Color notifIconColor;

  var tr = AppLocalizations.of(context).tr;

  TxType txType = txTypeFromString(tx.data['type']);
  switch (txType) {
    case TxType.DONATION:
      if (status == 'ACCEPTED') {
        title = tr('operation.donationApproved.title');
        message = tr('operation.donationApproved.message');
        notificationIcon = Icons.check;
        notifIconColor = Colors.greenAccent;
      } else if (status == 'PENDING') {
        title = tr('operation.donationPending.title');
        message = tr('operation.donationPending.message');
        notificationIcon = Icons.info;
        notifIconColor = Colors.blueAccent;
      } else {
        title = tr('operation.donationRejected.title');
        message = tr('operation.donationRejected.message');
        notificationIcon = Icons.mood_bad;
        notifIconColor = Colors.redAccent;
      }
      break;
    case TxType.CASHOUT:
      if (status == 'ACCEPTED') {
        title = tr('operation.cashoutApproved.title');
        message = tr('operation.cashoutApproved.message');
        notificationIcon = Icons.check;
        notifIconColor = Colors.greenAccent;
      } else if (status == 'PENDING') {
        title = tr('operation.cashoutPending.title');
        message = tr('operation.cashoutPending.message');
        notificationIcon = Icons.info;
        notifIconColor = Colors.blueAccent;
      } else {
        title = tr('operation.cashoutRejected.title');
        message = tr('operation.cashoutRejected.message');
        notificationIcon = Icons.mood_bad;
        notifIconColor = Colors.redAccent;
      }
      break;
    default:
  }

  return Flushbar(
    title: title,
    message: message,
    icon: Icon(
      notificationIcon,
      color: notifIconColor,
    ),
    reverseAnimationCurve: Curves.linear,
  );
}

Future<void> showTxResult(DocumentReference txRef, BuildContext context) async {
  var actualContext = context;
  var flushBar = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder(
        future: _waitForTx(txRef, actualContext),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen(
              inAsyncCall: true,
              child: Container(),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop(snapshot.data);
          });
          return Container();
        },
      );
    },
  );
  flushBar?.show(actualContext);
}
