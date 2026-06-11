import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/notification_prefs.dart';
import '../models/employer_profile.dart';
import '../models/seeker_profile.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  Future<SeekerProfile?> getSeekerProfile(String uid) async {
    final doc = await _db.collection('seekerProfiles').doc(uid).get();
    if (!doc.exists) return null;
    return SeekerProfile.fromDoc(doc);
  }

  Stream<SeekerProfile?> watchSeekerProfile(String uid) {
    return _db.collection('seekerProfiles').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SeekerProfile.fromDoc(doc);
    });
  }

  Future<void> saveSeekerProfile(SeekerProfile profile, {bool enforceDailyLimit = false}) async {
    if (enforceDailyLimit) {
      final userDoc = await _db.collection('users').doc(profile.uid).get();
      final last = (userDoc.data()?['lastProfileUpdate'] as Timestamp?)?.toDate();
      if (last != null && DateTime.now().difference(last).inHours < 24) {
        throw Exception('profile_update_limit');
      }
    }
    await _db.collection('seekerProfiles').doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
    await _db.collection('users').doc(profile.uid).update({
      'profileCompleted': true,
      'latestJobTitle': profile.latestJobTitle,
      'lastProfileUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<EmployerProfile?> getEmployerProfile(String uid) async {
    final doc = await _db.collection('employerProfiles').doc(uid).get();
    if (!doc.exists) return null;
    return EmployerProfile.fromDoc(doc);
  }

  Stream<EmployerProfile?> watchEmployerProfile(String uid) {
    return _db.collection('employerProfiles').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return EmployerProfile.fromDoc(doc);
    });
  }

  Future<void> saveEmployerProfile(EmployerProfile profile) async {
    await _db.collection('employerProfiles').doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
    await _db.collection('users').doc(profile.uid).update({
      'profileCompleted': true,
      'companyName': profile.companyName,
      'lastProfileUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> updateNotificationPrefs(String uid, NotificationPrefs prefs) async {
    await _db.collection('users').doc(uid).update({
      'notificationPrefs': prefs.toMap(),
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Stream<List<EmployerProfile>> watchEmployersWithLocation() {
    return _db.collection('employerProfiles').snapshots().map((snap) {
      return snap.docs
          .map(EmployerProfile.fromDoc)
          .where((p) => p.hasLocation)
          .toList();
    });
  }

  Stream<List<SeekerProfile>> watchSeekersWithLocation() {
    return _db.collection('seekerProfiles').snapshots().map((snap) {
      return snap.docs
          .map(SeekerProfile.fromDoc)
          .where((p) => p.lat != null && p.lng != null)
          .toList();
    });
  }

  Future<List<SeekerProfile>> getAllSeekerProfiles() async {
    final snap = await _db.collection('seekerProfiles').get();
    return snap.docs.map(SeekerProfile.fromDoc).toList();
  }
}
