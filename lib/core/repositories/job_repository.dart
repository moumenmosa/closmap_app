import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_post.dart';
import '../models/job_search_filters.dart';
import '../utils/geo_utils.dart';

class JobRepository {
  JobRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _jobs =>
      _db.collection('jobs');

  Stream<List<JobPost>> watchActiveJobs({List<String>? titleFilters}) {
    return _jobs
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snap) {
      var jobs = snap.docs.map(JobPost.fromDoc).toList();
      jobs = _applyTitleFilters(jobs, titleFilters);
      return jobs;
    });
  }

  Future<List<JobPost>> searchJobs({
    String? keyword,
    String? jobType,
    String? city,
    double? lat,
    double? lng,
    JobSearchFilters? filters,
  }) async {
    final snap = await _jobs
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .get();
    var jobs = snap.docs.map(JobPost.fromDoc).toList();

    final f = filters ?? const JobSearchFilters();
    final effectiveKeyword = (keyword ?? f.keyword).trim();
    final effectiveCity = (city ?? f.city).trim();
    final effectiveJobType = jobType ?? f.jobType;

    if (effectiveKeyword.isNotEmpty) {
      final k = effectiveKeyword.toLowerCase();
      jobs = jobs
          .where((j) =>
              j.title.toLowerCase().contains(k) ||
              j.companyName.toLowerCase().contains(k) ||
              j.skills.any((s) => s.toLowerCase().contains(k)))
          .toList();
    }
    jobs = _applyTitleFilters(jobs, f.jobTitles.isEmpty ? null : f.jobTitles.toList());
    if (effectiveJobType != null && effectiveJobType.isNotEmpty) {
      jobs = jobs.where((j) => j.jobType == effectiveJobType).toList();
    }
    if (effectiveCity.isNotEmpty) {
      jobs = jobs
          .where((j) => j.city.toLowerCase().contains(effectiveCity.toLowerCase()))
          .toList();
    }
    if (f.location.isNotEmpty) {
      final loc = f.location.toLowerCase();
      jobs = jobs
          .where((j) =>
              j.city.toLowerCase().contains(loc) ||
              j.locationText.toLowerCase().contains(loc) ||
              j.country.toLowerCase().contains(loc))
          .toList();
    }
    if (f.company.isNotEmpty) {
      final c = f.company.toLowerCase();
      jobs = jobs.where((j) => j.companyName.toLowerCase().contains(c)).toList();
    }
    if (f.experienceLevel != null && f.experienceLevel!.isNotEmpty) {
      jobs = jobs.where((j) => j.experienceLevel == f.experienceLevel).toList();
    }
    if (f.fieldOfEducation != null && f.fieldOfEducation!.isNotEmpty) {
      jobs = jobs.where((j) => j.fieldOfEducation == f.fieldOfEducation).toList();
    }
    if (f.levelOfEducation != null && f.levelOfEducation!.isNotEmpty) {
      jobs = jobs.where((j) => j.levelOfEducation == f.levelOfEducation).toList();
    }
    if (f.remoteOption != null && f.remoteOption!.isNotEmpty) {
      jobs = jobs.where((j) => j.remoteOption == f.remoteOption).toList();
    }
    if (f.genderType != null && f.genderType!.isNotEmpty && f.genderType != 'All') {
      jobs = jobs
          .where((j) => j.genderType == f.genderType || j.genderType == 'All')
          .toList();
    }
    if (f.languages.isNotEmpty) {
      jobs = jobs
          .where((j) => f.languages.any((l) => j.languages.contains(l)))
          .toList();
    }
    if (f.salaryMin > JobSearchFilters.salaryFloor ||
        f.salaryMax < JobSearchFilters.salaryCeiling) {
      jobs = jobs
          .where((j) => j.salaryMax >= f.salaryMin && j.salaryMin <= f.salaryMax)
          .toList();
    }

    final sortLat = f.useExploringSpot ? f.spotLat : (lat ?? f.lat);
    final sortLng = f.useExploringSpot ? f.spotLng : (lng ?? f.lng);
    final radiusKm = f.useExploringSpot ? f.spotRadiusKm : null;

    if (radiusKm != null && sortLat != null && sortLng != null) {
      jobs = jobs.where((j) {
        if (j.lat == null || j.lng == null) return false;
        return GeoUtils.distanceKm(sortLat, sortLng, j.lat!, j.lng!) <= radiusKm;
      }).toList();
    }

    if (sortLat != null && sortLng != null) {
      jobs.sort((a, b) {
        if (a.lat == null || a.lng == null) return 1;
        if (b.lat == null || b.lng == null) return -1;
        final da = GeoUtils.distanceKm(sortLat, sortLng, a.lat!, a.lng!);
        final db = GeoUtils.distanceKm(sortLat, sortLng, b.lat!, b.lng!);
        return da.compareTo(db);
      });
    }
    return jobs;
  }

  List<JobPost> _applyTitleFilters(List<JobPost> jobs, List<String>? titleFilters) {
    if (titleFilters == null || titleFilters.isEmpty) return jobs;
    final lowered = titleFilters.map((t) => t.toLowerCase()).toList();
    return jobs
        .where((j) {
          final title = j.title.toLowerCase();
          return lowered.any((t) => title.contains(t));
        })
        .toList();
  }

  Future<JobPost?> getJob(String id) async {
    try {
      final doc = await _jobs.doc(id).get();
      if (!doc.exists) return null;
      return JobPost.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  Stream<List<JobPost>> watchEmployerJobs(String employerId) {
    return _jobs
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(JobPost.fromDoc).toList());
  }

  Future<String> saveJob(JobPost job) async {
    if (job.id.isEmpty) {
      final ref = await _jobs.add(job.toMap());
      return ref.id;
    }
    await _jobs.doc(job.id).set(job.toMap(), SetOptions(merge: true));
    return job.id;
  }

  /// Atomically activates a job via merge-set (avoids update-not-found failures).
  Future<String> publishJobPost(JobPost job, int validityDays) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: validityDays));
    final data = Map<String, dynamic>.from(job.toMap())
      ..['status'] = 'active'
      ..['publishedAt'] = Timestamp.fromDate(now)
      ..['expiresAt'] = Timestamp.fromDate(expiresAt)
      ..['validityDays'] = validityDays
      ..['updatedAt'] = FieldValue.serverTimestamp();

    if (job.id.isEmpty) {
      final ref = await _jobs.add(data);
      return ref.id;
    }
    await _jobs.doc(job.id).set(data, SetOptions(merge: true));
    return job.id;
  }

  @Deprecated('Use publishJobPost')
  Future<void> publishJob(String jobId, int validityDays) async {
    final now = DateTime.now();
    await _jobs.doc(jobId).update({
      'status': 'active',
      'publishedAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(Duration(days: validityDays))),
      'validityDays': validityDays,
    });
  }

  Future<void> incrementApplicants(String jobId) async {
    await _jobs.doc(jobId).update({
      'applicantsCount': FieldValue.increment(1),
    });
  }
}
