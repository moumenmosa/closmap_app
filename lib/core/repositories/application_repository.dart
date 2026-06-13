import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/job_application.dart';
import '../models/view_request.dart';

class ApplicationRepository {
  ApplicationRepository(this._db);

  final FirebaseFirestore _db;

  Future<bool> hasApplied(String seekerId, String jobId) async {
    final docId = '${seekerId}_$jobId';
    final doc = await _db.collection('applications').doc(docId).get();
    if (doc.exists) return true;
    final legacy = await _db
        .collection('applications')
        .where('seekerId', isEqualTo: seekerId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    return legacy.docs.isNotEmpty;
  }

  /// Creates the application atomically using a deterministic doc id so a
  /// seeker can never apply twice to the same job, even with rapid taps.
  Future<String> apply({
    required String jobId,
    required String seekerId,
    required String employerId,
    required String jobTitle,
    required String companyName,
    required String seekerName,
  }) async {
    final docRef = _db.collection('applications').doc('${seekerId}_$jobId');
    final created = await _db.runTransaction<bool>((tx) async {
      final existing = await tx.get(docRef);
      if (existing.exists) return false;
      tx.set(docRef, {
        'jobId': jobId,
        'seekerId': seekerId,
        'employerId': employerId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'seekerName': seekerName,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
        'removedBySeeker': false,
      });
      return true;
    });
    if (!created) throw StateError('already_applied');
    return docRef.id;
  }

  Stream<List<JobApplication>> watchSeekerApplications(String seekerId) {
    return _db
        .collection('applications')
        .where('seekerId', isEqualTo: seekerId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(JobApplication.fromDoc)
            .where((a) => !a.removedBySeeker)
            .toList());
  }

  Stream<List<JobApplication>> watchJobApplications(String jobId) {
    return _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(JobApplication.fromDoc).toList());
  }

  Future<void> updateApplicationStatus(
    String id,
    ApplicationStatus status, {
    String? interviewNote,
  }) async {
    final data = <String, dynamic>{'status': status.name};
    if (interviewNote != null) {
      data['interviewNote'] = interviewNote;
    }
    await _db.collection('applications').doc(id).update(data);
  }

  Future<JobApplication?> getApplication(String id) async {
    final doc = await _db.collection('applications').doc(id).get();
    if (!doc.exists) return null;
    return JobApplication.fromDoc(doc);
  }

  Stream<List<ViewRequest>> watchApprovedViewRequests(
    String employerId, {
    String? jobId,
  }) {
    return _db
        .collection('viewRequests')
        .where('employerId', isEqualTo: employerId)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
      var list = s.docs.map(ViewRequest.fromDoc).toList();
      if (jobId != null && jobId.isNotEmpty) {
        list = list.where((r) => r.jobId == jobId).toList();
      }
      return list;
    });
  }

  Future<bool> hasApprovedViewRequest(
    String employerId,
    String seekerId,
  ) async {
    final snap = await _db
        .collection('viewRequests')
        .where('employerId', isEqualTo: employerId)
        .where('seekerId', isEqualTo: seekerId)
        .where('status', isEqualTo: 'approved')
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> removeApplication(String id) async {
    await _db.collection('applications').doc(id).update({
      'removedBySeeker': true,
    });
  }

  Stream<List<SavedJob>> watchSavedJobs(String seekerId) {
    return _db
        .collection('savedJobs')
        .where('seekerId', isEqualTo: seekerId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(SavedJob.fromDoc).toList());
  }

  Future<bool> isSaved(String seekerId, String jobId) async {
    final snap = await _db
        .collection('savedJobs')
        .where('seekerId', isEqualTo: seekerId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> toggleSaved(String seekerId, String jobId) async {
    final snap = await _db
        .collection('savedJobs')
        .where('seekerId', isEqualTo: seekerId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.delete();
    } else {
      await _db.collection('savedJobs').add({
        'seekerId': seekerId,
        'jobId': jobId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeSaved(String savedId) async {
    await _db.collection('savedJobs').doc(savedId).delete();
  }

  Stream<List<MatchedJob>> watchMatchedJobs(String seekerId) {
    return _db
        .collection('matchedJobs')
        .where('seekerId', isEqualTo: seekerId)
        .orderBy('matchedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(MatchedJob.fromDoc).toList());
  }

  Future<void> addMatchedJob({
    required String seekerId,
    required String jobId,
    required String spotId,
    required double score,
  }) async {
    final existing = await _db
        .collection('matchedJobs')
        .where('seekerId', isEqualTo: seekerId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    await _db.collection('matchedJobs').add({
      'seekerId': seekerId,
      'jobId': jobId,
      'spotId': spotId,
      'score': score,
      'matchedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ViewRequest>> watchPendingRequests(String seekerId) {
    return _db
        .collection('viewRequests')
        .where('seekerId', isEqualTo: seekerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ViewRequest.fromDoc).toList());
  }

  /// Pending view requests older than 24 hours (client-side stale check).
  Future<bool> hasStalePendingRequests(String seekerId) async {
    final snap = await _db
        .collection('viewRequests')
        .where('seekerId', isEqualTo: seekerId)
        .where('status', isEqualTo: 'pending')
        .get();
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return snap.docs.any((d) {
      final ts = d.data()['createdAt'] as Timestamp?;
      return ts != null && ts.toDate().isBefore(cutoff);
    });
  }

  Future<bool> canSendViewRequest(String employerId, String seekerId) async {
    final weekAgo = DateTime.now().subtract(
      Duration(days: AppConfig.viewRequestCooldownDays),
    );
    final snap = await _db
        .collection('viewRequests')
        .where('employerId', isEqualTo: employerId)
        .where('seekerId', isEqualTo: seekerId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
        .limit(1)
        .get();
    return snap.docs.isEmpty;
  }

  Future<String> sendViewRequest(ViewRequest request) async {
    final ref = await _db.collection('viewRequests').add(request.toMap());
    return ref.id;
  }

  Future<ViewRequest?> getViewRequest(String id) async {
    final doc = await _db.collection('viewRequests').doc(id).get();
    if (!doc.exists) return null;
    return ViewRequest.fromDoc(doc);
  }

  Stream<List<ViewRequest>> watchEmployerHeadhuntingRequests(String employerId) {
    return _db
        .collection('viewRequests')
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(ViewRequest.fromDoc)
            .where((r) => r.jobId.isEmpty)
            .toList());
  }

  Future<void> respondToViewRequest(
    String id,
    ViewRequestStatus status,
  ) async {
    await _db.collection('viewRequests').doc(id).update({
      'status': status.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }
}
