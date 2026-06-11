import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exploring_spot.dart';

class SpotRepository {
  SpotRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<ExploringSpot>> watchSpots(String seekerId) {
    return _db
        .collection('exploringSpots')
        .where('seekerId', isEqualTo: seekerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ExploringSpot.fromDoc).toList());
  }

  Future<void> addSpot(ExploringSpot spot) async {
    await _db.collection('exploringSpots').add(spot.toMap());
  }

  Future<void> updateSpot(String id, ExploringSpot spot) async {
    await _db.collection('exploringSpots').doc(id).set(spot.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteSpot(String id) async {
    await _db.collection('exploringSpots').doc(id).delete();
  }
}
