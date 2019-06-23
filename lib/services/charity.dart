import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/models/charity.dart';

class CharityService {
  final Firestore _db = Firestore.instance;

  Future<Map<String, Charity>> getCases() async {
    QuerySnapshot qS = await _db.collection('cases').getDocuments();
    Map<String, Charity> cases = Map.fromIterable(qS.documents,
        key: (snap) => snap.documentID,
        value: (snap) => Charity.fromJson(snap.data));
    return Future<Map<String, Charity>>.value(cases);
  }

  Future<Wallet> getPoints(String userId) async {
    final points = await _db.collection('points').document(userId).get();
    return Wallet.fromJson(points.data);
  }
}

CharityService charityService = CharityService();
