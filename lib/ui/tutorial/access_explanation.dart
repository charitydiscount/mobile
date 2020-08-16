import 'package:charity_discount/state/state_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

SimpleDialog explanationDialogBuilder(BuildContext context) {
  Widget title = Text(tr('explanation.title'));
  Widget content = Text(tr('explanation.content'));
  Widget controls = ButtonBar(
    children: [
      Container(
        width: 160,
        child: CheckboxListTile(
          subtitle: Text(tr('explanation.disableExplanation')),
          dense: true,
          value: AppModel.of(context).explanationSkipped,
          onChanged: (value) {
            AppModel.of(context, rebuildOnChange: true).skipExplanation(value);
          },
        ),
      ),
      RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(
          tr('gotIt').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    ],
  );

  return SimpleDialog(
    title: Stack(
      children: <Widget>[
        title,
        Positioned(
          right: -10.0,
          top: -10.0,
          child: CloseButton(),
        ),
      ],
    ),
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: content,
          ),
          controls,
        ],
      ),
    ],
  );
}

Future<bool> showExplanationDialog(BuildContext context) async {
  if (AppModel.of(context).explanationSkipped) {
    return true;
  }

  bool continueToShop = await showDialog(
    context: context,
    builder: explanationDialogBuilder,
    barrierDismissible: false,
  );

  return continueToShop ?? false;
}
