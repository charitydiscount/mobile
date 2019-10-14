import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/animated_pages.dart';
import 'package:charity_discount/util/authorize.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:iban_form_field/iban_form_field.dart';
import 'package:charity_discount/models/user.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/ui/widgets/operations.dart';

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
  List<String> _titles;
  bool _saveIban = false;
  PageController _pageController;
  AppModel _state;
  bool _done = false;

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
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _iban = Iban(iban.countryCode);
                  _iban.checkDigits = iban.checkDigits;
                  _iban.basicBankAccountNumber = iban.basicBankAccountNumber;
                });
              });
            },
            validator: (iban) {
              if (iban.isValid) {
                if (_iban == null ||
                    iban.electronicFormat != _iban.electronicFormat) {
                  _formKey.currentState.save();
                }
              }
              return null;
            },
            initialValue: _iban != null ? _iban : Iban('RO'),
          ),
        ),
        _accountNameForm,
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 0),
          child: CheckboxListTile(
            title: Text(AppLocalizations.of(context).tr('account.save')),
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
                'Saved Accounts',
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        ListView(
          shrinkWrap: true,
          primary: false,
          children: _state.user.savedAccounts
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
        ),
      ],
    );
  }

  void _deleteSavedAccount(SavedAccount savedAccount) {
    setState(() {
      _state.deleteSavedAccount(savedAccount);
    });
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
                fontSize: Theme.of(context).textTheme.display1.fontSize),
            validator: (String value) {
              if (value.isEmpty) {
                return null;
              }

              double amount = double.tryParse(value);
              if (amount == null) {
                return 'Doar numere';
              }

              if (amount > _state.wallet.cashback.acceptedAmount) {
                return AppLocalizations.of(context)
                    .tr('account.insufficientCashback');
              }

              _amount = amount;
              return null;
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              labelStyle: TextStyle(
                color: Colors.grey,
                fontSize: Theme.of(context).textTheme.subtitle.fontSize,
              ),
              labelText: AppLocalizations.of(context).tr('account.amountHint'),
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
                  '${AppLocalizations.of(context).tr('account.availableCashback')}: ${_state.wallet.cashback.acceptedAmount.toStringAsFixed(2)} RON',
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
                  trailing:
                      _done ? Icon(Icons.check, color: Colors.green) : null,
                ),
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.account_circle),
                  ),
                  title: Text(_accountNameController.text),
                  subtitle:
                      Text(AppLocalizations.of(context).tr('account.name')),
                  trailing:
                      _done ? Icon(Icons.check, color: Colors.green) : null,
                ),
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.monetization_on),
                  ),
                  title: Text(_amount.toStringAsFixed(2)),
                  subtitle:
                      Text(AppLocalizations.of(context).tr('account.amount')),
                  trailing:
                      _done ? Icon(Icons.check, color: Colors.green) : null,
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
                      '${AppLocalizations.of(context).tr('authorize')} & ${AppLocalizations.of(context).tr('send')}'
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      authorize(
                        context: context,
                        title: 'Authorize the transaction',
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
                                .then((txRef) =>
                                    showTxResult(txRef, context).then((_) {
                                      setState(() {
                                        _done = true;
                                      });
                                    }))
                            : print('Failed to auth'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
            labelText: AppLocalizations.of(context).tr('account.name'),
          ),
        ),
      );

  Widget get _accountAliasForm => _saveIban
      ? Container(
          child: TextField(
            controller: _accountAliasController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              labelText: AppLocalizations.of(context).tr('account.alias'),
              hasFloatingPlaceholder: false,
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

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (_stackIndex != 2) {
      actions.add(
        FlatButton(
          child: Text(AppLocalizations.of(context).tr('next')),
          textColor: Colors.white,
          onPressed: _iban == null ||
                  _accountNameController.text.length < 5 ||
                  !_iban.isValid ||
                  _stackIndex == 2
              ? null
              : () {
                  setState(() {
                    if (_saveIban &&
                        _state.user.savedAccounts.firstWhere(
                                (saved) => saved.iban == _iban.electronicFormat,
                                orElse: () => null) ==
                            null) {
                      _state.addSavedAccount(
                        SavedAccount(
                          iban: _iban.electronicFormat,
                          name: _accountNameController.text,
                          alias: _accountAliasController.text,
                        ),
                      );
                    }
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
        title: Text(AppLocalizations.of(context).tr(_titles[_stackIndex])),
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
            }
          });
        },
      ),
    );
  }
}
