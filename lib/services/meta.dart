import 'dart:io';
import 'package:charity_discount/models/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class MetaService {
  final _db = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  Observable<ProgramMeta> _programsMetaListener;

  Future<TwoPerformantMeta> getTwoPerformantMeta() async {
    var twoPMeta = await _db.collection('meta').document('2performant').get();
    return TwoPerformantMeta.fromJson(twoPMeta.data);
  }

  Future<ProgramMeta> getProgramsMeta() async {
    var programsMeta = await _db.collection('meta').document('programs').get();
    if (programsMeta == null) {
      return ProgramMeta(count: 0, categories: []);
    }

    return ProgramMeta.fromJson(programsMeta.data);
  }

  Observable<ProgramMeta> get programsMetaStream {
    if (_programsMetaListener == null) {
      _programsMetaListener = Observable(
        _db
            .collection('meta')
            .document('programs')
            .snapshots()
            .asyncMap((snap) => ProgramMeta.fromJson(snap.data)),
      );
    }
    return _programsMetaListener;
  }

  Future<void> addFcmToken(String token) => _auth.currentUser().then(
        (user) => _db
            .collection('users')
            .document(user.uid)
            .collection('tokens')
            .document(token)
            .setData({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        }),
      );

  Future<void> removeFcmToken(String token) => _auth.currentUser().then(
        (user) => _db
            .collection('users')
            .document(user.uid)
            .collection('tokens')
            .document(token)
            .delete(),
      );

  Future<void> setNotifications(
    String deviceToken,
    bool notificationsEnabled,
  ) =>
      _auth.currentUser().then(
            (user) => _db
                .collection('users')
                .document(user.uid)
                .collection('tokens')
                .document(deviceToken)
                .setData({
              'notifications': notificationsEnabled,
            }, merge: true),
          );
}

MetaService metaService = MetaService();
