import 'dart:async';
import 'dart:io';
import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class MetaService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  BehaviorSubject<ProgramMeta> _metaStream = BehaviorSubject();
  StreamSubscription _programsMetaListener;

  Future<TwoPerformantMeta> getTwoPerformantMeta() async {
    var twoPMeta = await _db.collection('meta').doc('2performant').get();
    return TwoPerformantMeta.fromJson(twoPMeta.data());
  }

  Future<ProgramMeta> getProgramsMeta() async {
    var programsMeta = await _db.collection('meta').doc('programs').get();
    if (programsMeta == null) {
      return ProgramMeta(count: 0, categories: []);
    }

    return ProgramMeta.fromJson(programsMeta.data());
  }

  Stream<ProgramMeta> get programsMetaStream {
    if (_programsMetaListener == null) {
      _programsMetaListener = _db
          .collection('meta')
          .doc('programs')
          .snapshots()
          .asyncMap((snap) => ProgramMeta.fromJson(snap.data()))
          .listen((meta) => _metaStream.add(meta));
    }
    return _metaStream;
  }

  Future<void> addFcmToken(String token) => _db
          .collection(FirestoreCollection.users)
          .doc(_auth.currentUser.uid)
          .collection('tokens')
          .doc(token)
          .set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });

  Future<void> removeFcmToken(String token) => _auth.currentUser != null
      ? _db
          .collection(FirestoreCollection.users)
          .doc(_auth.currentUser.uid)
          .collection('tokens')
          .doc(token)
          .delete()
      : null;

  Future<void> setNotifications(
    String deviceToken,
    bool notificationsEnabled,
  ) =>
      _db
          .collection(FirestoreCollection.users)
          .doc(_auth.currentUser.uid)
          .collection('tokens')
          .doc(deviceToken)
          .set(
        {
          'notifications': notificationsEnabled,
        },
        SetOptions(merge: true),
      );

  Future<void> setNotificationsForPromotions(
    String deviceToken,
    bool notificationsEnabled,
  ) {
    return notificationsEnabled
        ? FirebaseMessaging.instance.subscribeToTopic('campaigns')
        : FirebaseMessaging.instance.unsubscribeFromTopic('campaigns');
    // return _db.collection('notifications').doc('promotions').set(
    //   {
    //     _auth.currentUser.uid: notificationsEnabled
    //         ? FieldValue.arrayUnion([deviceToken])
    //         : FieldValue.arrayRemove([deviceToken]),
    //   },
    //   SetOptions(merge: true),
    // );
  }

  Future<void> setEmailNotifications(bool disabled) =>
      _db.collection(FirestoreCollection.users).doc(_auth.currentUser.uid).set(
        {
          'disableMailNotification': disabled,
        },
        SetOptions(merge: true),
      );

  Stream<bool> get subscribedToNewsletter => _db
      .collection(FirestoreCollection.users)
      .doc(_auth.currentUser.uid)
      .snapshots()
      .map((event) =>
          event.data().putIfAbsent('disableMailNotification', () => false));

  Future<void> closeListeners() async {
    if (_programsMetaListener != null) {
      await _programsMetaListener.cancel();
      await _metaStream.close();
    }
  }
}
