import '../models/exploring_spot.dart';
import '../models/job_post.dart';
import '../models/seeker_profile.dart';
import '../utils/geo_utils.dart';

class MatchingService {
  double scoreJob(SeekerProfile profile, JobPost job) {
    var score = 0.0;
    if (profile.latestJobTitle.isNotEmpty &&
        job.title.toLowerCase().contains(profile.latestJobTitle.toLowerCase())) {
      score += 0.4;
    }
    final seekerSkills =
        profile.skills.map((s) => s.name.toLowerCase()).toSet();
    final jobSkills = job.skills.map((s) => s.toLowerCase()).toSet();
    if (seekerSkills.isNotEmpty && jobSkills.isNotEmpty) {
      final overlap = seekerSkills.intersection(jobSkills).length;
      score += (overlap / jobSkills.length).clamp(0, 1) * 0.35;
    }
    final seekerLangs =
        profile.languages.map((l) => l.language.toLowerCase()).toSet();
    final jobLangs = job.languages.map((l) => l.toLowerCase()).toSet();
    if (seekerLangs.isNotEmpty && jobLangs.isNotEmpty) {
      final overlap = seekerLangs.intersection(jobLangs).length;
      score += (overlap / jobLangs.length).clamp(0, 1) * 0.15;
    }
    if (profile.education.isNotEmpty &&
        job.fieldOfEducation.isNotEmpty &&
        profile.education.any((e) =>
            e.field.toLowerCase() == job.fieldOfEducation.toLowerCase())) {
      score += 0.1;
    }
    return score.clamp(0, 1);
  }

  bool isMatchInSpot(ExploringSpot spot, JobPost job, SeekerProfile profile,
      {double minScore = 0.35}) {
    if (!job.isActive || job.lat == null || job.lng == null) return false;
    if (!GeoUtils.withinRadius(
        spot.lat, spot.lng, job.lat!, job.lng!, spot.radiusKm)) {
      return false;
    }
    return scoreJob(profile, job) >= minScore;
  }

  List<JobPost> scoreAndSort(
    List<JobPost> jobs,
    SeekerProfile profile, {
    double? lat,
    double? lng,
  }) {
    final scored = jobs.map((j) {
      var s = scoreJob(profile, j);
      if (lat != null && lng != null && j.lat != null && j.lng != null) {
        final dist = GeoUtils.distanceKm(lat, lng, j.lat!, j.lng!);
        s += (1 / (1 + dist)) * 0.1;
      }
      return (job: j, score: s);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.job).toList();
  }
}
