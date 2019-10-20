import 'package:charity_discount/models/news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user.dart';

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

  Future<void> saveAccount(
    String userId,
    SavedAccount savedAccount,
  ) async {
    throw Error();
  }

  Future<void> removeAccount(
    String userId,
    SavedAccount savedAccount,
  ) async {
    throw Error();
  }

  Future<List<News>> getNews() {
    throw Error();
  }

  Future<void> sendOtpCode(String userId) {
    throw Error();
  }

  Future<bool> checkOtpCode(String userId, int code) {
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
      'status': 'PENDING',
    });
  }

  @override
  Future<void> saveAccount(
    String userId,
    SavedAccount savedAccount,
  ) async {
    DocumentReference userRef = _db.collection('users').document(userId);
    return userRef.updateData({
      'accounts': FieldValue.arrayUnion([savedAccount.toJson()])
    }).catchError((e) => _handleFirstAccount(e, userId, savedAccount));
  }

  Future<void> _handleFirstAccount(
    dynamic e,
    String userId,
    SavedAccount savedAccount,
  ) async {
    if (!(e is PlatformException)) {
      return null;
    }

    DocumentReference ref = _db.collection('users').document(userId);
    return ref.setData(
      {
        'accounts': [savedAccount.toJson()]
      },
      merge: true,
    );
  }

  @override
  Future<void> removeAccount(String userId, SavedAccount savedAccount) {
    DocumentReference userRef = _db.collection('users').document(userId);
    return userRef.updateData({
      'accounts': FieldValue.arrayRemove([savedAccount.toJson()])
    }).catchError((e) {});
  }

  @override
  Future<List<News>> getNews() {
    List<News> mockedNews = [
      News(
        id: '1',
        createdAt: DateTime.now(),
        title: 'Charity Discount Launched',
        imageUrl: 'https://charitydiscount.ro/img/charity_discount.png',
        body:
            'It is a pleasure to announce the launch of <strong>Charity Discount</strong>',
      ),
      News(
        id: '1',
        createdAt: DateTime.now(),
        title: 'New Charity Case Supported',
        imageUrl: 'http://teachforromania.org/wp-content/uploads/105.jpg',
        body:
            '<p><i>Knowledge is power. Information is liberating. Education is the premise of progress, in every society, in every family.</i></p>',
      ),
    ];
    return Future.value(mockedNews);
  }

  @override
  Future<void> sendOtpCode(String userId) {
    return _db.collection('otp-requests').document(userId).setData({
      'userId': userId,
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> checkOtpCode(String userId, int code) async {
    final otpRef = _db.collection('otps').document(userId);

    final otp = await otpRef.get();
    final codeMatches = otp.data['code'] == code;

    if (codeMatches) {
      otpRef.setData({'used': true}, merge: true);
    }

    return codeMatches;
  }
}
