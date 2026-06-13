import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus { draft, active, expired }

class JobPost {
  final String id;
  final String employerId;
  final String companyName;
  final String companyLogoUrl;
  final String title;
  final String experienceLevel;
  final int yearsOfExperience;
  final List<String> skills;
  final String jobType; // Full-Time / Part-Time ...
  final String remoteOption; // On Site / Remote / Hybrid
  final String fieldOfEducation;
  final String levelOfEducation;
  final List<String> languages;
  final num salaryMin;
  final num salaryMax;
  final String currency;
  final String genderType;
  final DateTime? joiningDate;
  final String about;
  final String duties;
  final List<String> benefits;
  final List<String> requiredSkills;
  final String locationText;
  final String city;
  final String country;
  final double? lat;
  final double? lng;
  final String geohash;
  final int validityDays;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final String status; // draft | active
  final int applicantsCount;
  final DateTime createdAt;

  const JobPost({
    required this.id,
    required this.employerId,
    this.companyName = '',
    this.companyLogoUrl = '',
    this.title = '',
    this.experienceLevel = '',
    this.yearsOfExperience = 0,
    this.skills = const [],
    this.jobType = '',
    this.remoteOption = '',
    this.fieldOfEducation = '',
    this.levelOfEducation = '',
    this.languages = const [],
    this.salaryMin = 0,
    this.salaryMax = 0,
    this.currency = 'SR',
    this.genderType = 'All',
    this.joiningDate,
    this.about = '',
    this.duties = '',
    this.benefits = const [],
    this.requiredSkills = const [],
    this.locationText = '',
    this.city = '',
    this.country = '',
    this.lat,
    this.lng,
    this.geohash = '',
    this.validityDays = 7,
    this.publishedAt,
    this.expiresAt,
    this.status = 'draft',
    this.applicantsCount = 0,
    required this.createdAt,
  });

  bool get isDraft => status == 'draft';

  bool get isExpired =>
      status == 'active' &&
      expiresAt != null &&
      expiresAt!.isBefore(DateTime.now());

  bool get isActive => status == 'active' && !isExpired;

  JobStatus get effectiveStatus => isDraft
      ? JobStatus.draft
      : isExpired
          ? JobStatus.expired
          : JobStatus.active;

  Duration? get timeRemaining =>
      expiresAt == null ? null : expiresAt!.difference(DateTime.now());

  String get salaryLabel =>
      '${_fmt(salaryMin)} $currency - ${_fmt(salaryMax)} $currency';

  static String _fmt(num n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _stringField(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.map((e) => e.toString()).join('\n');
    return value.toString();
  }

  factory JobPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return JobPost(
      id: doc.id,
      employerId: d['employerId'] ?? '',
      companyName: d['companyName'] ?? '',
      companyLogoUrl: d['companyLogoUrl'] ?? '',
      title: d['title'] ?? '',
      experienceLevel: d['experienceLevel'] ?? '',
      yearsOfExperience: (d['yearsOfExperience'] as num?)?.toInt() ?? 0,
      skills: List<String>.from(d['skills'] ?? []),
      jobType: d['jobType'] ?? '',
      remoteOption: d['remoteOption'] ?? '',
      fieldOfEducation: d['fieldOfEducation'] ?? '',
      levelOfEducation: d['levelOfEducation'] ?? '',
      languages: List<String>.from(d['languages'] ?? []),
      salaryMin: (d['salaryMin'] ?? 0) as num,
      salaryMax: (d['salaryMax'] ?? 0) as num,
      currency: d['currency'] ?? 'SR',
      genderType: d['genderType'] ?? 'All',
      joiningDate: (d['joiningDate'] as Timestamp?)?.toDate(),
      about: d['about'] ?? '',
      duties: _stringField(d['duties']),
      benefits: List<String>.from(d['benefits'] ?? []),
      requiredSkills: List<String>.from(
        d['requiredSkills'] ?? d['skills'] ?? [],
      ),
      locationText: d['locationText'] ?? '',
      city: d['city'] ?? '',
      country: d['country'] ?? '',
      lat: (d['lat'] as num?)?.toDouble(),
      lng: (d['lng'] as num?)?.toDouble(),
      geohash: d['geohash'] ?? '',
      validityDays: (d['validityDays'] as num?)?.toInt() ?? 7,
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate(),
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
      status: d['status'] ?? 'draft',
      applicantsCount: (d['applicantsCount'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'employerId': employerId,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'title': title,
        'experienceLevel': experienceLevel,
        'yearsOfExperience': yearsOfExperience,
        'jobType': jobType,
        'remoteOption': remoteOption,
        'fieldOfEducation': fieldOfEducation,
        'levelOfEducation': levelOfEducation,
        'languages': languages,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'currency': currency,
        'genderType': genderType,
        'joiningDate':
            joiningDate != null ? Timestamp.fromDate(joiningDate!) : null,
        'about': about,
        'duties': duties,
        'benefits': benefits,
        'requiredSkills': requiredSkills,
        'skills': requiredSkills.isNotEmpty ? requiredSkills : skills,
        'locationText': locationText,
        'city': city,
        'country': country,
        'lat': lat,
        'lng': lng,
        'geohash': geohash,
        'validityDays': validityDays,
        'publishedAt':
            publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'status': status,
        'applicantsCount': applicantsCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
