import 'package:flutter/material.dart';

Widget buildConnectionLoading({BuildContext context, AsyncSnapshot snapshot}) {
  if (snapshot.hasError) {
    return Text("${snapshot.error}");
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
        ),
      ),
    );
  }

  if (!snapshot.hasData) {
    return Text('No data available');
  }

  return null;
}
