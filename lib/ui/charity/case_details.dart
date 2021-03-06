import 'dart:io';
import 'package:charity_discount/models/charity.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/ui/tutorial/access_explanation.dart';
import 'package:charity_discount/ui/wallet/operations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CaseDetails extends StatelessWidget {
  final Charity charity;

  CaseDetails({Key key, @required this.charity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leadImage = charity.images.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Hero(
                    tag: 'case-${charity.id}',
                    child: CachedNetworkImage(
                      imageUrl: charity.images.first.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
          )
        : Container();
    final images = charity.images
        .skip(1)
        .map(
          (image) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: image.url,
                    fit: BoxFit.cover,
                    errorWidget:
                        (BuildContext context, String url, Object error) {
                      return Container();
                    },
                  ),
                )
              ],
            ),
          ),
        )
        .toList();

    final description = Padding(
      padding: EdgeInsets.only(top: 16, bottom: 16, right: 8, left: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              charity.description,
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(charity.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!locator<AuthService>().isActualUser()) {
            showSignInDialog(context);
            return;
          }
          if (Platform.isIOS) {
            locator<AffiliateService>().launchWebApp(
              'wallet',
              'case',
              charity.id,
            );
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return DonateDialog(charityCase: charity);
              },
            ).then((txRef) {
              if (txRef != null) {
                showTxResult(txRef, context);
              }
            });
          }
        },
        child: const Icon(Icons.favorite),
      ),
      body: ListView(
        children: List.from([leadImage, description])..addAll(images),
      ),
    );
  }
}
