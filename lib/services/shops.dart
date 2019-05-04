import 'package:charity_discount/models/market.dart';
import 'package:charity_discount/services/affiliate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charity_discount/models/favorite_shops.dart';

class ShopsService {
  final _db = Firestore.instance;
  final _userId;
  Observable<DocumentSnapshot> _favRef;
  BehaviorSubject<FavoriteShop> _favorites = BehaviorSubject<FavoriteShop>();

  Observable<FavoriteShop> get favorites => _favorites.stream;

  ShopsService(this._userId) {
    _favRef = Observable(
            _db.collection('favoriteShops').document(_userId).snapshots())
        .asBroadcastStream();
    _favRef.listen((snap) {
      _favorites.add(FavoriteShop(
          userId: _userId,
          shopIds: List<String>.from(
              snap.data != null && snap.data.containsKey('shopIds')
                  ? snap.data['shopIds']
                  : List())));
    });
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

  Observable<Market> getShopsFull(int page, int perPage) {
    var marketFuture = affiliateService.getMarket(
        page: page, perPage: perPage, userId: _userId);

    return Observable.combineLatest2(
        Observable.fromFuture(marketFuture), getShopsService(_userId).favorites,
        (Market market, FavoriteShop favorites) {
      market.programs.forEach((p) {
        if (favorites.shopIds
                .firstWhere((f) => f == p.uniqueCode, orElse: () => null) !=
            null) {
          p.favorited = true;
        } else {
          p.favorited = false;
        }
      });
      return market;
    });
  }

  void closeFavoritesSink() {
    _favorites.close();
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
