import 'dart:async';
import 'package:charity_discount/models/program.dart' as models;
import 'package:charity_discount/models/rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charity_discount/models/favorite_shops.dart';

abstract class ShopsService {
  BehaviorSubject<FavoriteShops> get favoritePrograms;

  Future<List<models.Program>> getAllPrograms();

  Future<void> setFavoriteShop(
    models.Program program,
    bool favorite,
  );

  Future<List<Review>> getProgramRating(String programId);

  Future<void> saveReview(models.Program program, Review review);

  Future<void> closeFavoritesSink();

  void listenToFavShops();
}

class FirebaseShopsService implements ShopsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Stream<DocumentSnapshot> _favRef;
  StreamSubscription _favListener;
  BehaviorSubject<FavoriteShops> _favoritePrograms =
      BehaviorSubject<FavoriteShops>();

  @override
  BehaviorSubject<FavoriteShops> get favoritePrograms => _favoritePrograms;

  @override
  Future<void> setFavoriteShop(models.Program program, bool favorite) async {
    DocumentReference ref =
        _db.collection('favoriteShops').doc(_auth.currentUser.uid);

    if (favorite) {
      return ref.update({
        'programs.${program.uniqueCode}': program.toJson(),
      }).catchError((e) => _handleFavDocNotExistent(
            e,
            program,
          ));
    } else {
      return ref.update({
        'programs.${program.uniqueCode}': FieldValue.delete(),
      }).catchError((e) => print(e));
    }
  }

  Future<void> closeFavoritesSink() async {
    await _favListener.cancel();
    await _favoritePrograms.close();
  }

  void _handleFavDocNotExistent(
    dynamic e,
    models.Program program,
  ) {
    if (!(e is FirebaseException)) {
      throw e;
    }

    DocumentReference ref =
        _db.collection('favoriteShops').doc(_auth.currentUser.uid);
    ref.set({
      'userId': _auth.currentUser.uid,
      'programs': {
        '${program.uniqueCode}': program.toJson(),
      }
    }, SetOptions(merge: true));
  }

  @override
  Future<List<models.Program>> getAllPrograms() async {
    final snap = await _db.collection('programs').doc('all').get();
    if (!snap.exists) {
      return [];
    }

    return snap
        .data()
        .entries
        .where((snapEntry) => snapEntry.key.compareTo('updatedAt') != 0)
        .map((snapEntry) {
          final program = models.Program.fromJson(
            Map<String, dynamic>.from(snapEntry.value),
          );
          return program;
        })
        .where((program) => program.status == 'active')
        .toList();
  }

  @override
  Future<List<Review>> getProgramRating(String programId) async {
    DocumentSnapshot snap =
        await _db.collection('reviews').doc(programId).get();

    if (!snap.exists) {
      return [];
    }

    Map reviews = snap.data()['reviews'];
    return List.from(reviews.entries)
        .map((r) => Review.fromJson(r.value))
        .toList();
  }

  @override
  Future<void> saveReview(models.Program program, Review review) async {
    await _db.collection('reviews').doc(program.uniqueCode).update(
      {
        'shopUniqueCode': program.uniqueCode,
        'reviews.${review.reviewer.userId}': {
          'reviewer': review.reviewer.toJson(),
          'rating': review.rating,
          'description': review.description,
          'createdAt': FieldValue.serverTimestamp(),
        },
      },
    ).catchError((e) => _handleFirstReview(e, program, review));
  }

  Future<void> _handleFirstReview(
    dynamic e,
    models.Program program,
    Review review,
  ) async {
    if (!(e is FirebaseException)) {
      return null;
    }

    DocumentReference ref = _db.collection('reviews').doc(program.uniqueCode);
    return ref.set(
      {
        'shopUniqueCode': program.uniqueCode,
        'reviews': {
          review.reviewer.userId: {
            'reviewer': review.reviewer.toJson(),
            'rating': review.rating,
            'description': review.description,
            'createdAt': FieldValue.serverTimestamp(),
          },
        }
      },
    );
  }

  @override
  void listenToFavShops() {
    _favRef =
        _db.collection('favoriteShops').doc(_auth.currentUser.uid).snapshots();
    _favListener = _favRef.listen((snap) {
      if (snap.exists) {
        _favoritePrograms.add(FavoriteShops.fromJson(snap.data()));
      } else {
        _favoritePrograms.add(FavoriteShops(
          userId: _auth.currentUser.uid,
          programs: {},
        ));
      }
    });
  }
}
