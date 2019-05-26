import 'package:charity_discount/models/points.dart';
import 'package:charity_discount/ui/widgets/about_points.dart';
import 'package:charity_discount/ui/widgets/history_points.dart';
import 'package:flutter/material.dart';

class PointsScreen extends StatelessWidget {
  final Points points;

  PointsScreen({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
              title: Text(
                'Charity Points',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              iconTheme: IconThemeData(
                color: Theme.of(context).textTheme.body2.color,
              ),
              bottom: TabBar(
                isScrollable: false,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).textTheme.body2.color,
                tabs: choices.map((Choice choice) {
                  return Tab(
                    text: choice.title,
                    icon: Icon(choice.icon),
                  );
                }).toList(),
              )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.local_mall),
          ),
          body: TabBarView(
            children: choices.map((Choice choice) => choice.widget).toList(),
          ),
        ));
  }
}

class Choice {
  final String title;
  final IconData icon;
  final Widget widget;

  const Choice({this.title, this.icon, this.widget});
}

const List<Choice> choices = const <Choice>[
  const Choice(
      title: 'Despre Puncte',
      icon: Icons.favorite,
      widget: AboutPointsWidget(points: const Points(acceptedAmount: 420))),
  const Choice(
      title: 'Tranzactii', icon: Icons.history, widget: HistoryPointsWidget()),
];
