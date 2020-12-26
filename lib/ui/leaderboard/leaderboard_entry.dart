import 'package:charity_discount/models/leaderboard.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:charity_discount/util/amounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final double highestPoints;
  final int place;

  const LeaderboardRow({
    Key key,
    @required this.entry,
    @required this.highestPoints,
    @required this.place,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: UserAvatar(photoUrl: entry.photoUrl),
              radius: 20,
              backgroundColor: Colors.transparent,
            ),
            title: Text(entry.name ?? '-'),
            subtitle: LinearPercentIndicator(
              width: ScreenUtil().setWidth(250),
              percent: entry.points / highestPoints,
              progressColor: theme.accentColor,
              backgroundColor: Colors.grey.shade300,
              trailing: Row(
                children: [
                  Text(AmountHelper.amountToString(entry.points)),
                  Text(
                    ' CharityPoints',
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
            ),
            trailing: Text(
              place.toString(),
              style: theme.textTheme.subtitle1,
            ),
          ),
          if (place < 4)
            Positioned(
              bottom: 8,
              left: 45,
              child: getTrophy(),
            ),
          if (entry.isStaff)
            Positioned(
              bottom: 8,
              left: 8,
              child: Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.cover,
                width: 20,
                height: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget getTrophy() => SvgPicture.asset(
        'assets/icons/trophy.svg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        color: place == 1
            ? Colors.yellow
            : place == 2
                ? Colors.blueGrey.shade200
                : Colors.orange,
      );
}
