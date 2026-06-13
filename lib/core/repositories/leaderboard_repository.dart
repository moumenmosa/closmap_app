import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<LeaderboardEntry>> watchTopCompanies({int limit = 10}) {
    return _db.collection('jobs').snapshots().asyncMap((_) => _loadTop(limit));
  }

  Future<List<LeaderboardEntry>> _loadTop(int limit) async {
    try {
      final live = await _computeLive(limit);
      if (live.isNotEmpty) return live;
    } catch (_) {
      // Fall back to seeded leaderboard when live aggregation fails.
    }
    return _loadSeeded(limit);
  }

  Future<List<LeaderboardEntry>> _loadSeeded(int limit) async {
    final seeded = await _db
        .collection('leaderboard')
        .orderBy('rank')
        .limit(limit)
        .get();
    return seeded.docs.map(LeaderboardEntry.fromDoc).toList();
  }

  /// Ranks employers using job data only (readable by all signed-in users).
  Future<List<LeaderboardEntry>> _computeLive(int limit) async {
    final jobsSnap = await _db.collection('jobs').get();

    final scores = <String, _EmployerScore>{};

    for (final doc in jobsSnap.docs) {
      final d = doc.data();
      if (d['status'] != 'active') continue;
      final employerId = d['employerId'] as String? ?? '';
      if (employerId.isEmpty) continue;
      final entry = scores.putIfAbsent(employerId, () => _EmployerScore());
      entry.activeJobs++;
      entry.totalApplicants += (d['applicantsCount'] as num?)?.toInt() ?? 0;
    }

    if (scores.isEmpty) return [];

    final entries = <LeaderboardEntry>[];
    for (final e in scores.entries) {
      final profile =
          await _db.collection('employerProfiles').doc(e.key).get();
      final user = await _db.collection('users').doc(e.key).get();
      final pd = profile.data() ?? {};
      final ud = user.data() ?? {};
      final companyName = (pd['companyName'] as String?)?.isNotEmpty == true
          ? pd['companyName'] as String
          : (ud['companyName'] as String? ?? 'Company');
      final logoUrl = pd['logoUrl'] as String? ?? '';
      final score = e.value.activeJobs * 10 + e.value.totalApplicants * 5;
      entries.add(LeaderboardEntry(
        id: e.key,
        rank: 0,
        companyName: companyName,
        logoUrl: logoUrl,
        score: score,
      ));
    }

    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map((e) => LeaderboardEntry(
              id: e.value.id,
              rank: e.key + 1,
              companyName: e.value.companyName,
              logoUrl: e.value.logoUrl,
              score: e.value.score,
            ))
        .toList();
  }
}

class _EmployerScore {
  int activeJobs = 0;
  int totalApplicants = 0;
}
