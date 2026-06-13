import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  shortlisted,
  interview,
  offered,
  hired,
  rejected,
}

class JobApplication {
  final String id;
  final String jobId;
  final String seekerId;
  final String employerId;
  final String jobTitle;
  final String companyName;
  final String seekerName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final bool removedBySeeker;
  final String interviewNote;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.employerId,
    this.jobTitle = '',
    this.companyName = '',
    this.seekerName = '',
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.removedBySeeker = false,
    this.interviewNote = '',
  });

  static ApplicationStatus statusFromString(String? raw) {
    if (raw == 'viewed') return ApplicationStatus.shortlisted;
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == (raw ?? 'pending'),
      orElse: () => ApplicationStatus.pending,
    );
  }

  factory JobApplication.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return JobApplication(
      id: doc.id,
      jobId: d['jobId'] ?? '',
      seekerId: d['seekerId'] ?? '',
      employerId: d['employerId'] ?? '',
      jobTitle: d['jobTitle'] ?? '',
      companyName: d['companyName'] ?? '',
      seekerName: d['seekerName'] ?? '',
      status: statusFromString(d['status'] as String?),
      appliedAt: (d['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      removedBySeeker: d['removedBySeeker'] ?? false,
      interviewNote: d['interviewNote'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'seekerId': seekerId,
        'employerId': employerId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'seekerName': seekerName,
        'status': status.name,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'removedBySeeker': removedBySeeker,
        'interviewNote': interviewNote,
      };
}

class SavedJob {
  final String id;
  final String jobId;
  final String seekerId;
  final DateTime savedAt;

  const SavedJob({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.savedAt,
  });

  factory SavedJob.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SavedJob(
      id: doc.id,
      jobId: d['jobId'] ?? '',
      seekerId: d['seekerId'] ?? '',
      savedAt: (d['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'seekerId': seekerId,
        'savedAt': Timestamp.fromDate(savedAt),
      };
}

class MatchedJob {
  final String id;
  final String jobId;
  final String seekerId;
  final String spotId;
  final double score;
  final DateTime matchedAt;

  const MatchedJob({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.spotId,
    this.score = 0,
    required this.matchedAt,
  });

  factory MatchedJob.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return MatchedJob(
      id: doc.id,
      jobId: d['jobId'] ?? '',
      seekerId: d['seekerId'] ?? '',
      spotId: d['spotId'] ?? '',
      score: (d['score'] as num?)?.toDouble() ?? 0,
      matchedAt: (d['matchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'seekerId': seekerId,
        'spotId': spotId,
        'score': score,
        'matchedAt': Timestamp.fromDate(matchedAt),
      };
}
