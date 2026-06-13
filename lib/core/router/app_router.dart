import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/applications/applications_screen.dart';
import '../../features/applications/view_request_detail_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/employer_jobs/add_job_screen.dart';
import '../../features/employer_jobs/application_detail_screen.dart';
import '../../features/employer_jobs/applicants_screen.dart';
import '../../features/employer_jobs/headhunting_screen.dart';
import '../../features/employer_jobs/posted_jobs_screen.dart';
import '../../features/employer_profile/employer_profile_screen.dart';
import '../../features/admin/admin_home_screen.dart';
import '../../features/home/employer_home_screen.dart';
import '../../features/home/seeker_home_screen.dart';
import '../../features/jobs/company_profile_screen.dart';
import '../../features/jobs/job_details_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/settings/about_app_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/search/filter_screen.dart';
import '../../features/search/search_screen.dart';
import '../models/job_search_filters.dart';
import '../../features/seeker_profile/seeker_profile_screen.dart';
import '../../core/models/seeker_profile.dart';
import '../../features/seeker_profile/seeker_profile_wizard.dart';
import '../../features/spots/add_spot_screen.dart';
import '../../features/spots/exploring_spots_screen.dart';
import '../../features/subscriptions/payment_screen.dart';
import '../../features/subscriptions/plans_screen.dart';
import '../../features/subscriptions/subscriptions_screen.dart';
import '../../firebase_options.dart';
import '../utils/auth_routing.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (DefaultFirebaseOptions.isPlaceholder &&
          state.matchedLocation != '/setup') {
        return '/setup';
      }
      final loggedIn = authState.valueOrNull != null;
      final onAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation.startsWith('/forgot') ||
          state.matchedLocation.startsWith('/welcome') ||
          state.matchedLocation == '/setup';

      if (!loggedIn && !onAuth && state.matchedLocation != '/') {
        return '/login';
      }

      final onSplash = state.matchedLocation == '/';

      if (loggedIn && !onAuth && !onSplash) {
        if (userState.isLoading) return null;
        final user = userState.valueOrNull;
        if (user == null) return '/login';
        if (!user.emailVerified) return '/otp';
        // Verified user on an in-app route: allow navigation.
        return null;
      }

      if (loggedIn && onAuth && state.matchedLocation != '/otp') {
        if (userState.isLoading) return null;
        final user = userState.valueOrNull;
        if (user == null) return null;
        if (!user.emailVerified) return '/otp';
        return homeRouteForUser(user);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/setup',
        builder: (_, _) => const SetupFirebaseScreen(),
      ),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (_, _) => const OtpScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/admin/home', builder: (_, _) => const AdminHomeScreen()),
      GoRoute(path: '/seeker/home', builder: (_, _) => const SeekerHomeScreen()),
      GoRoute(
        path: '/employer/home',
        builder: (_, _) => const EmployerHomeScreen(),
      ),
      GoRoute(
        path: '/seeker/profile-wizard',
        builder: (_, state) => SeekerProfileWizard(
          initial: state.extra as SeekerProfile?,
          enforceDailyLimit: state.uri.queryParameters['edit'] == '1',
        ),
      ),
      GoRoute(
        path: '/seeker/profile',
        builder: (_, _) => const SeekerProfileScreen(),
      ),
      GoRoute(
        path: '/employer/profile',
        builder: (_, _) => const EmployerProfileScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (_, state) => JobDetailsScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/company/:id',
        builder: (_, state) =>
            CompanyProfileScreen(employerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/applications',
        builder: (_, _) => const ApplicationsScreen(),
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: '/filter',
        builder: (_, state) => FilterScreen(
          initial: state.extra as JobSearchFilters? ?? JobSearchFilters.empty,
        ),
      ),
      GoRoute(
        path: '/employer/jobs',
        builder: (_, _) => const PostedJobsScreen(),
      ),
      GoRoute(
        path: '/employer/job/add',
        builder: (_, state) => AddJobScreen(jobId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/employer/job/:id/applicants',
        builder: (_, state) =>
            ApplicantsScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/employer/job/:jobId/applicants/:appId',
        builder: (_, state) => ApplicationDetailScreen(
          jobId: state.pathParameters['jobId']!,
          applicationId: state.pathParameters['appId']!,
        ),
      ),
      GoRoute(
        path: '/requests/:id',
        builder: (_, state) => ViewRequestDetailScreen(
          requestId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/employer/headhunting',
        builder: (_, _) => const HeadhuntingScreen(),
      ),
      GoRoute(
        path: '/spots',
        builder: (_, _) => const ExploringSpotsScreen(),
      ),
      GoRoute(path: '/spots/add', builder: (_, _) => const AddSpotScreen()),
      GoRoute(
        path: '/subscriptions',
        builder: (_, _) => const SubscriptionsScreen(),
      ),
      GoRoute(path: '/plans', builder: (_, _) => const PlansScreen()),
      GoRoute(
        path: '/payment',
        builder: (_, state) => PaymentScreen(
          type: state.uri.queryParameters['type'] ?? 'plan',
          itemId: state.uri.queryParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/leaderboard', builder: (_, _) => const LeaderboardScreen()),
      GoRoute(path: '/about', builder: (_, _) => const AboutAppScreen()),
    ],
  );
});

class SetupFirebaseScreen extends StatelessWidget {
  const SetupFirebaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CloseMap Setup')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase is not configured yet.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Run flutterfire configure and replace lib/firebase_options.dart. '
              'See README.md for full setup instructions (Firebase Spark, Cloudinary, EmailJS).',
            ),
          ],
        ),
      ),
    );
  }
}
