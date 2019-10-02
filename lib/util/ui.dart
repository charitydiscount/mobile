import 'package:flutter/material.dart';

Widget buildConnectionLoading({
  @required BuildContext context,
  @required AsyncSnapshot snapshot,
  Widget waitingDisplay,
  bool handleError = true,
}) {
  if (snapshot.hasError) {
    if (!handleError) {
      return null;
    }
    print(snapshot.error);
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            Icons.signal_wifi_off,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              "Aparent, conexiunea cu serviciile Charity Discount nu poate fi stabilita",
            ),
          ),
        ),
      ],
    );
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    Widget waitingAdditionalWidget =
        waitingDisplay != null ? waitingDisplay : Container();
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: waitingAdditionalWidget,
            ),
          ],
        ),
      ),
    );
  }

  if (!snapshot.hasData) {
    return Text('No data available');
  }

  return null;
}
