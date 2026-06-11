/// Central configuration for third-party services.

class AppConfig {

  AppConfig._();



  // ---------------- Cloudinary ----------------

  static const String cloudinaryCloudName = 'ddoknf9ir';

  static const String cloudinaryUploadPreset = 'closemap_unsigned';



  static bool get cloudinaryConfigured =>

      cloudinaryCloudName.isNotEmpty &&

      cloudinaryUploadPreset.isNotEmpty;



  // ---------------- Business constants ----------------

  static const int otpResendSeconds = 60;



  static const int maxLoginAttempts = 5;

  static const int loginLockoutMinutes = 15;



  static const int subscriptionDays = 30;

  static const int expiryReminderDays = 2;

  static const int lowPointsThreshold = 3;



  static const double minSpotRadiusKm = 1;

  static const double maxSpotRadiusKm = 15;

  static const double defaultSpotRadiusKm = 5;

  static const int spotNameMaxLength = 40;



  static const int maxResumeSizeMb = 10;

  static const int maxImageSizeMb = 5;



  static const int viewRequestCooldownDays = 7;

}

