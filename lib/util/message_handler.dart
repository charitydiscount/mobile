import 'dart:async';
import 'dart:io';
import 'package:charity_discount/services/meta.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class MessageHandler extends StatefulWidget {
  final Widget child;

  MessageHandler({Key key, this.child}) : super(key: key);

  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

final FirebaseMessaging fcm = FirebaseMessaging();

class _MessageHandlerState extends State<MessageHandler> {
  StreamSubscription _iosSubscription;

  @override
  void initState() {
    super.initState();

    final state = AppModel.of(context);
    if (state.isNewDevice) {
      if (Platform.isIOS) {
        _iosSubscription = fcm.onIosSettingsRegistered.listen((data) {
          _registerFcmToken();
        });
        fcm.requestNotificationPermissions();
      } else {
        _registerFcmToken();
      }
      state.setKnownDevice();
    }

    fcm.getToken().then((token) => print(token));
    if (state.settings.notifications) {
      fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          Flushbar(
            title: message['notification']['title'],
            message: message['notification']['body'],
          ).show(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _registerFcmToken() async {
    final token = await fcm.getToken();
    var user = await FirebaseAuth.instance.currentUser();
    metaService.addFcmToken(user.uid, token);
  }

  @override
  void dispose() {
    super.dispose();
    _iosSubscription.cancel();
  }
}
