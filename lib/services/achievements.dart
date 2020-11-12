import 'package:charity_discount/models/achievement.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Achievement>> getAchievements() async {
    final snap = await _db.collection(FirestoreCollection.achievements).get();
    return snap.docs.map((doc) => Achievement.fromJson(doc.data()));
  }
}
