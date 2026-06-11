import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/app_user.dart';
import '../models/notification_item.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<SubscriptionPlan>> watchPlans() {
    return _db.collection('plans').snapshots().map(
          (s) => s.docs.map(SubscriptionPlan.fromDoc).toList()
            ..sort((a, b) => a.price.compareTo(b.price)),
        );
  }

  Stream<List<PointPackage>> watchPointPackages() {
    return _db.collection('pointPackages').snapshots().map(
          (s) => s.docs.map(PointPackage.fromDoc).toList()
            ..sort((a, b) => a.points.compareTo(b.points)),
        );
  }

  Future<void> subscribe(String uid, SubscriptionTier tier, int points) async {
    final expiry = DateTime.now().add(const Duration(days: AppConfig.subscriptionDays));
    await _db.collection('users').doc(uid).update({
      'tier': tier.name,
      'points': FieldValue.increment(points),
      'subscriptionExpiry': Timestamp.fromDate(expiry),
    });
    await _addTransaction(
      uid: uid,
      type: 'subscription',
      description: '${tier.name} plan',
      pointsDelta: points,
    );
  }

  Future<void> purchasePoints(String uid, int points, String packageId) async {
    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(points),
    });
    await _addTransaction(
      uid: uid,
      type: 'points_purchase',
      description: 'Points package $packageId',
      pointsDelta: points,
    );
  }

  Future<bool> deductPoint(String uid, String description) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    final points = (userDoc.data()?['points'] ?? 0) as int;
    if (points < 1) return false;
    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(-1),
    });
    await _addTransaction(
      uid: uid,
      type: 'deduction',
      description: description,
      pointsDelta: -1,
    );
    return true;
  }

  Future<void> _addTransaction({
    required String uid,
    required String type,
    required String description,
    required int pointsDelta,
  }) async {
    await _db.collection('transactions').add({
      'userId': uid,
      'type': type,
      'description': description,
      'pointsDelta': pointsDelta,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TransactionItem>> watchTransactions(String uid) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(TransactionItem.fromDoc).toList());
  }
}
