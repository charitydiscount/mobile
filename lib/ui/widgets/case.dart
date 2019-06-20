import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/ui/screens/case_details.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:charity_discount/models/charity.dart';

class CaseWidget extends StatelessWidget {
  final Charity charityCase;

  CaseWidget({Key key, this.charityCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = CachedNetworkImage(
      imageUrl: charityCase.images[0].url,
      width: 120,
      height: 120,
      fit: BoxFit.fill,
    );
    final donateButton = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: () {},
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
            builder: (BuildContext context) =>
                CaseDetails(charity: charityCase),
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
              leading: logo,
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
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  donateButton,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
