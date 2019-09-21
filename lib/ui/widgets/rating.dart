import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class RatingWidget extends StatelessWidget {
  final Review rating;

  const RatingWidget({Key key, this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget userAvatar = ClipOval(
      child: SizedBox(
        height: 50,
        width: 50,
        child: rating.reviewer.photoUrl != null
            ? CachedNetworkImage(
                imageUrl: rating.reviewer.photoUrl,
                fit: BoxFit.scaleDown,
              )
            : Image.asset(
                'assets/images/default.png',
                fit: BoxFit.scaleDown,
              ),
      ),
    );
    Widget userName = Text(
      rating.reviewer.name,
      style: Theme.of(context).textTheme.title,
    );
    Widget reviewDate = Text(
      DateFormat.yMd('ro_RO').format(rating.createdAt),
      style: Theme.of(context).textTheme.caption,
    );
    Widget stars = RatingBar(
      initialRating: rating.rating.toDouble(),
      direction: Axis.horizontal,
      allowHalfRating: true,
      glow: false,
      ignoreGestures: true,
      itemCount: 5,
      itemSize: 20,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.green,
      ),
      onRatingUpdate: (rating) {},
    );

    return Container(
      height: 320,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      userAvatar,
                      Column(
                        children: <Widget>[
                          userName,
                          reviewDate,
                          stars,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(rating.description),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgramRating extends StatelessWidget {
  final OverallRating rating;
  final double iconSize;

  const ProgramRating({
    Key key,
    @required this.rating,
    @required this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return rating.count > 0
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RatingBar(
                initialRating: rating.overall,
                direction: Axis.horizontal,
                allowHalfRating: true,
                glow: false,
                ignoreGestures: true,
                itemCount: 5,
                itemSize: iconSize,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.green,
                ),
                onRatingUpdate: (rating) {},
              ),
              Text(
                ' (${rating.count})',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          )
        : Container();
  }
}
