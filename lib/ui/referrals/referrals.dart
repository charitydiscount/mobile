import 'package:charity_discount/models/referral.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:charity_discount/util/tools.dart';

class ReferralsScreen extends StatelessWidget {
  final CharityService charityService;

  ReferralsScreen({Key key, @required this.charityService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('referrals'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 12.0,
              ),
              child: ReferralLink(charityService: charityService),
            ),
            Referrals(charityService: charityService),
          ],
        ),
      ),
    );
  }
}

class ReferralLink extends StatelessWidget {
  final CharityService charityService;

  const ReferralLink({Key key, @required this.charityService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: charityService.getReferralLink(),
      builder: (context, snapshot) {
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );

        if (loading != null) {
          return loading;
        }

        String referralLink = snapshot.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('referralCall')),
              subtitle: Text(tr('referralDetails')),
            ),
            TextFormField(
              readOnly: true,
              initialValue: referralLink,
              maxLines: 2,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 16, color: Colors.green),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(referralLink);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Referrals extends StatelessWidget {
  final CharityService charityService;

  const Referrals({Key key, @required this.charityService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Referral>>(
      initialData: [],
      future: charityService.getReferrals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data.isEmpty) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                '${tr('referrals')} (${snapshot.data.length})',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.left,
              ),
            ),
            ListView.separated(
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemBuilder: (context, index) {
                  final referral = snapshot.data[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 60.0,
                      child: UserAvatar(photoUrl: referral.photoUrl),
                    ),
                    title: Text(referral.name),
                    subtitle: Text(
                      formatDateTime(referral.createdAt),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${addUpCommissionsForStatus(referral, 'paid').toStringAsFixed(2)} RON',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.green),
                        ),
                        Text(
                          '${addUpCommissionsForStatus(referral, 'pending').toStringAsFixed(2)} RON',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.yellowAccent.shade700),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        );
      },
    );
  }

  double addUpCommissionsForStatus(Referral referral, String status) {
    if (referral.commissions == null || referral.commissions.isEmpty) {
      return 0;
    }

    final commissionsForStatus =
        referral.commissions.where((element) => element.status == status);
    if (commissionsForStatus.isNotEmpty) {
      return commissionsForStatus
          .map((commission) => commission.amount)
          .reduce((value, element) => value += element);
    } else {
      return 0;
    }
  }
}
