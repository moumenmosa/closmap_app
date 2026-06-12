import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/auth_routing.dart';
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
    final authUser = ref.read(authStateProvider);
    if (authUser.isLoading) {
      Future.delayed(const Duration(milliseconds: 400), _navigate);
      return;
    }
    final firebaseUser = authUser.valueOrNull;
    if (firebaseUser == null) {
      final seenWelcome =
          ref.read(sharedPrefsProvider).getBool('seen_welcome') ?? false;
      context.go(seenWelcome ? '/login' : '/welcome');
      return;
    }
    final appUserState = ref.read(currentUserProvider);
    if (appUserState.isLoading) {
      Future.delayed(const Duration(milliseconds: 400), _navigate);
      return;
    }
    final appUser = appUserState.valueOrNull;
    if (appUser == null) {
      context.go('/login');
      return;
    }
    if (!appUser.emailVerified) {
      context.go('/otp');
      return;
    }
    context.go(homeRouteForUser(appUser));
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
