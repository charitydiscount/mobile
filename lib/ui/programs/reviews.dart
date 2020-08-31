import 'package:charity_discount/models/rating.dart';
import 'package:charity_discount/ui/programs/rating.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProgramReviewsScreen extends StatelessWidget {
  const ProgramReviewsScreen({
    Key key,
    @required this.reviews,
  }) : super(key: key);

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('review.reviews')),
      ),
      body: ListView(
        children: reviews
            .map(
              (rating) => RatingWidget(rating: rating),
            )
            .toList(),
      ),
    );
  }
}
