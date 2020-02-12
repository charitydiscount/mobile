import 'package:charity_discount/models/program.dart';
import 'package:charity_discount/models/rating.dart';
import 'package:charity_discount/services/shops.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateScreen extends StatefulWidget {
  final Program program;
  final ShopsService shopsService;
  final Review existingReview;

  RateScreen({
    Key key,
    @required this.program,
    @required this.shopsService,
    this.existingReview,
  }) : super(key: key);

  _RateScreenState createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _rating = 0;
  TextEditingController _descriptionController = TextEditingController();
  bool _validDescription = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview.rating;
      _descriptionController.text = widget.existingReview.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    Function tr = AppLocalizations.of(context).tr;
    Widget headline = Text(
      tr(
        'review.addHeadline',
        args: [widget.program.name],
      ),
      style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 20),
      textAlign: TextAlign.center,
    );

    String _ratingHeadline = '';
    switch (_rating) {
      case 1:
        _ratingHeadline = tr('review.notRecommended');
        break;
      case 2:
        _ratingHeadline = tr('review.disappointing');
        break;
      case 3:
        _ratingHeadline = tr('review.decent');
        break;
      case 4:
        _ratingHeadline = tr('review.satisfied');
        break;
      case 5:
        _ratingHeadline = tr('review.excellent');
        break;
      default:
        _ratingHeadline = '';
    }

    Widget stars = Padding(
      padding: EdgeInsets.only(top: 24),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              _ratingHeadline,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            RatingBar(
              allowHalfRating: false,
              initialRating: _rating.toDouble(),
              itemCount: 5,
              itemSize: 45,
              direction: Axis.horizontal,
              itemPadding: EdgeInsets.all(4),
              itemBuilder: (context, index) {
                return Icon(
                  Icons.star,
                  color: Colors.green,
                );
              },
              unratedColor: Colors.grey.shade300,
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating.toInt();
                });
              },
            ),
          ],
        ),
      ),
    );

    Widget description = TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        labelStyle: TextStyle(
          color: Colors.grey,
        ),
        labelText: AppLocalizations.of(context).tr('review.opinion'),
      ),
      autovalidate: true,
      minLines: 1,
      maxLines: 20,
      validator: (text) {
        if (text.length > 2000) {
          _validDescription = false;
          return tr('review.descriptionTooLong', args: [2000.toString()]);
        }

        _validDescription = true;
        return null;
      },
    );

    String titleKey =
        widget.existingReview != null ? 'review.edit' : 'review.add';
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(titleKey)),
        automaticallyImplyLeading: false,
        leading: CloseButton(),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text(tr('review.publish').toUpperCase()),
            onPressed: _validReview
                ? () {
                    AppModel state = AppModel.of(context);
                    Review review = Review(
                      reviewer: Reviewer.fromUser(state.user),
                      rating: _rating,
                      description: _descriptionController.text,
                    );
                    widget.shopsService
                        .saveReview(widget.program, review)
                        .then((_) {
                      Navigator.of(context).pop(true);
                    });
                  }
                : null,
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: <Widget>[
          headline,
          stars,
          description,
        ],
      ),
    );
  }

  bool get _validReview => _rating > 0 && _validDescription;
}
