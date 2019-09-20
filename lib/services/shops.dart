import 'dart:async';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/models/rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charity_discount/models/favorite_shops.dart';

class ShopsService {
  BehaviorSubject<FavoriteShops> get favoritePrograms => throw Error();

  Future<List<models.Program>> getAllPrograms() async {
    throw Error();
  }

  Future<void> setFavoriteShop(
    String userId,
    models.Program program,
    bool favorite,
  ) async {
    throw Error();
  }

  Future<List<Rating>> getProgramRating(String programId) async {
    throw Error();
  }
}

class FirebaseShopsService implements ShopsService {
  final _db = Firestore.instance;
  final String userId;
  Observable<DocumentSnapshot> _favRef;
  StreamSubscription _favListener;
  BehaviorSubject<FavoriteShops> _favoritePrograms =
      BehaviorSubject<FavoriteShops>();

  BehaviorSubject<FavoriteShops> get favoritePrograms => _favoritePrograms;

  FirebaseShopsService(this.userId) {
    _favRef = Observable(
        _db.collection('favoriteShops').document(userId).snapshots());
    _favListener = _favRef.listen((snap) {
      if (snap.exists) {
        _favoritePrograms.add(FavoriteShops.fromJson(snap.data));
      } else {
        _favoritePrograms.add(FavoriteShops(userId: userId, programs: []));
      }
    });
  }

  @override
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

  Future<void> closeFavoritesSink() async {
    await _favListener.cancel();
    await _favoritePrograms.close();
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

  @override
  Future<List<models.Program>> getAllPrograms() async {
    QuerySnapshot snapshot =
        await _db.collection('shops').orderBy('createdAt').getDocuments();

    List<models.Program> programs = [];
    snapshot.documents.forEach((doc) {
      programs.addAll(
        models.fromFirestoreBatch(doc),
      );
    });
    programs.sort((p1, p2) =>
        p1.name.trim().toLowerCase().compareTo(p2.name.trim().toLowerCase()));

    return programs;
  }

  @override
  Future<List<Rating>> getProgramRating(String programId) {
    return Future.delayed(
      Duration(milliseconds: 500),
      () => [
        Rating(
          reviewer: Reviewer(
            name: 'Test',
            photoUrl:
                'https://lh3.googleusercontent.com/-ObKekHwOJsI/AAAAAAAAAAI/AAAAAAAABm8/JgnGjSb-M_M/s96-c/photo.jpg',
            userId: '123',
          ),
          rating: 3.5,
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
          createdAt: DateTime.now(),
        ),
        Rating(
          reviewer: Reviewer(
            name: 'Test 2',
            photoUrl:
                'https://lh3.googleusercontent.com/-ObKekHwOJsI/AAAAAAAAAAI/AAAAAAAABm8/JgnGjSb-M_M/s96-c/photo.jpg',
            userId: '123',
          ),
          rating: 4.2,
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
          createdAt: DateTime.now(),
        ),
      ],
    );
  }
}
