import 'dart:io';

import 'package:charity_discount/models/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class MetaService {
  final _db = Firestore.instance;
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

  Future<void> addFcmToken(String userId, String token) {
    final tokenRef = _db
        .collection('users')
        .document(userId)
        .collection('tokens')
        .document(token);

    return tokenRef.setData({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

  Future<void> removeFcmToken(String userId, String token) {
    return _db
        .collection('users')
        .document(userId)
        .collection('tokens')
        .document(token)
        .delete();
  }

  Future<void> setNotifications(
    String userId,
    String deviceToken,
    bool notificationsEnabled,
  ) {
    final tokenRef = _db
        .collection('users')
        .document(userId)
        .collection('tokens')
        .document(deviceToken);

    return tokenRef.setData({
      'notifications': notificationsEnabled,
    }, merge: true);
  }
}

MetaService metaService = MetaService();
