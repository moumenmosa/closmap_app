import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../repositories/application_repository.dart';
import '../repositories/job_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../repositories/spot_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../services/matching_service.dart';
import '../services/notification_service.dart';
import '../services/seed_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authProvider), ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(ref.watch(firestoreProvider));
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(ref.watch(firestoreProvider));
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ref.watch(firestoreProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(firestoreProvider));
});

final spotRepositoryProvider = Provider<SpotRepository>((ref) {
  return SpotRepository(ref.watch(firestoreProvider));
});

final cloudinaryServiceProvider =
    Provider<CloudinaryService>((ref) => CloudinaryService());

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(firestoreProvider));
});

final matchingServiceProvider =
    Provider<MatchingService>((ref) => MatchingService());

final seedServiceProvider = Provider<SeedService>((ref) {
  return SeedService(ref.watch(firestoreProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authState;
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return const Stream.empty();
  return ref.watch(authServiceProvider).watchUser(auth.uid);
});

final localeProvider =
    StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier(this._prefs) : super(_prefs.getString('locale') ?? 'en');

  final SharedPreferences _prefs;

  void setLocale(String code) {
    state = code;
    _prefs.setString('locale', code);
  }
}
