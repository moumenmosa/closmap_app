import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<LeaderboardEntry>> watchTopCompanies({int limit = 10}) {
    return _db
        .collection('leaderboard')
        .orderBy('rank')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(LeaderboardEntry.fromDoc).toList());
  }
}
