import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/util/animated_pages.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:iban_form_field/iban_form_field.dart';

class CashoutScreen extends StatefulWidget {
  CashoutScreen({Key key}) : super(key: key);

  @override
  _CashoutScreenState createState() => _CashoutScreenState();
}

class _CashoutScreenState extends State<CashoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  int _stackIndex = 0;
  Iban _iban;
  double _amount = 0.0;
  List<String> _titles;
  bool _saveIban = false;
  PageController _pageController;
  AppModel _state;

  @override
  void initState() {
    super.initState();
    _titles = [
      'account.account',
      'account.amount',
    ];
    _state = AppModel.of(context);
  }

  Widget _buildAccountWidget() {
    return Container(
      key: ValueKey<int>(0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          _accountNameForm,
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
            children: _state.wallet.savedAccounts
                .map(
                  (account) => Card(
                    child: ListTile(
                      title: Text(account.fullIban.toPrintFormat),
                      subtitle: Text(account.name),
                      onTap: () {
                        setState(() {
                          _iban = account.fullIban;
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
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: _amountController,
            validator: (String value) {
              if (value.isEmpty) {
                return null;
              }

              double amount = double.tryParse(value);
              if (amount == null) {
                return 'Doar numere';
              }

              if (double.parse(value) > _amount) {
                return 'Cashback insuficient';
              }

              return null;
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              labelStyle: TextStyle(color: Colors.grey),
              labelText: 'Suma pe care doresti sa o retragi',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              WhitelistingTextInputFormatter(
                RegExp(r'^\d+\.?\d{0,2}$'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _accountNameForm => _saveIban
      ? Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: TextField(
            controller: _accountNameController,
            decoration: InputDecoration(
                // border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey),
                labelText: AppLocalizations.of(context).tr('account.name'),
                hasFloatingPlaceholder: false,
                isDense: true),
          ),
        )
      : Container();

  Widget get _leadingButton {
    switch (_stackIndex) {
      case 0:
        return CloseButton();
        break;
      case 1:
        return IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            setState(() {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.ease,
              );
            });
          },
        );
        break;
      default:
        return BackButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr(_titles[_stackIndex])),
        automaticallyImplyLeading: false,
        leading: _leadingButton,
        actions: <Widget>[
          FlatButton(
            child: Text('Next'),
            textColor: Colors.white,
            onPressed: _iban == null || !_iban.isValid
                ? null
                : () {
                    setState(() {
                      if (_saveIban &&
                          _state.wallet.savedAccounts.firstWhere(
                                  (saved) =>
                                      saved.iban == _iban.electronicFormat,
                                  orElse: () => null) ==
                              null) {
                        _state.addSavedAccount(
                          SavedAccount(
                              iban: _iban.electronicFormat,
                              name: _accountNameController.text),
                        );
                      }
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.ease,
                      );
                    });
                  },
          )
        ],
      ),
      body: AnimatedPages(
        itemCount: 2,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index, pageController) {
          if (_pageController == null) {
            _pageController = pageController;
          }
          return index == 0 ? _buildAccountWidget() : _buildAmountWidget();
        },
        onPageChanged: (index) => setState(() => _stackIndex = index),
      ),
    );
  }
}
