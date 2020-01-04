import 'package:charity_discount/ui/app/util.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';
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
  Future<Map<String, Charity>> cases;

  @override
  void initState() {
    super.initState();
    cases = widget.charityService.getCases();
  }

  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              primary: false,
              pinned: true,
              floating: true,
              forceElevated: true,
              titleSpacing: 0.0,
              title: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.poll,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildCases(),
            _buildHeroes(),
          ],
        ),
      ),
    );
  }

  Widget _buildCases() {
    return FutureBuilder<Map<String, Charity>>(
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
  }

  Widget _buildHeroes() {
    return FutureBuilder<Map<String, Charity>>(
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
  }

  @override
  bool get wantKeepAlive => true;
}
