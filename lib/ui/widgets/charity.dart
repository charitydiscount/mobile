import 'package:flutter/material.dart';
import 'package:charity_discount/models/state.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:charity_discount/util/state_widget.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/case.dart';
import 'package:charity_discount/services/charity.dart';

class CharityWidget extends StatefulWidget {
  _CharityState createState() => _CharityState();
}

class _CharityState extends State<CharityWidget> {
  StateModel appState;
  bool _loadingVisible = false;
  Future<Map<String, Charity>> cases;

  @override
  void initState() {
    super.initState();
    cases = charityService.getCases();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).getState();

    if (appState.isLoading) {
      _loadingVisible = true;
    } else {
      _loadingVisible = false;
    }

    final casesBuilder = FutureBuilder<Map<String, Charity>>(
      future: cases,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shopWidgets = snapshot.data.values
              .map((c) => CaseWidget(charityCase: c))
              .toList();
          return Column(mainAxisSize: MainAxisSize.min, children: shopWidgets);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner
        return CircularProgressIndicator();
      },
    );

    return LoadingScreen(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[casesBuilder],
          ),
        ),
        inAsyncCall: _loadingVisible);
  }
}
