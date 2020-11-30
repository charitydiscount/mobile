import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/user_achievement.dart';
import 'package:charity_discount/util/locale.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/achievement.dart' as model;
import 'package:easy_localization/easy_localization.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Achievement extends StatelessWidget {
  final model.Achievement achievement;
  final UserAchievement userAchievement;

  const Achievement({
    Key key,
    @required this.achievement,
    this.userAchievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _AchievementBadge(
        badgeUrl: achievement.badgeUrl,
        achieved: userAchievement?.achieved ?? false,
      ),
      title: Text(
        getLocalizedText(
          context.locale,
          achievement.name,
        ),
      ),
      subtitle: Text(
        getLocalizedText(
          context.locale,
          achievement.description,
        ),
      ),
      isThreeLine: true,
      trailing: _buildTrailing(),
    );
  }

  Widget _buildTrailing() => Stack(
        children: [
          Container(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: achievement.conditions.map(
                (c) {
                  switch (c.type) {
                    case model.AchievementConditionType.COUNT:
                      return _AchievementTargetCount(
                        condition: c,
                        currentCount: userAchievement?.currentCount ?? 0,
                      );
                    case model.AchievementConditionType.UNTIL_DATE:
                    case model.AchievementConditionType.EXACT_DATE:
                      return _AchievementTargetDate(condition: c);
                    default:
                  }
                },
              ).toList(),
            ),
          ),
          userAchievement?.achieved ?? false
              ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                )
              : Container(width: 0, height: 0)
        ],
      );
}

class _AchievementBadge extends StatelessWidget {
  final String badgeUrl;
  final bool achieved;

  const _AchievementBadge({
    Key key,
    @required this.badgeUrl,
    this.achieved = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      child: CachedNetworkImage(
        imageUrl: badgeUrl ?? '',
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: achieved
                  ? null
                  : ColorFilter.matrix(
                      <double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ],
                    ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 60,
          width: 60,
          child: Icon(
            Icons.error,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _AchievementTargetCount extends StatelessWidget {
  final model.AchievementCondition condition;
  final int currentCount;

  const _AchievementTargetCount({
    Key key,
    @required this.condition,
    this.currentCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => CircularPercentIndicator(
        radius: 50,
        lineWidth: 5.0,
        percent: currentCount / condition.target,
        progressColor: Theme.of(context).accentColor,
        center: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            '$currentCount',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      );
}

class _AchievementTargetDate extends StatelessWidget {
  final model.AchievementCondition condition;

  const _AchievementTargetDate({Key key, this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${formatDate(condition.target)}',
      style: Theme.of(context).textTheme.caption,
    );
  }
}
