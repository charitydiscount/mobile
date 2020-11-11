import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AccessButtonType {
  FLAT,
  FLOATING,
}

class AccessButton extends StatefulWidget {
  final AccessButtonType buttonType;
  final String url;
  final String programId;
  final String programName;
  final String eventScreen;
  final TextStyle textStyle;

  AccessButton({
    Key key,
    @required this.buttonType,
    @required this.url,
    @required this.programId,
    @required this.programName,
    @required this.eventScreen,
    this.textStyle,
  }) : super(key: key);

  @override
  _AccessButtonState createState() => _AccessButtonState();
}

class _AccessButtonState extends State<AccessButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return widget.buttonType == AccessButtonType.FLAT
        ? FlatButton(
            padding: EdgeInsets.zero,
            child: _buildChild('access'),
            onPressed: _onPressed,
          )
        : FloatingActionButton.extended(
            icon: const Icon(Icons.open_in_new),
            label: _buildChild('accessShop'),
            onPressed: _onPressed,
          );
  }

  Function get _onPressed => _loading
      ? null
      : () async {
          setState(() {
            _loading = true;
          });
          try {
            await openAffiliateLink(
              widget.url,
              context,
              widget.programId,
              widget.programName,
              widget.eventScreen,
            );
          } catch (e) {
            print(e);
          }
          setState(() {
            _loading = false;
          });
        };

  Widget _buildChild(String textKey) => widget.buttonType == AccessButtonType.FLAT
      ? _loading
          ? Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 3.0),
            )
          : Text(
              tr(textKey),
              style: widget.textStyle,
            )
      : Container(
          width: 150,
          child: Center(
            child: _loading
                ? Container(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    tr(textKey),
                    style: widget.textStyle,
                  ),
          ),
        );
}
