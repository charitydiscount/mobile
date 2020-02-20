import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/news.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class NewsScreen extends StatelessWidget {
  final CharityService charityService;

  const NewsScreen({Key key, @required this.charityService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('news'))),
      body: FutureBuilder(
        future: charityService.getNews(),
        builder: (context, snapshot) {
          final loading = buildConnectionLoading(
            context: context,
            snapshot: snapshot,
          );
          if (loading != null) {
            return loading;
          }

          final List<News> newsList = snapshot.data;
          newsList.sort((n1, n2) => n2.createdAt.compareTo(n1.createdAt));

          return ListView.builder(
            primary: true,
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: NewsWidget(
                  news: newsList[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewsWidget extends StatelessWidget {
  final News news;

  const NewsWidget({Key key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double imageHeight = MediaQuery.of(context).size.height / 3.5;
    Widget image = news.imageUrl == null
        ? Container()
        : Container(
            height: imageHeight,
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              maxHeight: imageHeight,
              maxWidth: double.infinity,
              child: Hero(
                tag: 'news-${news.id}',
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => CaseDetails(
        //       charity: charityCase,
        //       charityService: charityService,
        //     ),
        //     settings: RouteSettings(name: 'CaseDetails'),
        //   ),
        // );
      },
      child: Card(
        child: Column(
          children: <Widget>[
            image,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                news.title,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 16.0),
                  child: Text(
                    formatDate(news.createdAt),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Html(data: news.body),
            )
          ],
        ),
      ),
    );
  }
}
