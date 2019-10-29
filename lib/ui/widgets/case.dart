import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/ui/screens/case_details.dart';
import 'package:charity_discount/ui/widgets/operations.dart';
import 'package:charity_discount/util/url.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';

class CaseWidget extends StatelessWidget {
  final Charity charityCase;
  final CharityService charityService;

  CaseWidget({
    Key key,
    @required this.charityCase,
    @required this.charityService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = CachedNetworkImage(
      imageUrl: charityCase.images[0].url,
      width: 100,
      fit: BoxFit.fitWidth,
    );
    final websiteButton = charityCase.site != null
        ? Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: FlatButton(
              onPressed: () {
                launchURL(charityCase.site);
              },
              child: Text('Website'),
            ))
        : Container();
    final donateButton = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return DonateDialog(
              charityCase: charityCase,
              charityService: charityService,
            );
          },
        ).then((txRef) => showTxResult(txRef, context));
      },
      padding: EdgeInsets.all(12),
      color: Theme.of(context).primaryColor,
      child: Text(
        AppLocalizations.of(context).tr('contribute'),
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
              charityService: charityService,
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
            ListTile(
              leading: Hero(
                tag: 'case-${charityCase.id}',
                child: logo,
              ),
              title: Center(
                child: Text(
                  charityCase.title,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              subtitle: Center(
                child: Text(''),
              ),
            ),
            ButtonBar(
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
