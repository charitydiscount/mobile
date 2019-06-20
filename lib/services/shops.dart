import 'dart:async';
import 'package:charity_discount/models/program.dart' as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charity_discount/models/favorite_shops.dart';

class ShopsService {
  final _db = Firestore.instance;
  final String _userId;
  Observable<DocumentSnapshot> _favRef;
  StreamSubscription _favListener;
  BehaviorSubject<FavoriteShops> _favoritePrograms =
      BehaviorSubject<FavoriteShops>();
  DocumentSnapshot _lastProgramsDoc;

  BehaviorSubject<FavoriteShops> get favoritePrograms => _favoritePrograms;

  ShopsService(this._userId) {
    _favRef = Observable(
        _db.collection('favoriteShops').document(_userId).snapshots());
    _favListener = _favRef.listen((snap) {
      if (snap.exists) {
        _favoritePrograms.add(FavoriteShops.fromJson(snap.data));
      } else {
        _favoritePrograms.add(FavoriteShops(userId: _userId, programs: []));
      }
    });
  }

  Future<List<models.Program>> _getPrograms(
      {bool startAfterPrevious = false}) async {
    QuerySnapshot query;
    if (startAfterPrevious == true && _lastProgramsDoc != null) {
      query = await _db
          .collection('shops')
          .orderBy('createdAt')
          .startAfter([_lastProgramsDoc.data['createdAt']])
          .limit(1)
          .getDocuments();
    } else {
      query = await _db
          .collection('shops')
          .orderBy('createdAt')
          .limit(1)
          .getDocuments();
    }

    if (query.documents.length == 0) {
      return [];
    }

    _lastProgramsDoc = query.documents.last;

    return models.fromFirestoreBatch(_lastProgramsDoc);
  }

  Future<List<models.Program>> _getProgramsForCategory(
      {bool startAfterPrevious = false, String category}) async {
    QuerySnapshot query;
    if (startAfterPrevious == true && _lastProgramsDoc != null) {
      query = await _db
          .collection('categories')
          .where('category', isEqualTo: category)
          .orderBy('createdAt')
          .startAfter([_lastProgramsDoc.data['createdAt']])
          .limit(1)
          .getDocuments();
    } else {
      query = await _db
          .collection('categories')
          .where('category', isEqualTo: category)
          .orderBy('createdAt')
          .limit(1)
          .getDocuments();
    }

    if (query.documents.length == 0) {
      return [];
    }

    _lastProgramsDoc = query.documents.last;

    return models.fromFirestoreBatch(_lastProgramsDoc);
  }

  Future<void> setFavoriteShop(
      String userId, models.Program program, bool favorite) async {
    DocumentReference ref = _db.collection('favoriteShops').document(userId);

    if (favorite) {
      return ref.updateData({
        'programs': FieldValue.arrayUnion([program.toJson()])
      }).catchError((e) => _handleFavDocNotExistent(e, userId, program));
    } else {
      return ref.updateData({
        'programs': FieldValue.arrayRemove([program.toJson()])
      }).catchError((e) => print(e));
    }
  }

  Observable<List<models.Program>> getPrograms() {
    return Observable.fromFuture(
      _getPrograms(startAfterPrevious: true),
    );
  }

  Observable<List<models.Program>> getProgramsForCategory(String category) {
    return Observable.fromFuture(
      _getProgramsForCategory(startAfterPrevious: true, category: category),
    );
  }

  void closeFavoritesSink() {
    _favListener.cancel();
    _favoritePrograms.close();
  }

  void refreshCache() {
    _lastProgramsDoc = null;
  }

  void _handleFavDocNotExistent(
      dynamic e, String userId, models.Program program) {
    if (!(e is PlatformException)) {
      return;
    }

    DocumentReference ref = _db.collection('favoriteShops').document(userId);
    ref.setData({
      'userId': userId,
      'programs': [program.toJson()]
    }, merge: true);
  }
}

ShopsService _shopsService;

ShopsService getShopsService(String userId) {
  if (_shopsService == null) {
    _shopsService = ShopsService(userId);
  }

  return _shopsService;
}
