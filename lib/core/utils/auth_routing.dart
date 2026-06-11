import '../models/app_user.dart';

/// Shared post-auth destination used by splash, OTP, and router redirects.
String homeRouteForUser(AppUser user) {
  if (user.role == UserRole.admin) return '/admin/home';
  if (!user.profileCompleted) {
    return user.role == UserRole.employer
        ? '/employer/profile'
        : '/seeker/profile-wizard';
  }
  return user.role == UserRole.employer ? '/employer/home' : '/seeker/home';
}
