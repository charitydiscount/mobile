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
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.blur_circular)),
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.blur_circular)),
    ];
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Timeline(children: items, position: TimelinePosition.Left));
  }
}
