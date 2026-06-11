import '../models/app_user.dart';
import '../models/job_post.dart';
import 'geo_utils.dart';

class SubscriptionUtils {
  SubscriptionUtils._();

  static bool canApplyToJob({
    required AppUser user,
    required JobPost job,
    required double seekerLat,
    required double seekerLng,
    String? seekerCity,
    String? seekerCountry,
  }) {
    if (!user.hasActiveSubscription) return false;
    if (job.lat == null || job.lng == null) return true;

    switch (user.activeTier) {
      case SubscriptionTier.gold:
        return true;
      case SubscriptionTier.silver:
        if (seekerCountry != null &&
            job.country.isNotEmpty &&
            seekerCountry.toLowerCase() != job.country.toLowerCase()) {
          return false;
        }
        return true;
      case SubscriptionTier.bronze:
        if (seekerCity != null &&
            job.city.isNotEmpty &&
            seekerCity.toLowerCase() != job.city.toLowerCase()) {
          return false;
        }
        final dist = GeoUtils.distanceKm(
          seekerLat,
          seekerLng,
          job.lat!,
          job.lng!,
        );
        return dist <= 50; // same city ~50km radius
      case SubscriptionTier.none:
        return false;
    }
  }

  static bool canPostJob({
    required AppUser user,
    required String employerCountry,
    required String jobCountry,
  }) {
    if (!user.hasActiveSubscription) return false;
    if (user.activeTier == SubscriptionTier.gold) return true;
    return employerCountry.toLowerCase() == jobCountry.toLowerCase();
  }
}
