import 'package:charity_discount/models/achievement.dart' as model;
import 'package:charity_discount/models/user_achievement.dart';
import 'package:charity_discount/services/achievements.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/achievements/achievement.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class AchievementsList extends StatefulWidget {
  const AchievementsList({
    Key key,
  }) : super(key: key);

  @override
  _AchievementsListState createState() => _AchievementsListState();
}

class _AchievementsListState extends State<AchievementsList> {
  AsyncMemoizer _memoizer = AsyncMemoizer<List<model.Achievement>>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<model.Achievement>>(
      future: _memoizer.runOnce(
        () => locator<AchievementsService>().getAchievements(),
      ),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );

        if (loading != null) {
          return SliverToBoxAdapter(child: loading);
        }

        final achievements = snapshot.data;

        return StreamBuilder<Map<String, UserAchievement>>(
          stream: locator<AchievementsService>().getUserAchievements(),
          builder: (context, userAchievementsSnap) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final achievement = achievements[index];
                  return Achievement(
                    achievement: achievement,
                    userAchievement: userAchievementsSnap.hasData
                        ? userAchievementsSnap.data[achievement.id]
                        : null,
                  );
                },
                childCount: achievements.length,
              ),
            );
          },
        );
      },
    );
  }
}
