import 'package:cloud_firestore/cloud_firestore.dart';

class EducationEntry {
  final String level;
  final String field;
  final DateTime? startDate;
  final DateTime? endDate;
  final String description;

  const EducationEntry({
    required this.level,
    required this.field,
    this.startDate,
    this.endDate,
    this.description = '',
  });

  factory EducationEntry.fromMap(Map<String, dynamic> m) => EducationEntry(
        level: m['level'] ?? '',
        field: m['field'] ?? '',
        startDate: (m['startDate'] as Timestamp?)?.toDate(),
        endDate: (m['endDate'] as Timestamp?)?.toDate(),
        description: m['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'level': level,
        'field': field,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'description': description,
      };
}

class ExperienceEntry {
  final String jobTitle;
  final String employmentType;
  final String companyName;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool ongoing;
  final String responsibilities;
  final String achievements;

  const ExperienceEntry({
    required this.jobTitle,
    required this.employmentType,
    required this.companyName,
    this.startDate,
    this.endDate,
    this.ongoing = false,
    this.responsibilities = '',
    this.achievements = '',
  });

  factory ExperienceEntry.fromMap(Map<String, dynamic> m) => ExperienceEntry(
        jobTitle: m['jobTitle'] ?? '',
        employmentType: m['employmentType'] ?? '',
        companyName: m['companyName'] ?? '',
        startDate: (m['startDate'] as Timestamp?)?.toDate(),
        endDate: (m['endDate'] as Timestamp?)?.toDate(),
        ongoing: m['ongoing'] ?? false,
        responsibilities: m['responsibilities'] ?? '',
        achievements: m['achievements'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'jobTitle': jobTitle,
        'employmentType': employmentType,
        'companyName': companyName,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'ongoing': ongoing,
        'responsibilities': responsibilities,
        'achievements': achievements,
      };
}

class LanguageEntry {
  final String language;
  final String proficiency; // Beginner / Intermediate / Advanced / Native

  const LanguageEntry({required this.language, required this.proficiency});

  factory LanguageEntry.fromMap(Map<String, dynamic> m) => LanguageEntry(
        language: m['language'] ?? '',
        proficiency: m['proficiency'] ?? '',
      );

  Map<String, dynamic> toMap() =>
      {'language': language, 'proficiency': proficiency};
}

class SkillEntry {
  final String name;
  final String source; // 'experience' | 'education'
  final int sourceIndex;

  const SkillEntry({
    required this.name,
    this.source = 'experience',
    this.sourceIndex = 0,
  });

  factory SkillEntry.fromMap(Map<String, dynamic> m) => SkillEntry(
        name: m['name'] ?? '',
        source: m['source'] ?? 'experience',
        sourceIndex: (m['sourceIndex'] ?? 0) as int,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'source': source,
        'sourceIndex': sourceIndex,
      };
}

class SeekerProfile {
  final String uid;
  final String gender;
  final String maritalStatus;
  final String nationality;
  final String countryOfResidence;
  final String city;
  final double? lat;
  final double? lng;
  final String photoUrl;
  final DateTime? dateOfBirth;
  final List<EducationEntry> education;
  final List<ExperienceEntry> experience;
  final List<LanguageEntry> languages;
  final List<SkillEntry> skills;
  final String resumeUrl;
  final String resumeName;
  final int resumeSizeBytes;
  final String linkedInUrl;
  final List<String> otherLinks;
  final DateTime? updatedAt;

  const SeekerProfile({
    required this.uid,
    this.gender = '',
    this.maritalStatus = '',
    this.nationality = '',
    this.countryOfResidence = '',
    this.city = '',
    this.lat,
    this.lng,
    this.photoUrl = '',
    this.dateOfBirth,
    this.education = const [],
    this.experience = const [],
    this.languages = const [],
    this.skills = const [],
    this.resumeUrl = '',
    this.resumeName = '',
    this.resumeSizeBytes = 0,
    this.linkedInUrl = '',
    this.otherLinks = const [],
    this.updatedAt,
  });

  String get latestJobTitle =>
      experience.isNotEmpty ? experience.first.jobTitle : '';

  static int monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  static String formatDurationMonths(int totalMonths) {
    if (totalMonths <= 0) return '0Y - 0M';
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    return '${years}Y - ${months}M';
  }

  static int totalExperienceMonths(List<ExperienceEntry> entries) {
    var total = 0;
    final now = DateTime.now();
    for (final e in entries) {
      if (e.startDate == null) continue;
      final end = e.ongoing ? now : e.endDate;
      if (end == null) continue;
      total += monthsBetween(e.startDate!, end);
    }
    return total;
  }

  String get totalExperienceLabel =>
      formatDurationMonths(totalExperienceMonths(experience));

