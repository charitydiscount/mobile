import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class CharityService {
  Future<Map<String, Charity>> getCases() async {
    throw Error();
  }

  Observable<Wallet> getPointsListener(String userId) {
    throw Error();
  }

  Future<DocumentReference> createTransaction(
    String userId,
    TxType type,
    double amount,
    String currency,
    String target,
  ) async {
    throw Error();
  }
}

class FirebaseCharityService implements CharityService {
  final Firestore _db = Firestore.instance;

  @override
  Future<Map<String, Charity>> getCases() async {
    QuerySnapshot qS = await _db.collection('cases').getDocuments();
    Map<String, Charity> cases = Map.fromIterable(qS.documents,
        key: (snap) => snap.documentID,
        value: (snap) {
          Charity charityCase = Charity.fromJson(snap.data);
          charityCase.id = snap.documentID;
          return charityCase;
        });
    return Future<Map<String, Charity>>.value(cases);
  }

  @override
  Observable<Wallet> getPointsListener(String userId) {
    return Observable(
      _db.collection('points').document(userId).snapshots().map(
        (pointsSnapshop) {
          return pointsSnapshop.exists
              ? Wallet.fromJson(pointsSnapshop.data)
              : null;
        },
      ),
    );
  }

  @override
  Future<DocumentReference> createTransaction(
    String userId,
    TxType type,
    double amount,
    String currency,
    String target,
  ) async {
    return _db.collection('requests').add({
      'userId': userId,
      'type': describeEnum(type),
      'amount': amount,
      'currency': currency,
      'target': target,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
