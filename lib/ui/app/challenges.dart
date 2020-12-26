import 'package:charity_discount/ui/achievements/achievements.dart';
import 'package:charity_discount/ui/leaderboard/leadeboard.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        text: tr('leaderboard'),
                        icon: SvgPicture.asset(
                          'assets/icons/trophy.svg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          color: Colors.white,
                        ),
                      ),
                      Tab(
                        text: tr('achievements'),
                        icon: Icon(
                          Icons.double_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      Leaderboard(),
                    ],
                  );
                },
              ),
              Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      AchievementsList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
