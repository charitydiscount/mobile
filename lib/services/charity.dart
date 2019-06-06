import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charity_discount/models/charity.dart';

class CharityService {
  final Firestore _db = Firestore.instance;

  Observable<Map<String, Charity>> cases;

  CharityService() {
    cases = Observable(_db
        .collection('cases')
        .getDocuments()
        .asStream()
        .map((qS) => qS.documents.asMap())
        .map((snaps) => snaps.map((index, snap) => MapEntry<String, Charity>(
            snap.documentID, Charity.fromJson(snap.data)))));
  }

  Future<Map<String, Charity>> getCases() async {
    QuerySnapshot qS = await _db.collection('cases').getDocuments();
    Map<String, Charity> cases = Map.fromIterable(qS.documents,
        key: (snap) => snap.documentID,
        value: (snap) => Charity.fromJson(snap.data));
    return Future<Map<String, Charity>>.value(cases);
  }
}

CharityService charityService = CharityService();
