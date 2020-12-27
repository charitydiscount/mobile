import 'package:charity_discount/models/leaderboard.dart';
import 'package:charity_discount/util/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final snap = await _db
        .collection(FirestoreCollection.leaderboard)
        .orderBy('points', descending: true)
        .limit(10)
        .get();

    final entries =
        snap.docs.map((doc) => LeaderboardEntry.fromJson(doc.data())).toList();

    entries.sort((e1, e2) => e2.points.compareTo(e1.points));

    return entries;
  }

  Future<LeaderboardEntry> getOwnEntry() async {
    final snap = await _db
        .collection(FirestoreCollection.leaderboard)
        .doc(_auth.currentUser.uid)
        .get();

    return snap.exists ? LeaderboardEntry.fromJson(snap.data()) : null;
  }
}