  static int entryDurationMonths(ExperienceEntry e) {
    if (e.startDate == null) return 0;
    final end = e.ongoing ? DateTime.now() : e.endDate;
    if (end == null) return 0;
    return monthsBetween(e.startDate!, end);
  }

  String skillSourceLabel(SkillEntry skill) {
    if (skill.source == 'education' && education.isNotEmpty) {
      final idx = skill.sourceIndex.clamp(0, education.length - 1);
      return '${education[idx].field} - Education';
    }
    if (skill.source == 'experience' && experience.isNotEmpty) {
      final idx = skill.sourceIndex.clamp(0, experience.length - 1);
      final exp = experience[idx];
      return '${exp.jobTitle} - ${exp.companyName}';
    }
    return skill.source == 'education' ? 'Education' : 'Experience';
  }

  static String educationLevelBadge(String level) {
    final lower = level.toLowerCase();
    if (lower.contains('bachelor')) return 'BACHELORS';
    if (lower.contains('master')) return 'MASTERS';
    if (lower.contains('phd') || lower.contains('doctor')) return 'PHD';
    if (lower.contains('diploma')) return 'DIPLOMA';
    if (lower.contains('high school')) return 'HIGH SCHOOL';
    return level.toUpperCase();
  }

  /// 0..1 profile completion used by the wizard progress bar.
  double get completion {
    var score = 0.0;
    if (gender.isNotEmpty &&
        maritalStatus.isNotEmpty &&
        nationality.isNotEmpty &&
        countryOfResidence.isNotEmpty &&
        dateOfBirth != null) {
      score += .3;
    }
    if (education.isNotEmpty) score += .15;
    if (experience.isNotEmpty) score += .2;
    if (languages.isNotEmpty) score += .1;
    if (skills.isNotEmpty) score += .1;
    if (resumeUrl.isNotEmpty) score += .15;
    return score.clamp(0, 1);
  }

  factory SeekerProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SeekerProfile(
      uid: doc.id,
      gender: d['gender'] ?? '',
      maritalStatus: d['maritalStatus'] ?? '',
      nationality: d['nationality'] ?? '',
      countryOfResidence: d['countryOfResidence'] ?? '',
      city: d['city'] ?? '',
      lat: (d['lat'] as num?)?.toDouble(),
      lng: (d['lng'] as num?)?.toDouble(),
      photoUrl: d['photoUrl'] ?? '',
      dateOfBirth: (d['dateOfBirth'] as Timestamp?)?.toDate(),
      education: ((d['education'] ?? []) as List)
          .map((e) => EducationEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      experience: ((d['experience'] ?? []) as List)
          .map((e) => ExperienceEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      languages: ((d['languages'] ?? []) as List)
          .map((e) => LanguageEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      skills: ((d['skills'] ?? []) as List)
          .map((e) => SkillEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      resumeUrl: d['resumeUrl'] ?? '',
      resumeName: d['resumeName'] ?? '',
      resumeSizeBytes: (d['resumeSizeBytes'] ?? 0) as int,
      linkedInUrl: d['linkedInUrl'] ?? '',
      otherLinks: List<String>.from(d['otherLinks'] ?? []),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'gender': gender,
        'maritalStatus': maritalStatus,
        'nationality': nationality,
        'countryOfResidence': countryOfResidence,
        'city': city,
        'lat': lat,
        'lng': lng,
        'photoUrl': photoUrl,
        'dateOfBirth':
            dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
        'education': education.map((e) => e.toMap()).toList(),
        'experience': experience.map((e) => e.toMap()).toList(),
        'languages': languages.map((e) => e.toMap()).toList(),
        'skills': skills.map((e) => e.toMap()).toList(),
        'resumeUrl': resumeUrl,
        'resumeName': resumeName,
        'resumeSizeBytes': resumeSizeBytes,
        'linkedInUrl': linkedInUrl,
        'otherLinks': otherLinks,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  SeekerProfile copyWith({
    String? gender,
    String? maritalStatus,
    String? nationality,
    String? countryOfResidence,
    String? city,
    double? lat,
    double? lng,
    String? photoUrl,
    DateTime? dateOfBirth,
    List<EducationEntry>? education,
    List<ExperienceEntry>? experience,
    List<LanguageEntry>? languages,
    List<SkillEntry>? skills,
    String? resumeUrl,
    String? resumeName,
    int? resumeSizeBytes,
    String? linkedInUrl,
    List<String>? otherLinks,
  }) {
    return SeekerProfile(
      uid: uid,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationality: nationality ?? this.nationality,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      languages: languages ?? this.languages,
      skills: skills ?? this.skills,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeName: resumeName ?? this.resumeName,
      resumeSizeBytes: resumeSizeBytes ?? this.resumeSizeBytes,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      otherLinks: otherLinks ?? this.otherLinks,
      updatedAt: updatedAt,
    );
  }
}
