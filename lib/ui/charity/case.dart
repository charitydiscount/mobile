import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/charity/case_details.dart';
import 'package:charity_discount/ui/tutorial/access_explanation.dart';
import 'package:charity_discount/ui/wallet/operations.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';

class CaseWidget extends StatelessWidget {
  final Charity charityCase;

  CaseWidget({Key key, @required this.charityCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'case-${charityCase.id}',
      child: CachedNetworkImage(
        imageUrl: charityCase.images[0].url,
        fit: BoxFit.fitWidth,
      ),
    );
    final websiteButton = charityCase.site != null
        ? Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () {
                launchURL(charityCase.site);
              },
              child: Text('Website'),
            ),
          )
        : Container();
    final donateButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        primary: Theme.of(context).primaryColor,
      ),
      onPressed: () {
        if (!locator<AuthService>().isActualUser()) {
          showSignInDialog(context);
          return;
        }
        if (Platform.isIOS) {
          locator<AffiliateService>().launchWebApp(
            'wallet',
            'case',
            charityCase.id,
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return DonateDialog(charityCase: charityCase);
            },
          ).then((txRef) {
            if (txRef != null) {
              showTxResult(txRef, context);
            }
          });
        }
      },
      child: Text(
        tr('contribute'),
        style: TextStyle(color: Colors.white),
      ),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CaseDetails(
              charity: charityCase,
            ),
            settings: RouteSettings(name: 'CaseDetails'),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: logo),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  charityCase.title,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                websiteButton,
                donateButton,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
