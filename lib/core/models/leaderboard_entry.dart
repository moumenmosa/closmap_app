import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.rank,
    required this.companyName,
    this.logoUrl = '',
    this.score = 0,
  });

  final String id;
  final int rank;
  final String companyName;
  final String logoUrl;
  final int score;

  factory LeaderboardEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return LeaderboardEntry(
      id: doc.id,
      rank: (d['rank'] ?? 0) as int,
      companyName: d['companyName'] ?? '',
      logoUrl: d['logoUrl'] ?? '',
      score: (d['score'] ?? 0) as int,
    );
  }
}
