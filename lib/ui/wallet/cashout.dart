import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/util/animated_pages.dart';
import 'package:charity_discount/util/authorize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:iban_form_field/iban_form_field.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/ui/wallet/operations.dart';
import 'package:async/async.dart';

class CashoutScreen extends StatefulWidget {
  final CharityService charityService;

  CashoutScreen({Key key, @required this.charityService}) : super(key: key);

  @override
  _CashoutScreenState createState() => _CashoutScreenState();
}

class _CashoutScreenState extends State<CashoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountAliasController = TextEditingController();
  int _stackIndex = 0;
  Iban _iban;
  double _amount = 0.0;
  bool _validAmount = false;
  List<String> _titles;
  bool _saveIban = false;
  PageController _pageController;
  AppModel _state;
  String _txResult = '';
  AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    _titles = ['account.account', 'account.amount', 'account.summary'];
    _state = AppModel.of(context);
  }

  Widget _buildAccountWidget() {
    return ListView(
      key: ValueKey<int>(0),
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Form(
          key: _formKey,
          autovalidate: true,
          child: IbanFormField(
            onSaved: (iban) {
              if (iban != null &&
                  iban.basicBankAccountNumber != null &&
                  iban.basicBankAccountNumber.isNotEmpty) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _iban = Iban(iban.countryCode);
                    _iban.checkDigits = iban.checkDigits;
                    _iban.basicBankAccountNumber = iban.basicBankAccountNumber;
                  });
                });
              }
            },
            validator: (iban) {
              _formKey.currentState.save();
              return null;
            },
            initialValue: _iban != null ? _iban : Iban('RO'),
          ),
        ),
        _accountNameForm,
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 0),
          child: CheckboxListTile(
            title: Text(tr('account.save')),
            dense: true,
            activeColor: Theme.of(context).primaryColor,
            value: _saveIban,
            onChanged: (newValue) => setState(() {
              _saveIban = newValue;
            }),
          ),
        ),
        _accountAliasForm,
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                tr('account.savedAccounts'),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        FutureBuilder(
            future: _asyncMemoizer.runOnce(() => _state.savedAccounts),
            builder: (context, snapshot) {
              var loading = buildConnectionLoading(
                context: context,
                snapshot: snapshot,
              );
              if (loading != null) {
                return loading;
              }

              List<SavedAccount> accounts = List.of(snapshot.data);
              return ListView(
                shrinkWrap: true,
                primary: false,
                children: accounts
                    .map(
                      (account) => Card(
                        child: ListTile(
                          title: Text(account.alias),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(account.fullIban.toPrintFormat),
                              Text(account.name),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            setState(() {
                              _iban = account.fullIban;
                              _accountNameController.text = account.name;
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.ease,
                              );
                            });
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteSavedAccount(account),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
      ],
    );
  }

  void _deleteSavedAccount(SavedAccount savedAccount) {
    setState(() {
      _state.deleteSavedAccount(savedAccount);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _accountAliasController.dispose();
    _accountNameController.dispose();
    _amountController.dispose();
  }

  Widget _buildAmountWidget() {
    return Container(
      key: ValueKey<int>(1),
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: _amountController,
            autovalidate: true,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline4.fontSize),
            validator: (String value) {
              if (value.isEmpty) {
                if (_validAmount != false) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() {
                      _validAmount = false;
                    }),
                  );
                }
                return null;
              }

              double amount = double.tryParse(value);
              if (amount == null) {
                if (_validAmount != false) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => setState(() {
                            _validAmount = false;
                          }));
                }
                return 'Doar numere';
              }

              if (amount > _state.wallet.cashback.acceptedAmount ||
                  _state.wallet.cashback.acceptedAmount <
                      _state.minimumWithdrawalAmount ||
                  amount < _state.minimumWithdrawalAmount) {
                if (_validAmount != false) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => setState(() {
                            _validAmount = false;
                          }));
                }
                return tr('account.insufficientCashback');
              }

              _amount = amount;
              if (_validAmount != true) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => setState(() {
                          _validAmount = true;
                        }));
              }
              return null;
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              labelStyle: TextStyle(
                color: Colors.grey,
                fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
              ),
              labelText: tr('account.amountHint'),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              WhitelistingTextInputFormatter(
                RegExp(r'^\d+\.?\d{0,2}$'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${tr('account.availableCashback')}: ${_state.wallet.cashback.acceptedAmount.toStringAsFixed(2)} RON',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryWidget() {
    return Container(
      key: ValueKey<int>(2),
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              primary: false,
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.account_balance),
                  ),
                  title: Text(_iban.toPrintFormat),
                  subtitle: Text('IBAN'),
                  trailing: getTrailingIcons(),
                ),
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.account_circle),
                  ),
                  title: Text(_accountNameController.text),
                  subtitle: Text(tr('account.name')),
                  trailing: getTrailingIcons(),
                ),
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.monetization_on),
                  ),
                  title: Text(_amount.toStringAsFixed(2)),
                  subtitle: Text(tr('account.amount')),
                  trailing: getTrailingIcons(),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(24.0),
            width: double.infinity,
            child: _done
                ? null
                : RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      '${tr('authorize')} & ${tr('send')}'.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      authorize(
                        context: context,
                        title: tr('authorizeFlow.title'),
                        charityService: widget.charityService,
                      ).then(
                        (didAuthenticate) => didAuthenticate == true
                            ? widget.charityService
                                .createTransaction(
                                  AppModel.of(context).user.userId,
                                  TxType.CASHOUT,
                                  double.tryParse(_amountController.text),
                                  'RON',
                                  AppModel.of(context).user.userId,
                                )
                                .then((txRef) => showTxResult(txRef, context)
                                        .then((txStatus) {
                                      setState(() {
                                        _txResult = txStatus;
                                      });
                                    }))
                                .catchError((error) => Flushbar(
                                      title:
                                          'Failed to create the transaction request',
                                      message: error.toString(),
                                      icon: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                      reverseAnimationCurve: Curves.linear,
                                    )?.show(context))
                            : print('Failed to auth'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool get _done => _txResult.isNotEmpty;

  Widget getTrailingIcons() {
    if (!_done) {
      return null;
    }

    if (_txResult == 'ACCEPTED') {
      return Icon(Icons.check, color: Colors.green);
    } else if (_txResult == 'PENDING') {
      return Icon(Icons.check, color: Colors.yellow);
    } else {
      return Icon(Icons.close, color: Colors.red);
    }
  }

  Widget get _accountNameForm => Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: TextFormField(
          controller: _accountNameController,
          textCapitalization: TextCapitalization.words,
          autovalidate: true,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.grey),
            labelText: tr('account.name'),
          ),
        ),
      );

  Widget get _accountAliasForm => _saveIban
      ? Container(
          child: TextField(
            controller: _accountAliasController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              labelText: tr('account.alias'),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              isDense: true,
            ),
          ),
        )
      : Container();

  Widget get _closeButton => IconButton(
        icon: Icon(Icons.close),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
      );

  Widget get _leadingButton {
    if (_done) {
      return _closeButton;
    }
    switch (_stackIndex) {
      case 0:
        return CloseButton();
      case 1:
        return BackButton();
      case 2:
        return BackButton();
      default:
        return BackButton();
    }
  }

  bool get _isAmountValid =>
      _stackIndex != 1 || (_stackIndex == 1 && _validAmount);

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (_stackIndex != 2) {
      actions.add(
        FlatButton(
          child: Text(tr('next')),
          textColor: Colors.white,
          onPressed: _iban == null ||
                  _accountNameController.text.length < 5 ||
                  !_iban.isValid ||
                  _stackIndex == 2 ||
                  !_isAmountValid
              ? null
              : () {
                  if (_saveIban) {
                    _state.addSavedAccount(
                      SavedAccount(
                        iban: _iban.electronicFormat,
                        name: _accountNameController.text,
                        alias: _accountAliasController.text,
                      ),
                    );
                  }
                  setState(() {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease,
                    );
                  });
                },
        ),
      );
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(_titles[_stackIndex])),
        automaticallyImplyLeading: false,
        leading: _leadingButton,
        actions: actions,
      ),
      body: AnimatedPages(
        itemCount: _titles.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index, pageController) {
          if (_pageController == null) {
            _pageController = pageController;
          }
          switch (index) {
            case 0:
              return _buildAccountWidget();
            case 1:
              return _buildAmountWidget();
            case 2:
              return _buildSummaryWidget();
            default:
              return Container();
          }
        },
        onPageChanged: (index) {
          setState(() {
            _stackIndex = index;
            if (index == 1 && _amountController.text.isEmpty) {
              _amountController.text =
                  _state.wallet.cashback.acceptedAmount.toStringAsFixed(2);
              if (_state.wallet.cashback.acceptedAmount >=
                  _state.minimumWithdrawalAmount) {
                _validAmount = true;
              }
            }
          });
        },
      ),
    );
  }
}
