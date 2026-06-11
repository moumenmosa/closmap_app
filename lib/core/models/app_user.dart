import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_prefs.dart';

enum UserRole { seeker, employer, admin }

enum SubscriptionTier { none, bronze, silver, gold }

extension SubscriptionTierX on SubscriptionTier {
  String get id => name;

  /// Geographic application/posting scope.
  bool get isGlobal => this == SubscriptionTier.gold;

  /// Max exploring spots a seeker may define.
  int get maxExploringSpots {
    switch (this) {
      case SubscriptionTier.bronze:
        return 1;
      case SubscriptionTier.silver:
        return 3;
      case SubscriptionTier.gold:
        return 5;
      case SubscriptionTier.none:
        return 0;
    }
  }
}

class AppUser {
  final String uid;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String companyName;
  final String email;
  final String phone;
  final bool emailVerified;
  final bool profileCompleted;
  final String language;
  final int points;
  final SubscriptionTier tier;
  final DateTime? subscriptionExpiry;
  final String latestJobTitle;
  final DateTime createdAt;
  final DateTime? lastProfileUpdate;
  final NotificationPrefs notificationPrefs;

  const AppUser({
    required this.uid,
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.companyName = '',
    required this.email,
    this.phone = '',
    this.emailVerified = false,
    this.profileCompleted = false,
    this.language = 'en',
    this.points = 0,
    this.tier = SubscriptionTier.none,
    this.subscriptionExpiry,
    this.latestJobTitle = '',
    required this.createdAt,
    this.lastProfileUpdate,
    this.notificationPrefs = const NotificationPrefs(),
  });

  String get displayName {
    if (role == UserRole.employer) return companyName;
    if (role == UserRole.admin) {
      final name = '$firstName $lastName'.trim();
      return name.isEmpty ? 'Admin' : name;
    }
    return '$firstName $lastName'.trim();
  }

  bool get isAdmin => role == UserRole.admin;

  bool get hasActiveSubscription =>
      tier != SubscriptionTier.none &&
      subscriptionExpiry != null &&
      subscriptionExpiry!.isAfter(DateTime.now());

  SubscriptionTier get activeTier =>
      hasActiveSubscription ? tier : SubscriptionTier.none;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      role: _roleFromString(d['role'] as String?),
      firstName: d['firstName'] ?? '',
      lastName: d['lastName'] ?? '',
      companyName: d['companyName'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      emailVerified: d['emailVerified'] ?? false,
      profileCompleted: d['profileCompleted'] ?? false,
      language: d['language'] ?? 'en',
      points: (d['points'] ?? 0) as int,
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == (d['tier'] ?? 'none'),
        orElse: () => SubscriptionTier.none,
      ),
      subscriptionExpiry: (d['subscriptionExpiry'] as Timestamp?)?.toDate(),
      latestJobTitle: d['latestJobTitle'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastProfileUpdate: (d['lastProfileUpdate'] as Timestamp?)?.toDate(),
      notificationPrefs: NotificationPrefs.fromMap(
        d['notificationPrefs'] as Map<String, dynamic>?,
      ),
    );
  }

  static UserRole _roleFromString(String? role) {
    switch (role) {
      case 'employer':
        return UserRole.employer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.seeker;
    }
  }

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'firstName': firstName,
        'lastName': lastName,
        'companyName': companyName,
        'email': email,
        'phone': phone,
        'emailVerified': emailVerified,
        'profileCompleted': profileCompleted,
        'language': language,
        'points': points,
        'tier': tier.name,
        'subscriptionExpiry': subscriptionExpiry != null
            ? Timestamp.fromDate(subscriptionExpiry!)
            : null,
        'latestJobTitle': latestJobTitle,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastProfileUpdate': lastProfileUpdate != null
            ? Timestamp.fromDate(lastProfileUpdate!)
            : null,
      };
}
