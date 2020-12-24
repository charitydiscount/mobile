import 'package:charity_discount/models/leaderboard.dart';
import 'package:charity_discount/services/leadeboard.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/leaderboard/leaderboard_entry.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({
    Key key,
  }) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  AsyncMemoizer _topMemoizer = AsyncMemoizer<List<LeaderboardEntry>>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _topMemoizer.runOnce(
        () => locator<LeaderboardService>().getLeaderboard(),
      ),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );

        if (loading != null) {
          return SliverToBoxAdapter(child: loading);
        }

        final leadeboard = snapshot.data;
        double highestPoints =
            leadeboard.isNotEmpty ? leadeboard.first.points : 0;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return LeaderboardRow(
                entry: leadeboard[index],
                place: index + 1,
                highestPoints: highestPoints,
              );
            },
            childCount: leadeboard.length,
          ),
        );
      },
    );
  }
}
