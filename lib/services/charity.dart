import 'package:charity_discount/models/commission.dart';
import 'package:charity_discount/models/news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
    Target target,
  ) async {
    throw Error();
  }

  Future<List<SavedAccount>> get userAccounts => throw Error();

  Future<void> saveAccount(SavedAccount savedAccount) {
    throw Error();
  }

  Future<void> removeAccount(SavedAccount savedAccount) {
    throw Error();
  }

  Future<List<News>> getNews() {
    throw Error();
  }

  Future<void> sendOtpCode() {
    throw Error();
  }

  Future<bool> checkOtpCode(int code) {
    throw Error();
  }

  Future<List<Commission>> getUserCommissions() async {
    throw Error();
  }
}

class FirebaseCharityService implements CharityService {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    Target target,
  ) async {
    return _db.collection('requests').add({
      'userId': userId,
      'type': describeEnum(type),
      'amount': amount,
      'currency': currency,
      'target': target.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'PENDING',
    });
  }

  @override
  Future<List<SavedAccount>> get userAccounts =>
      _auth.currentUser().then((user) => _db
          .collection('users')
          .document(user.uid)
          .collection('accounts')
          .getDocuments()
          .then(
            (docs) => docs.documents
                .map((accountSnap) => SavedAccount.fromJson(accountSnap))
                .toList(),
          ));

  @override
  Future<void> saveAccount(SavedAccount savedAccount) =>
      _auth.currentUser().then((user) => _db
          .collection('users')
          .document(user.uid)
          .collection('accounts')
          .document(savedAccount.iban)
          .setData(savedAccount.toJson(), merge: true));

  @override
  Future<void> removeAccount(SavedAccount savedAccount) =>
      _auth.currentUser().then((user) => _db
          .collection('users')
          .document(user.uid)
          .collection('accounts')
          .document(savedAccount.iban)
          .delete());

  @override
  Future<List<News>> getNews() {
    List<News> mockedNews = [
      News(
        id: '1',
        createdAt: DateTime.now(),
        title: 'CharityDiscount Launched',
        imageUrl: 'https://charitydiscount.ro/img/charity_discount.png',
        body:
            'It is a pleasure to announce the launch of <strong>CharityDiscount</strong>',
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
  Future<void> sendOtpCode() => _auth.currentUser().then(
        (user) => _db.collection('otp-requests').document(user.uid).setData({
          'userId': user.uid,
          'requestedAt': FieldValue.serverTimestamp(),
        }),
      );

  @override
  Future<bool> checkOtpCode(int code) => _auth.currentUser().then(
        (user) =>
            _db.collection('otps').document(user.uid).get().then((otpSnap) {
          final codeMatches = otpSnap.data['code'] == code;

          if (codeMatches) {
            otpSnap.reference.setData({'used': true}, merge: true);
          }

          return codeMatches;
        }),
      );

  @override
  Future<List<Commission>> getUserCommissions() => _auth.currentUser().then(
        (user) => _db
            .collection('commissions')
            .document(user.uid)
            .get()
            .then((commissionsSnap) {
          if (!commissionsSnap.exists) {
            return null;
          }

          List commissions = [];
          commissionsSnap.data.forEach((key, value) {
            if (key != 'userId') {
              commissions.add(value);
            }
          });
          return List<Commission>.from(
            commissions
                .map((commissionJson) => Commission.fromJson(commissionJson))
                .toList(),
          );
        }),
      );
}
