import 'package:charity_discount/models/achievement.dart' as model;
import 'package:charity_discount/models/user_achievement.dart';
import 'package:charity_discount/services/achievements.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/achievements/achievement.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AchivementsScreen extends StatelessWidget {
  const AchivementsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('achievements'),
        ),
      ),
      body: FutureBuilder<List<model.Achievement>>(
        future: locator<AchievementsService>().getAchievements(),
        builder: (context, snapshot) {
          final loading = buildConnectionLoading(
            context: context,
            snapshot: snapshot,
          );

          if (loading != null) {
            return loading;
          }

          final achievements = snapshot.data;

          return StreamBuilder<Map<String, UserAchievement>>(
            stream: locator<AchievementsService>().getUserAchievements(),
            builder: (context, userAchievementsSnap) => ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Achievement(
                  achievement: achievement,
                  userAchievement: userAchievementsSnap.hasData
                      ? userAchievementsSnap.data[achievement.id]
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
