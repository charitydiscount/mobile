import 'dart:async';

import 'package:charity_discount/models/commission.dart';
import 'package:charity_discount/models/news.dart';
import 'package:charity_discount/models/referral.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/wallet.dart';
import 'package:charity_discount/models/charity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user.dart';

abstract class CharityService {
  Future<Map<String, Charity>> getCases() async {
    throw Error();
  }

  Observable<Wallet> getWalletStream(String userId) {
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

  Future<void> createReferralRequest(String referralCode) {
    throw Error();
  }

  Future<List<Referral>> getReferrals() async {
    throw Error();
  }

  Future<String> getReferralLink() async {
    throw Error();
  }

  Future<void> closeListeners();
}

class FirebaseCharityService implements CharityService {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _cachedReferralLink;
  BehaviorSubject<Wallet> _walletStream = BehaviorSubject();
  StreamSubscription _pointsListener;

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
  Observable<Wallet> getWalletStream(String userId) {
    if (_pointsListener != null) {
      return _walletStream;
    }

    _pointsListener = _db
        .collection('points')
        .document(userId)
        .snapshots()
        .map(
          (pointsSnapshop) => pointsSnapshop.exists
              ? Wallet.fromJson(pointsSnapshop.data)
              : null,
        )
        .listen((wallet) {
      _walletStream.add(wallet);
    });

    return _walletStream;
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
          var result = List<Commission>.from(
            commissions
                .map((commissionJson) => Commission.fromJson(commissionJson))
                .toList(),
          );
          result.sort((c1, c2) => c2.createdAt.compareTo(c1.createdAt));
          return result;
        }),
      );

  @override
  Future<void> createReferralRequest(String referralCode) =>
      _auth.currentUser().then(
            (user) => _db.collection('referral-requests').add(
              {
                'newUserId': user.uid,
                'referralCode': referralCode,
                'createdAt': FieldValue.serverTimestamp(),
              },
            ),
          );

  @override
  Future<List<Referral>> getReferrals() async {
    final user = await _auth.currentUser();
    final List<Referral> referrals = await _db
        .collection('referrals')
        .where('ownerId', isEqualTo: user.uid)
        .getDocuments()
        .then((referralDocs) => referralDocs.documents
            .map((refDoc) => Referral.fromJson(refDoc.data))
            .toList());

    if (referrals.isNotEmpty) {
      referrals.sort((r1, r2) => r2.createdAt.compareTo(r1.createdAt));
      List<Commission> commissions = await getUserCommissions();
      if (commissions != null) {
        referrals.forEach((referral) {
          List<Commission> referralCommissions = commissions
              .where((element) => element.referralId == referral.userId)
              .toList();
          referralCommissions
              .sort((e1, e2) => e1.createdAt.compareTo(e2.createdAt));
          referral.setCommissions(referralCommissions);
        });
      }
    }

    return referrals;
  }

  @override
  Future<String> getReferralLink() async {
    if (_cachedReferralLink != null) {
      return _cachedReferralLink;
    }

    final user = await _auth.currentUser();
    String prefix = await remoteConfig.getDynamicLinksPrefix();
    String imageUrl = await remoteConfig.getMetaImage();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: prefix,
      link: Uri.parse('https://charitydiscount.ro/referral/${user.uid}'),
      androidParameters: AndroidParameters(
        packageName: 'com.clover.charity_discount',
        minimumVersion: 500,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.clover.CharityDiscount',
        appStoreId: '1492115913',
        minimumVersion: '500',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'referrals',
        medium: 'social',
        source: 'mobile',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: tr('referralMeta.title'),
        description: tr('referralMeta.description'),
        imageUrl: Uri.parse(imageUrl),
      ),
    );

    final shortUrl = await parameters.buildShortLink();

    if (shortUrl.warnings.isNotEmpty) {
      print(shortUrl.warnings);
    }

    String link = shortUrl.shortUrl.toString();

    _cachedReferralLink = link;

    return link;
  }

  @override
  Future<void> closeListeners() async {
    if (_pointsListener != null) {
      await _pointsListener.cancel();
      await _walletStream.close();
    }
    return null;
  }
}
