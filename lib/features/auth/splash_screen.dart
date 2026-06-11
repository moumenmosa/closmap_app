import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/app_button.dart';
import '../../firebase_options.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    if (DefaultFirebaseOptions.isPlaceholder) {
      context.go('/setup');
      return;
    }
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      final seenWelcome =
          ref.read(sharedPrefsProvider).getBool('seen_welcome') ?? false;
      context.go(seenWelcome ? '/login' : '/welcome');
      return;
    }
    final appUser = ref.read(currentUserProvider).valueOrNull;
    if (appUser == null) {
      context.go('/login');
      return;
    }
    if (!appUser.emailVerified) {
      context.go('/otp');
      return;
    }
    if (appUser.role == UserRole.admin) {
      context.go('/admin/home');
      return;
    }
    if (!appUser.profileCompleted) {
      context.go(appUser.role == UserRole.employer
          ? '/employer/profile'
          : '/seeker/profile-wizard');
      return;
    }
    context.go(appUser.role == UserRole.employer
        ? '/employer/home'
        : '/seeker/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogoHeader(size: 160, showTitle: false),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
