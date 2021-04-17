import 'dart:async';
import 'package:charity_discount/services/charity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Otp extends StatefulWidget {
  final CharityService charityService;

  Otp({Key key, @required this.charityService}) : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> with SingleTickerProviderStateMixin {
  final int time = 30;
  AnimationController _controller;

  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

  String userName = '';
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: Icon(Icons.arrow_back),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }

  get _getVerificationCodeLabel {
    return Text(
      tr('authorizeFlow.title'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  get _getEmailLabel {
    return Text(
      tr('authorizeFlow.subtitle'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  get _getInputField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
      ],
    );
  }

  get _getInputPart {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _getVerificationCodeLabel,
        _getEmailLabel,
        _getInputField,
        _getActions,
        _getOtpKeyboard,
      ],
    );
  }

  get _getActions {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _getPasteButton,
        _hideResendButton ? _getTimerText : _getResendButton,
      ],
    );
  }

  get _getPasteButton {
    return InkWell(
      child: Container(
        height: 32,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: Text(
          tr('authorizeFlow.paste'),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      onTap: () {
        Clipboard.getData(Clipboard.kTextPlain).then((clipdboardData) {
          if (clipdboardData.text.length != 4 ||
              !clipdboardData.text.contains(RegExp(r'^[0-9]*$'))) {
            Flushbar(
              title: tr('authorizeFlow.pasteError.title'),
              message: tr('authorizeFlow.pasteError.message'),
            )..show(context);
            return;
          }

          setState(() {
            _firstDigit = int.parse(clipdboardData.text.substring(0, 1));
            _secondDigit = int.parse(clipdboardData.text.substring(1, 2));
            _thirdDigit = int.parse(clipdboardData.text.substring(2, 3));
            _fourthDigit = int.parse(clipdboardData.text.substring(3, 4));
          });

          _checkOtp(_code);
        });
      },
    );
  }

  get _getTimerText {
    return Container(
      height: 32,
      child: Offstage(
        offstage: !_hideResendButton,
        child: Stack(
          children: <Widget>[
            _getResendButton,
            Container(
              height: 32,
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.8),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(32),
              ),
              child: OtpTimer(controller: _controller),
            )
          ],
        ),
      ),
    );
  }

  get _getResendButton {
    return InkWell(
      child: Container(
        height: 32,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: Text(
          tr('authorizeFlow.resend'),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      onTap: () {
        widget.charityService.sendOtpCode();
        _startCountdown();
      },
    );
  }

  get _getOtpKeyboard {
    return Container(
      height: _screenSize.width - 80,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: '1',
                    onPressed: () {
                      _setCurrentDigit(1);
                    }),
                _otpKeyboardInputButton(
                    label: '2',
                    onPressed: () {
                      _setCurrentDigit(2);
                    }),
                _otpKeyboardInputButton(
                    label: '3',
                    onPressed: () {
                      _setCurrentDigit(3);
                    }),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: '4',
                    onPressed: () {
                      _setCurrentDigit(4);
                    }),
                _otpKeyboardInputButton(
                    label: '5',
                    onPressed: () {
                      _setCurrentDigit(5);
                    }),
                _otpKeyboardInputButton(
                    label: '6',
                    onPressed: () {
                      _setCurrentDigit(6);
                    }),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: '7',
                    onPressed: () {
                      _setCurrentDigit(7);
                    }),
                _otpKeyboardInputButton(
                    label: '8',
                    onPressed: () {
                      _setCurrentDigit(8);
                    }),
                _otpKeyboardInputButton(
                    label: '9',
                    onPressed: () {
                      _setCurrentDigit(9);
                    }),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 80.0,
                ),
                _otpKeyboardInputButton(
                    label: '0',
                    onPressed: () {
                      _setCurrentDigit(0);
                    }),
                _otpKeyboardActionButton(
                    label: Icon(
                      Icons.backspace,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_fourthDigit != null) {
                          _fourthDigit = null;
                        } else if (_thirdDigit != null) {
                          _thirdDigit = null;
                        } else if (_secondDigit != null) {
                          _secondDigit = null;
                        } else if (_firstDigit != null) {
                          _firstDigit = null;
                        }
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    totalTimeInSeconds = time;
    widget.charityService.sendOtpCode();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton;
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _getAppbar,
      body: Container(
        width: _screenSize.width,
        child: _getInputPart,
      ),
    );
  }

  Widget _otpTextField(int digit) {
    return Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: Text(
        digit != null ? digit.toString() : '',
        style: TextStyle(
          fontSize: 30.0,
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          height: 80.0,
          width: 80.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        height: 80.0,
        width: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label,
        ),
      ),
    );
  }

  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      }
    });

    if (_fourthDigit != null) {
      _checkOtp(_code);
    }
  }

  int get _code {
    return _firstDigit * 1000 +
        _secondDigit * 100 +
        _thirdDigit * 10 +
        _fourthDigit;
  }

  void _startCountdown() {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }

  void _checkOtp(int otp) {
    widget.charityService.checkOtpCode(otp).then((authorized) {
      if (authorized == true) {
        Navigator.pop(context, authorized);
      } else {
        Flushbar(
          title: tr('authorizeFlow.checkError.title'),
          message: tr('authorizeFlow.checkError.subtitle'),
        )..show(context);
      }
    });
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;

  OtpTimer({this.controller});

  String get timerString {
    Duration duration = controller.duration * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) {
        return Text(
          timerString,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
