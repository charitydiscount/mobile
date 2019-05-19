import 'package:charity_discount/models/meta.dart';
import 'package:charity_discount/models/program.dart' as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charity_discount/models/favorite_shops.dart';

class ShopsService {
  final _db = Firestore.instance;
  final _userId;
  Observable<DocumentSnapshot> _favRef;
  BehaviorSubject<FavoriteShops> _favoritePrograms =
      BehaviorSubject<FavoriteShops>();
  DocumentSnapshot _lastProgramsDoc;

  Observable<FavoriteShops> get favoritePrograms => _favoritePrograms.stream;

  ShopsService(this._userId) {
    _favRef = Observable(
            _db.collection('favoritePrograms').document(_userId).snapshots())
        .asBroadcastStream();
    _favRef.listen((snap) {
      if (snap.exists) {
        _favoritePrograms.add(FavoriteShops.fromJson(snap.data));
      } else {
        _favoritePrograms.add(FavoriteShops(userId: _userId, programs: []));
      }
    });
  }

  Future<List<models.Program>> getPrograms(
      {bool startAfterPrevious = false}) async {
    QuerySnapshot query;
    if (startAfterPrevious == true && _lastProgramsDoc != null) {
      query = await _db
          .collection('shops')
          .orderBy('createdAt')
          .startAfter([_lastProgramsDoc.data])
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

  Future<ProgramMeta> getProgramsMeta() async {
    var programsMeta = await _db.collection('meta').document('programs').get();
    if (programsMeta == null) {
      return ProgramMeta(count: 0, categories: []);
    }

    return ProgramMeta.fromJson(programsMeta.data);
  }

  Future<FavoriteShop> getFavoriteShops(String userId) async {
    return _db.collection('favoriteShops').document(userId).get().then((doc) {
      if (!doc.exists) {
        // User has no favorite shops
        return FavoriteShop(userId: userId, shopIds: List());
      }
      return FavoriteShop(
          userId: userId, shopIds: List<String>.from(doc.data['shopIds']));
    });
  }

  Future<void> setFavoriteShop(
      String userId, String shopId, bool favorite) async {
    DocumentReference ref = _db.collection('favoriteShops').document(userId);

    if (favorite) {
      return ref.updateData({
        'shopIds': FieldValue.arrayUnion([shopId])
      }).catchError((e) => _handleFavDocNotExistent(e, userId, shopId));
    } else {
      return ref.updateData({
        'shopIds': FieldValue.arrayRemove([shopId])
      }).catchError((e) => print(e));
    }
  }

  Observable<List<models.Program>> getProgramsFull() {
    var programs = getPrograms(startAfterPrevious: true);

    return Observable.combineLatest2(Observable.fromFuture(programs),
        getShopsService(_userId).favoritePrograms,
        (List<models.Program> programs, FavoriteShops favorites) {
      programs.forEach((p) {
        if (favorites.programs.firstWhere((f) => f.uniqueCode == p.uniqueCode,
                orElse: () => null) !=
            null) {
          p.favorited = true;
        } else {
          p.favorited = false;
        }
      });
      return programs;
    });
  }

  void closeFavoritesSink() {
    _favoritePrograms.close();
  }

  void refreshCache() {
    _lastProgramsDoc = null;
  }

  void _handleFavDocNotExistent(dynamic e, String userId, String shopId) {
    if (!(e is PlatformException)) {
      return;
    }

    DocumentReference ref = _db.collection('favoriteShops').document(userId);
    ref.setData({
      'shopIds': [shopId]
    }, merge: true);
  }
}

ShopsService _shopsService;

ShopsService getShopsService(userId) {
  if (_shopsService == null) {
    _shopsService = ShopsService(userId);
  }

  return _shopsService;
}
