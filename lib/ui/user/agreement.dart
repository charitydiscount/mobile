import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AgreementDialog extends StatefulWidget {
  AgreementDialog({Key key}) : super(key: key);

  @override
  _AgreementDialogState createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<AgreementDialog> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(tr('cancel')),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = TextButton(
      child: Text(tr('agree')),
      onPressed: _acceptedTerms && _acceptedPrivacy
          ? () {
              Navigator.pop(context, true);
            }
          : null,
    );

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAgreementEntry(_AgreementEntry.TERMS),
          _buildAgreementEntry(_AgreementEntry.PRIVACY),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }

  Widget _buildAgreementEntry(_AgreementEntry _agreementEntry) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Checkbox(
            value: _agreementEntry == _AgreementEntry.PRIVACY
                ? _acceptedPrivacy
                : _acceptedTerms,
            onChanged: (newValue) {
              setState(() {
                if (_agreementEntry == _AgreementEntry.PRIVACY) {
                  _acceptedPrivacy = newValue;
                } else {
                  _acceptedTerms = newValue;
                }
              });
            },
          ),
          RichText(
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.left,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tr('agreeTo')} ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: tr(_agreementEntry == _AgreementEntry.PRIVACY
                      ? 'privacy'
                      : 'terms'),
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (_agreementEntry == _AgreementEntry.PRIVACY) {
                        UrlHelper.launchPrivacy();
                      } else {
                        UrlHelper.launchTerms();
                      }
                    },
                ),
              ],
            ),
          ),
        ],
      );
}

enum _AgreementEntry {
  PRIVACY,
  TERMS,
}
