import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/rating.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final Review rating;

  const RatingWidget({Key key, this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget userAvatar = ClipOval(
      child: SizedBox(
        height: 50,
        width: 50,
        child: UserAvatar(photoUrl: rating.reviewer?.photoUrl),
      ),
    );
    Widget userName = Text(
      rating.reviewer?.name ?? '-',
      style: Theme.of(context).textTheme.subtitle1,
    );
    Widget reviewDate = Text(
      formatDate(rating.createdAt),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: ListTile(
          dense: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              rating.description ?? '',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
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
    return rating != null && rating.count > 0
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RatingBarIndicator(
                direction: Axis.horizontal,
                rating: rating.overall,
                itemCount: 5,
                itemSize: iconSize,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.green,
                ),
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
