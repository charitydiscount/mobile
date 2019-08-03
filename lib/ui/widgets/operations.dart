import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/ui.dart';
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
    return SimpleDialog(
      title: Text('Contribuie la ${widget.charityCase.title}'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 2.0),
      children: <Widget>[
        Container(
          child: DonateWidget(
            charityCase: widget.charityCase,
            formKey: _formKey,
          ),
          width: MediaQuery.of(context).size.width,
        ),
      ],
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
                'Cashback disponibil: ${balance.toString()} RON',
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
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                ),
              ),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: [
                  FlatButton(
                    child: Text('RENUNTA'),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                  ),
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
                        charityService
                            .createTransaction(
                          AppModel.of(context).user.userId,
                          TxType.DONATION,
                          double.tryParse(_amountController.text),
                          'RON',
                          widget.charityCase.id,
                        )
                            .then((createResult) {
                          Navigator.of(context).pop(true);
                        });
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
    return SimpleDialog(
      title: Text('Cashout'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 2.0),
      children: <Widget>[
        Container(
          child: CashoutWidget(formKey: _formKey),
          width: MediaQuery.of(context).size.width,
        ),
      ],
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
                'Cashback disponibil: ${balance.toString()} RON',
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
                    labelText: "Suma pe care doresti sa o retragi",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                ),
              ),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: [
                  FlatButton(
                    child: Text('RENUNTA'),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                  ),
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
                        charityService
                            .createTransaction(
                          AppModel.of(context).user.userId,
                          TxType.CASHOUT,
                          double.tryParse(_amountController.text),
                          'RON',
                          AppModel.of(context).user.userId,
                        )
                            .then((createResult) {
                          Navigator.of(context).pop(true);
                        });
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
