import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charity_discount/models/favorite_shop.dart';

class FirestoreService {
  final _db = Firestore.instance;

  Future<List<FavoriteShop>> getFavoriteShops(String userId) async {
    return _db
        .collection('favoriteShops')
        .where('userId', isEqualTo: userId)
        .getDocuments()
        .then((documents) => documents.documents
            .map((doc) => FavoriteShop.fromJson(doc.data))
            .toList());
  }
}

FirestoreService firestoreService = FirestoreService();
