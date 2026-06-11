import 'design_assets.dart';

/// Maps a Figma export to its route, Dart file, and parity status.
class DesignScreenEntry {
  const DesignScreenEntry({
    required this.name,
    required this.asset,
    required this.file,
    this.route,
    this.implemented = false,
    this.notes,
  });

  final String name;
  final String asset;
  final String? route;
  final String file;
  final bool implemented;
  final String? notes;
}

/// Verification matrix for Figma design parity.
class DesignScreenMap {
  DesignScreenMap._();

  static final List<DesignScreenEntry> entries = [
    // Auth & onboarding
    DesignScreenEntry(
      name: 'Welcome',
      asset: DesignAssets.welcome,
      route: '/welcome',
      file: 'lib/features/auth/welcome_screen.dart',
    ),
    DesignScreenEntry(
      name: 'Onboarding',
      asset: DesignAssets.onboarding,
      route: '/welcome',
      file: 'lib/features/auth/welcome_screen.dart',
    ),
    DesignScreenEntry(
      name: 'Login',
      asset: DesignAssets.login,
      route: '/login',
      file: 'lib/features/auth/login_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Job Seeker Register',
      asset: DesignAssets.jobSeekerRegister,
      route: '/register',
      file: 'lib/features/auth/register_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Employer Register',
      asset: DesignAssets.employerRegister,
      route: '/register',
      file: 'lib/features/auth/register_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Verify Account',
      asset: DesignAssets.verifyAccount,
      route: '/otp',
      file: 'lib/features/auth/otp_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Forgot Password',
      asset: DesignAssets.forgotPassword,
      route: '/forgot-password',
      file: 'lib/features/auth/forgot_password_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),

    // Seeker profile wizard
    DesignScreenEntry(
      name: 'Complete Registration',
      asset: DesignAssets.completeRegistration,
      route: '/seeker/profile-wizard',
      file: 'lib/features/seeker_profile/seeker_profile_wizard.dart',
      implemented: true,
      notes: 'Functional; field/layout parity pending',
    ),
    DesignScreenEntry(
      name: 'Add Education',
      asset: DesignAssets.addEducation,
      file: 'lib/features/seeker_profile/seeker_profile_wizard.dart',
      implemented: true,
      notes: 'Dialog stub; full sheet pending',
    ),
    DesignScreenEntry(
      name: 'Add Experience',
      asset: DesignAssets.addExperience,
      file: 'lib/features/seeker_profile/seeker_profile_wizard.dart',
      implemented: true,
      notes: 'Dialog stub; full sheet pending',
    ),
    DesignScreenEntry(
      name: 'Add Languages',
      asset: DesignAssets.addLanguages,
      file: 'lib/features/seeker_profile/seeker_profile_wizard.dart',
      implemented: true,
      notes: 'Dialog stub; full sheet pending',
    ),
    DesignScreenEntry(
      name: 'Add Skills',
      asset: DesignAssets.addSkills,
      file: 'lib/features/seeker_profile/seeker_profile_wizard.dart',
      implemented: true,
      notes: 'Dialog stub; full sheet pending',
    ),
    DesignScreenEntry(
      name: 'My Profile',
      asset: DesignAssets.myProfile,
      route: '/seeker/profile',
      file: 'lib/features/seeker_profile/seeker_profile_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),

    // Picker sheets
    DesignScreenEntry(
      name: 'Gender Type Picker',
      asset: DesignAssets.genderType,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Job Title Picker',
      asset: DesignAssets.jobTitle,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Job Type Picker',
      asset: DesignAssets.jobType,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Salary Picker',
      asset: DesignAssets.salary,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Experience Level Picker',
      asset: DesignAssets.experienceLevel,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Field of Education Picker',
      asset: DesignAssets.fieldOfEducation,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Level of Education Picker',
      asset: DesignAssets.levelOfEducation,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Remote Picker',
      asset: DesignAssets.remote,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Skill Picker',
      asset: DesignAssets.skill,
      file: 'lib/core/widgets/design/design_picker_sheet.dart',
      notes: 'Bottom sheet, not a route',
    ),

    // Employer profile & company
    DesignScreenEntry(
      name: 'Employer Registration',
      asset: DesignAssets.completeRegistrationVariants[2],
      route: '/employer/profile',
      file: 'lib/features/employer_profile/employer_profile_screen.dart',
      implemented: true,
      notes: 'Single form; wizard parity pending',
    ),
    DesignScreenEntry(
      name: 'Legal Documents',
      asset: DesignAssets.legal,
      route: '/employer/profile',
      file: 'lib/features/employer_profile/employer_profile_screen.dart',
      implemented: true,
      notes: 'Wizard step pending',
    ),
    DesignScreenEntry(
      name: 'Company Profile',
      asset: DesignAssets.companyProfile,
      route: '/company/:id',
      file: 'lib/features/jobs/company_profile_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),

    // Jobs
    DesignScreenEntry(
      name: 'Add Post',
      asset: DesignAssets.addPost,
      route: '/employer/job/add',
      file: 'lib/features/employer_jobs/add_job_screen.dart',
      implemented: true,
      notes: '6 fields; 15-field parity pending',
    ),
    DesignScreenEntry(
      name: 'Job Details',
      asset: DesignAssets.jobDetails,
      route: '/job/:id',
      file: 'lib/features/jobs/job_details_screen.dart',
      implemented: true,
      notes: 'Functional; hero/sections pending',
    ),
    DesignScreenEntry(
      name: 'Job Details Applicants',
      asset: DesignAssets.jobDetailsApplicants,
      route: '/employer/job/:id/applicants',
      file: 'lib/features/employer_jobs/applicants_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Job Details Statistics',
      asset: DesignAssets.jobDetailsStatistics,
      route: '/job/:id',
      file: 'lib/features/jobs/job_details_screen.dart',
      notes: 'Employer tab variant pending',
    ),
    DesignScreenEntry(
      name: 'Job Details Saved',
      asset: DesignAssets.jobDetailsSaved,
      route: '/job/:id',
      file: 'lib/features/jobs/job_details_screen.dart',
      notes: 'Seeker saved state pending',
    ),
    DesignScreenEntry(
      name: 'Job Details Submitted',
      asset: DesignAssets.jobDetailsSubmitted,
      route: '/job/:id',
      file: 'lib/features/jobs/job_details_screen.dart',
      notes: 'Seeker submitted state pending',
    ),
    DesignScreenEntry(
      name: 'Successfully Apply',
      asset: DesignAssets.successfullyApply,
      route: '/applications',
      file: 'lib/features/applications/applications_screen.dart',
      implemented: true,
      notes: 'Success modal pending',
    ),

    // Home, map, search
    DesignScreenEntry(
      name: 'Map Home',
      asset: DesignAssets.map,
      route: '/seeker/home',
      file: 'lib/features/home/seeker_home_screen.dart',
      implemented: true,
      notes: 'Map-first layout pending',
    ),
    DesignScreenEntry(
      name: 'Employer Map Home',
      asset: DesignAssets.maps,
      route: '/employer/home',
      file: 'lib/features/home/employer_home_screen.dart',
      implemented: true,
      notes: 'Map-first layout pending',
    ),
    DesignScreenEntry(
      name: 'Search',
      asset: DesignAssets.search,
      route: '/search',
      file: 'lib/features/search/search_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Filter',
      asset: DesignAssets.filter,
      route: '/search/filter',
      file: 'lib/features/search/filter_screen.dart',
      notes: 'Screen not created yet',
    ),

    // Applications & spots
    DesignScreenEntry(
      name: 'Applications',
      asset: DesignAssets.applications,
      route: '/applications',
      file: 'lib/features/applications/applications_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Exploring Spots',
      asset: DesignAssets.exploringSpot,
      route: '/spots',
      file: 'lib/features/spots/exploring_spots_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Add Spot',
      asset: DesignAssets.exploringSpotAlt,
      route: '/spots/add',
      file: 'lib/features/spots/add_spot_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),

    // Subscriptions & payments
    DesignScreenEntry(
      name: 'My Subscription',
      asset: DesignAssets.mySubscription,
      route: '/subscriptions',
      file: 'lib/features/subscriptions/subscriptions_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Select Plan',
      asset: DesignAssets.selectPlan,
      route: '/plans',
      file: 'lib/features/subscriptions/plans_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Points Store',
      asset: DesignAssets.point,
      route: '/subscriptions',
      file: 'lib/features/subscriptions/subscriptions_screen.dart',
      implemented: true,
      notes: 'Points tab layout pending',
    ),
    DesignScreenEntry(
      name: 'Payment Methods',
      asset: DesignAssets.paymentMethods,
      route: '/payment',
      file: 'lib/features/subscriptions/payment_screen.dart',
      implemented: true,
      notes: 'Functional; visual parity pending',
    ),
    DesignScreenEntry(
      name: 'Add New Card',
      asset: DesignAssets.addNewCard,
      route: '/payment',
      file: 'lib/features/subscriptions/payment_screen.dart',
      notes: 'Add-card sheet pending',
    ),
    DesignScreenEntry(
      name: 'Expiration Date',
      asset: DesignAssets.expirationDate,
      file: 'lib/features/subscriptions/payment_screen.dart',
      notes: 'Payment sub-sheet, not a route',
    ),
    DesignScreenEntry(
      name: 'Security Code',
      asset: DesignAssets.securityCode,
      file: 'lib/features/subscriptions/payment_screen.dart',
      notes: 'Payment sub-sheet, not a route',
    ),

    // New features (Phase 8)
    DesignScreenEntry(
      name: 'Settings',
      asset: DesignAssets.settings,
      route: '/settings',
      file: 'lib/features/settings/settings_screen.dart',
      notes: 'Screen not created yet',
    ),
    DesignScreenEntry(
      name: 'Leader Board',
      asset: DesignAssets.leaderBoard,
      route: '/leaderboard',
      file: 'lib/features/leaderboard/leaderboard_screen.dart',
      notes: 'Screen not created yet',
    ),
    DesignScreenEntry(
      name: 'About App',
      asset: DesignAssets.aboutApp,
      route: '/about',
      file: 'lib/features/settings/about_app_screen.dart',
      notes: 'Screen not created yet',
    ),

    // Other routed screens
    DesignScreenEntry(
      name: 'Notifications',
      asset: DesignAssets.profile,
      route: '/notifications',
      file: 'lib/features/notifications/notifications_screen.dart',
      implemented: true,
      notes: 'No dedicated Figma export',
    ),
    DesignScreenEntry(
      name: 'Headhunting',
      asset: DesignAssets.searchAlt1,
      route: '/employer/headhunting',
      file: 'lib/features/employer_jobs/headhunting_screen.dart',
      implemented: true,
      notes: 'No dedicated Figma export',
    ),
    DesignScreenEntry(
      name: 'Posted Jobs',
      asset: DesignAssets.jobDetailsAlt,
      route: '/employer/jobs',
      file: 'lib/features/employer_jobs/posted_jobs_screen.dart',
      implemented: true,
      notes: 'No dedicated Figma export',
    ),
    DesignScreenEntry(
      name: 'Seeker Preview',
      asset: DesignAssets.myProfile,
      route: '/employer/headhunting',
      file: 'lib/features/employer_jobs/seeker_preview_screen.dart',
      implemented: true,
      notes: 'Employer view of seeker profile',
    ),
  ];

  static List<DesignScreenEntry> get implemented =>
      entries.where((e) => e.implemented).toList();

  static List<DesignScreenEntry> get pending =>
      entries.where((e) => !e.implemented).toList();

  static DesignScreenEntry? byAsset(String asset) {
    for (final entry in entries) {
      if (entry.asset == asset) return entry;
    }
    return null;
  }

  static DesignScreenEntry? byRoute(String route) {
    for (final entry in entries) {
      if (entry.route == route) return entry;
    }
    return null;
  }
}
