import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget reAuthDialogBuilder(context) {
  Widget cancelButton = TextButton(
    child: Text(tr('cancel')),
    onPressed: () {
      Navigator.pop(context, false);
    },
  );
  Widget continueButton = TextButton(
    child: Text('OK'),
    onPressed: () {
      Navigator.pop(context, true);
    },
  );

  return AlertDialog(
    content: Text(tr('signInAgain')),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
}
