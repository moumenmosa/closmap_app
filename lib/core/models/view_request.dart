import 'package:cloud_firestore/cloud_firestore.dart';

enum ViewRequestStatus { pending, approved, rejected }

/// An employer's request to view a seeker's contact info and download the CV.
class ViewRequest {
  final String id;
  final String employerId;
  final String seekerId;
  final String companyName;
  final String companyLogoUrl;
  final String jobId; // empty => headhunting request (no job post)
  final String jobTitle;
  final ViewRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final bool reminded;

  const ViewRequest({
    required this.id,
    required this.employerId,
    required this.seekerId,
    this.companyName = '',
    this.companyLogoUrl = '',
    this.jobId = '',
    this.jobTitle = '',
    this.status = ViewRequestStatus.pending,
    required this.createdAt,
    this.respondedAt,
    this.reminded = false,
  });

  bool get isHeadhunting => jobId.isEmpty;

  factory ViewRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ViewRequest(
      id: doc.id,
      employerId: d['employerId'] ?? '',
      seekerId: d['seekerId'] ?? '',
      companyName: d['companyName'] ?? '',
      companyLogoUrl: d['companyLogoUrl'] ?? '',
      jobId: d['jobId'] ?? '',
      jobTitle: d['jobTitle'] ?? '',
      status: ViewRequestStatus.values.firstWhere(
        (s) => s.name == (d['status'] ?? 'pending'),
        orElse: () => ViewRequestStatus.pending,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (d['respondedAt'] as Timestamp?)?.toDate(),
      reminded: d['reminded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'employerId': employerId,
        'seekerId': seekerId,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'respondedAt':
            respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
        'reminded': reminded,
      };
}
