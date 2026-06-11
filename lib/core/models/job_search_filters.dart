class JobSearchFilters {
  const JobSearchFilters({
    this.jobTitles = const {},
    this.useExploringSpot = false,
    this.location = '',
    this.company = '',
    this.experienceLevel,
    this.fieldOfEducation,
    this.levelOfEducation,
    this.jobType,
    this.remoteOption,
    this.genderType,
    this.languages = const {},
    this.salaryMin = 0,
    this.salaryMax = 100000,
    this.keyword = '',
    this.city = '',
    this.lat,
    this.lng,
    this.spotLat,
    this.spotLng,
    this.spotRadiusKm,
  });

  final Set<String> jobTitles;
  final bool useExploringSpot;
  final String location;
  final String company;
  final String? experienceLevel;
  final String? fieldOfEducation;
  final String? levelOfEducation;
  final String? jobType;
  final String? remoteOption;
  final String? genderType;
  final Set<String> languages;
  final double salaryMin;
  final double salaryMax;
  final String keyword;
  final String city;
  final double? lat;
  final double? lng;
  final double? spotLat;
  final double? spotLng;
  final double? spotRadiusKm;

  static const double salaryFloor = 0;
  static const double salaryCeiling = 100000;

  bool get hasActiveFilters =>
      jobTitles.isNotEmpty ||
      location.isNotEmpty ||
      company.isNotEmpty ||
      experienceLevel != null ||
      fieldOfEducation != null ||
      levelOfEducation != null ||
      jobType != null ||
      remoteOption != null ||
      (genderType != null && genderType != 'All') ||
      languages.isNotEmpty ||
      salaryMin > salaryFloor ||
      salaryMax < salaryCeiling ||
      useExploringSpot;

  String get jobTitlesLabel {
    if (jobTitles.isEmpty) return '';
    if (jobTitles.length <= 2) return jobTitles.join(', ');
    return '${jobTitles.take(2).join(', ')}...';
  }

  JobSearchFilters copyWith({
    Set<String>? jobTitles,
    bool? useExploringSpot,
    String? location,
    String? company,
    String? experienceLevel,
    String? fieldOfEducation,
    String? levelOfEducation,
    String? jobType,
    String? remoteOption,
    String? genderType,
    Set<String>? languages,
    double? salaryMin,
    double? salaryMax,
    String? keyword,
    String? city,
    double? lat,
    double? lng,
    double? spotLat,
    double? spotLng,
    double? spotRadiusKm,
    bool clearExperienceLevel = false,
    bool clearFieldOfEducation = false,
    bool clearLevelOfEducation = false,
    bool clearJobType = false,
    bool clearRemoteOption = false,
    bool clearGenderType = false,
  }) {
    return JobSearchFilters(
      jobTitles: jobTitles ?? this.jobTitles,
      useExploringSpot: useExploringSpot ?? this.useExploringSpot,
      location: location ?? this.location,
      company: company ?? this.company,
      experienceLevel:
          clearExperienceLevel ? null : (experienceLevel ?? this.experienceLevel),
      fieldOfEducation: clearFieldOfEducation
          ? null
          : (fieldOfEducation ?? this.fieldOfEducation),
      levelOfEducation: clearLevelOfEducation
          ? null
          : (levelOfEducation ?? this.levelOfEducation),
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      remoteOption:
          clearRemoteOption ? null : (remoteOption ?? this.remoteOption),
      genderType: clearGenderType ? null : (genderType ?? this.genderType),
      languages: languages ?? this.languages,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      keyword: keyword ?? this.keyword,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      spotLat: spotLat ?? this.spotLat,
      spotLng: spotLng ?? this.spotLng,
      spotRadiusKm: spotRadiusKm ?? this.spotRadiusKm,
    );
  }

  static const empty = JobSearchFilters();
}
