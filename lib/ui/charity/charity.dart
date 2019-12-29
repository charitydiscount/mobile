import 'package:charity_discount/ui/app/util.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:charity_discount/ui/app/loading.dart';
import 'package:charity_discount/ui/charity/case.dart';
import 'package:charity_discount/services/charity.dart';

class CharityWidget extends StatefulWidget {
  final CharityService charityService;

  const CharityWidget({
    Key key,
    @required this.charityService,
  }) : super(key: key);

  _CharityState createState() => _CharityState();
}

class _CharityState extends State<CharityWidget>
    with AutomaticKeepAliveClientMixin {
  bool _loadingVisible = false;
  Future<Map<String, Charity>> cases;

  @override
  void initState() {
    super.initState();
    cases = widget.charityService.getCases();
  }

  Widget build(BuildContext context) {
    super.build(context);
    final casesBuilder = FutureBuilder<Map<String, Charity>>(
      future: cases,
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );
        if (loading != null) {
          return loading;
        }

        final caseWidgets = snapshot.data.entries
            .map(
              (entry) => CaseWidget(
                key: Key(entry.key),
                charityCase: entry.value,
                charityService: widget.charityService,
              ),
            )
            .toList();
        return GridView(
          key: Key('casesList'),
          children: caseWidgets,
          shrinkWrap: true,
          addAutomaticKeepAlives: true,
          primary: true,
          gridDelegate: getGridDelegate(
            context,
            rowDisplacement: -1,
            aspectRatioFactor: 1.1,
            maxPerRow: 2,
          ),
        );
      },
    );

    return LoadingScreen(
      child: casesBuilder,
      inAsyncCall: _loadingVisible,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
