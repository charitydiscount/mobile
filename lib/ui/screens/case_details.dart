import 'package:charity_discount/models/charity.dart';
import 'package:flutter/material.dart';

class CaseDetails extends StatelessWidget {
  final Charity charity;

  const CaseDetails({Key key, this.charity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = charity.images
        .map((image) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(children: <Widget>[
              Expanded(child: Image.network(image.url, fit: BoxFit.cover))
            ])))
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
        ));

    return Scaffold(
      appBar: AppBar(title: Text(charity.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.favorite),
      ),
      body: ListView(
        children: List.from([description])..addAll(images),
      ),
    );
  }
}
