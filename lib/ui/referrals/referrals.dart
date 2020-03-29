import 'package:charity_discount/models/referral.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

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
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ReferralLink(charityService: charityService),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Referrals(charityService: charityService),
            ),
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
    return FutureBuilder<ShortDynamicLink>(
      future: charityService.getReferralLink(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print(snapshot.error);
          return Container();
        }

        String referralLink = snapshot.data.shortUrl.toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(tr('referralCall')),
              subtitle: Text(tr('referralDetails')),
            ),
            TextFormField(
              readOnly: true,
              initialValue: referralLink,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 14, color: Colors.green),
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
        final loading = buildConnectionLoading(
          context: context,
          snapshot: snapshot,
        );

        if (loading != null) {
          return loading;
        }

        if (snapshot.data.isEmpty) {
          return Container(width: 0, height: 0);
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
                tr('referrals'),
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
                      child: UserAvatar(
                        photoUrl: referral.photoUrl,
                        // width: 120.0,
                        // height: 120.0,
                      ),
                    ),
                    title: Text(referral.name),
                    trailing: Text(
                      '${addUpCommissions(referral).toStringAsFixed(2)} RON',
                      style: Theme.of(context).textTheme.button,
                    ),
                  );
                }),
          ],
        );
      },
    );
  }

  double addUpCommissions(Referral referral) =>
      referral.commissions
          ?.map((commission) => commission.amount)
          ?.reduce((value, element) => value += element) ??
      0;
}
