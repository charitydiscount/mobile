import 'package:flutter/material.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class HistoryPointsWidget extends StatelessWidget {
  const HistoryPointsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TimelineModel> items = [
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Theme.of(context).primaryColor,
          icon: Icon(Icons.blur_circular, color: Colors.white)),
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Theme.of(context).primaryColor,
          icon: Icon(
            Icons.blur_circular,
            color: Colors.white,
          )),
    ];
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: Timeline(
          children: items,
          position: TimelinePosition.Left,
          lineColor: Theme.of(context).textTheme.body2.color,
        ));
  }
}
