import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/util/ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class DonateDialog extends StatefulWidget {
  final Charity charityCase;

  DonateDialog({Key key, this.charityCase}) : super(key: key);

  @override
  _DonateDialogState createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text('Contribuie la ${widget.charityCase.title}'),
      body: DonateWidget(
        charityCase: widget.charityCase,
        formKey: _formKey,
      ),
    );
  }
}

class DonateWidget extends StatefulWidget {
  final Charity charityCase;
  final GlobalKey<FormState> formKey;

  DonateWidget({Key key, this.charityCase, this.formKey}) : super(key: key);

  @override
  _DonateWidgetState createState() => _DonateWidgetState();
}

class _DonateWidgetState extends State<DonateWidget> {
  Observable<Wallet> _pointsListener;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    _pointsListener = charityService.getPointsListener(
      AppModel.of(context).user.userId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                'Cashback disponibil: ${balance.toStringAsFixed(2)} RON',
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
                      return 'Cashback insuficient';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                    labelText: "Suma cu care doresti sa contribui",
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
            ButtonTheme.bar(
              child: ButtonBar(
                children: [
                  FlatButton(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        Text(
                          'TRIMITE',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (widget.formKey.currentState.validate() &&
                          _amountController.text.isNotEmpty) {
                        var txRef = charityService.createTransaction(
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
            ),
          ],
        );
      },
    );
  }
}

class CashoutDialog extends StatefulWidget {
  CashoutDialog({Key key}) : super(key: key);

  _CashoutDialogState createState() => _CashoutDialogState();
}

class _CashoutDialogState extends State<CashoutDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Observable<Wallet> _pointsListener;

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text('Cashout'),
      body: CashoutWidget(formKey: _formKey),
    );
  }
}

class CashoutWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  CashoutWidget({Key key, this.formKey}) : super(key: key);

  @override
  _CashoutWidgetState createState() => _CashoutWidgetState();
}

class _CashoutWidgetState extends State<CashoutWidget> {
  Observable<Wallet> _pointsListener;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    _pointsListener = charityService.getPointsListener(
      AppModel.of(context).user.userId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                'Cashback disponibil: ${balance.toStringAsFixed(2)} RON',
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
                      return 'Doar numere';
                    }

                    if (double.parse(value) > balance) {
                      return 'Cashback insuficient';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                    labelText: "Suma pe care doresti sa o retragi",
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
            ButtonTheme.bar(
              child: ButtonBar(
                children: [
                  FlatButton(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.green,
                        ),
                        Text(
                          'RETRAGE',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (widget.formKey.currentState.validate() &&
                          _amountController.text.isNotEmpty) {
                        var txRef = charityService.createTransaction(
                          AppModel.of(context).user.userId,
                          TxType.CASHOUT,
                          double.tryParse(_amountController.text),
                          'RON',
                          AppModel.of(context).user.userId,
                        );

                        Navigator.of(context).pop(txRef);
                      }
                    },
                  ),
                ],
              ),
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
          title,
          Expanded(
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

  TxType txType = txTypeFromString(tx.data['type']);
  switch (txType) {
    case TxType.DONATION:
      if (status == 'ACCEPTED') {
        title = 'Donatie aprobata';
        message = 'Donatia a fost procesata cu success. Multumim!';
        notificationIcon = Icons.check;
        notifIconColor = Colors.greenAccent;
      } else if (status == 'PENDING') {
        title = 'Multumim!';
        message = 'Donatia este in curs de procesare';
        notificationIcon = Icons.info;
        notifIconColor = Colors.blueAccent;
      } else {
        title = 'Donation respinsa';
        message = 'Tranzactia nu a putut fi procesata';
        notificationIcon = Icons.mood_bad;
        notifIconColor = Colors.redAccent;
      }
      break;
    case TxType.CASHOUT:
      if (status == 'ACCEPTED') {
        title = 'Cashout aprobat';
        message =
            'Poate dura 2-3 zile lucratoare pana bancile proceseaza tranzactia';
        notificationIcon = Icons.check;
        notifIconColor = Colors.greenAccent;
      } else if (status == 'PENDING') {
        title = 'Multumim!';
        message = 'Tranzactia este in curs de procesare';
        notificationIcon = Icons.info;
        notifIconColor = Colors.blueAccent;
      } else {
        title = 'Cashout respins';
        message = 'Tranzactia nu a putut fi procesata';
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
