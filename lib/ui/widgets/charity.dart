import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:charity_discount/ui/widgets/loading.dart';
import 'package:charity_discount/ui/widgets/case.dart';
import 'package:charity_discount/services/charity.dart';

class CharityWidget extends StatefulWidget {
  _CharityState createState() => _CharityState();
}

class _CharityState extends State<CharityWidget>
    with AutomaticKeepAliveClientMixin {
  bool _loadingVisible = false;
  Future<Map<String, Charity>> cases;

  @override
  void initState() {
    super.initState();
    cases = charityService.getCases();
  }

  Widget build(BuildContext context) {
    super.build(context);
    final casesBuilder = FutureBuilder<Map<String, Charity>>(
      future: cases,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).accentColor),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Text('No data available');
        }

        final caseWidgets = snapshot.data.entries
            .map((entry) =>
                CaseWidget(key: Key(entry.key), charityCase: entry.value))
            .toList();
        return Expanded(
          child: ListView(
              key: Key('casesList'),
              children: caseWidgets,
              addAutomaticKeepAlives: true,
              primary: true),
        );
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

  @override
  bool get wantKeepAlive => true;
}
