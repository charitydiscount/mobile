import 'package:charity_discount/models/achievement.dart';
import 'package:charity_discount/models/user_achievement.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AchievementsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage;

  Future<List<Achievement>> getAchievements() async {
    final snap = await _db.collection(FirestoreCollection.achievements).get();

    // Compute the badge URL
    if (_storage == null) {
      String bucket = await remoteConfig.getPicturesBucket();
      _storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');
    }

    final achievements = snap.docs
        .map(
          (doc) => Achievement.fromJson(
            doc.data()..putIfAbsent('id', () => doc.id),
          ),
        )
        .toList();

    for (int i = 0; i < achievements.length; i++) {
      achievements[i].conditions.removeWhere(
          (element) => element.type != AchievementConditionType.COUNT);
      try {
        achievements[i].badgeUrl = await _storage
            .ref('badges/${achievements[i].badge}')
            .getDownloadURL();
      } catch (e) {
        print('Could not generate badge URL: ${e.message}');
      }
    }

    return achievements..sort((a1, a2) => a1.order.compareTo(a2.order));
  }

  Stream<Map<String, UserAchievement>> getUserAchievements() => _db
          .collection(FirestoreCollection.userAchievements)
          .doc(_auth.currentUser.uid)
          .snapshots()
          .map(
        (event) {
          if (!event.exists) {
            return null;
          }

          Map userAchievements = event.data();
          userAchievements.remove('userId');

          return userAchievements.map(
            (key, value) => MapEntry(
              key,
              UserAchievement.fromJson(value),
            ),
          );
        },
      );
}
