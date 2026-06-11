import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CloseMap'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @jobSeeker.
  ///
  /// In en, this message translates to:
  /// **'Job Seeker'**
  String get jobSeeker;

  /// No description provided for @employer.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employer;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get agreeTerms;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get enterOtp;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email. Open it, then return here.'**
  String get verifyEmailInstructions;

  /// No description provided for @verifyEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder if you do not see the email within a few minutes.'**
  String get verifyEmailHint;

  /// No description provided for @emailVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get emailVerifiedButton;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Open the link in your inbox first.'**
  String get emailNotVerifiedYet;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @headquarters.
  ///
  /// In en, this message translates to:
  /// **'Headquarters'**
  String get headquarters;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Job title, skills, company...'**
  String get searchHint;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get matched;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @exploringSpots.
  ///
  /// In en, this message translates to:
  /// **'Exploring Spots'**
  String get exploringSpots;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @viewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get viewed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'No current subscription'**
  String get noSubscription;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @addSpot.
  ///
  /// In en, this message translates to:
  /// **'Add Spot'**
  String get addSpot;

  /// No description provided for @spotName.
  ///
  /// In en, this message translates to:
  /// **'Exploring Spot Name'**
  String get spotName;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addJobPost.
  ///
  /// In en, this message translates to:
  /// **'Add Job Post'**
  String get addJobPost;

  /// No description provided for @applicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants;

  /// No description provided for @newApplicants.
  ///
  /// In en, this message translates to:
  /// **'New Applicants'**
  String get newApplicants;

  /// No description provided for @unlockedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Unlocked Profiles'**
  String get unlockedProfiles;

  /// No description provided for @rejectedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Rejected Profiles'**
  String get rejectedProfiles;

  /// No description provided for @matchingCandidates.
  ///
  /// In en, this message translates to:
  /// **'Matching Candidates'**
  String get matchingCandidates;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @insufficientPoints.
  ///
  /// In en, this message translates to:
  /// **'Insufficient points'**
  String get insufficientPoints;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully'**
  String get applicationSubmitted;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Login with biometrics'**
  String get biometricLogin;

  /// No description provided for @accountLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in 15 minutes.'**
  String get accountLocked;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @addNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Add New Plan'**
  String get addNewPlan;

  /// No description provided for @buyPoints.
  ///
  /// In en, this message translates to:
  /// **'Buy Points'**
  String get buyPoints;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get confirmAction;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} KM away'**
  String kmAway(String distance);

  /// No description provided for @hoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours left'**
  String hoursLeft(int hours);

  /// No description provided for @jobExpired.
  ///
  /// In en, this message translates to:
  /// **'This job posting has expired'**
  String get jobExpired;

  /// No description provided for @swipeToRemove.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to remove'**
  String get swipeToRemove;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @aboutCompany.
  ///
  /// In en, this message translates to:
  /// **'About the Company'**
  String get aboutCompany;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @headquartersLocation.
  ///
  /// In en, this message translates to:
  /// **'Headquarters Location'**
  String get headquartersLocation;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @totalJobPosts.
  ///
  /// In en, this message translates to:
  /// **'Total Job Posts'**
  String get totalJobPosts;

  /// No description provided for @totalApplicants.
  ///
  /// In en, this message translates to:
  /// **'Total Applicants'**
  String get totalApplicants;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetSent;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @profileUpdateLimit.
  ///
  /// In en, this message translates to:
  /// **'You can only update your profile once every 24 hours'**
  String get profileUpdateLimit;

  /// No description provided for @setupFirebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured yet. See README.md for setup steps.'**
  String get setupFirebase;

  /// No description provided for @seedDemoData.
  ///
  /// In en, this message translates to:
  /// **'Seed catalog (admin)'**
  String get seedDemoData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8+ chars with upper, lower, number and special character'**
  String get passwordWeak;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get otpInvalid;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @contactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Contact information shared'**
  String get contactUnlocked;

  /// No description provided for @requestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// No description provided for @renewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renewal: {date}'**
  String renewalDate(String date);

  /// No description provided for @mockPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Mock payment — no real charge'**
  String get mockPaymentNote;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// No description provided for @pointsStore.
  ///
  /// In en, this message translates to:
  /// **'Points Store'**
  String get pointsStore;

  /// No description provided for @validUntilSubscription.
  ///
  /// In en, this message translates to:
  /// **'Valid until subscription expiry'**
  String get validUntilSubscription;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatus;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @married.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get married;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @countryOfResidence.
  ///
  /// In en, this message translates to:
  /// **'Country of Residence'**
  String get countryOfResidence;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Currently working here'**
  String get ongoing;

  /// No description provided for @proficiency.
  ///
  /// In en, this message translates to:
  /// **'Proficiency'**
  String get proficiency;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @native.
  ///
  /// In en, this message translates to:
  /// **'Native/Bilingual'**
  String get native;

  /// No description provided for @linkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn Profile'**
  String get linkedIn;

  /// No description provided for @otherLinks.
  ///
  /// In en, this message translates to:
  /// **'Other Links'**
  String get otherLinks;

  /// No description provided for @companySector.
  ///
  /// In en, this message translates to:
  /// **'Company Sector'**
  String get companySector;

  /// No description provided for @companyActivity.
  ///
  /// In en, this message translates to:
  /// **'Company Activity'**
  String get companyActivity;

  /// No description provided for @companySize.
  ///
  /// In en, this message translates to:
  /// **'Company Size'**
  String get companySize;

  /// No description provided for @dateEstablished.
  ///
  /// In en, this message translates to:
  /// **'Date of Establishment'**
  String get dateEstablished;

  /// No description provided for @coverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Cover Photo'**
  String get coverPhoto;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @operatingHours.
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get operatingHours;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @salaryRange.
  ///
  /// In en, this message translates to:
  /// **'Salary Range'**
  String get salaryRange;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-Time'**
  String get fullTime;

  /// No description provided for @partTime.
  ///
  /// In en, this message translates to:
  /// **'Part-Time'**
  String get partTime;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @onSite.
  ///
  /// In en, this message translates to:
  /// **'On Site'**
  String get onSite;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @validityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Validity Period'**
  String get validityPeriod;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @duties.
  ///
  /// In en, this message translates to:
  /// **'Duties & Responsibilities'**
  String get duties;

  /// No description provided for @matchingScore.
  ///
  /// In en, this message translates to:
  /// **'Matching Score'**
  String get matchingScore;

  /// No description provided for @unlockProfile.
  ///
  /// In en, this message translates to:
  /// **'Unlock Profile'**
  String get unlockProfile;

  /// No description provided for @headhunting.
  ///
  /// In en, this message translates to:
  /// **'Headhunting'**
  String get headhunting;

  /// No description provided for @jobPosts.
  ///
  /// In en, this message translates to:
  /// **'Job Posts'**
  String get jobPosts;

  /// No description provided for @sideMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get sideMenu;

  /// No description provided for @emptyApplied.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get emptyApplied;

  /// No description provided for @emptySaved.
  ///
  /// In en, this message translates to:
  /// **'No saved jobs'**
  String get emptySaved;

  /// No description provided for @emptyMatched.
  ///
  /// In en, this message translates to:
  /// **'No matched jobs yet'**
  String get emptyMatched;

  /// No description provided for @emptyRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get emptyRequests;

  /// No description provided for @emptyNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get emptyNotifications;

  /// No description provided for @emptySpots.
  ///
  /// In en, this message translates to:
  /// **'No exploring spots defined'**
  String get emptySpots;

  /// No description provided for @defineSpotHint.
  ///
  /// In en, this message translates to:
  /// **'Define a spot to receive job match notifications'**
  String get defineSpotHint;

  /// No description provided for @confirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Share your contact info and CV with this company?'**
  String get confirmApprove;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Decline this profile view request?'**
  String get confirmReject;

  /// No description provided for @lowPointsWarning.
  ///
  /// In en, this message translates to:
  /// **'Your points balance is low'**
  String get lowPointsWarning;

  /// No description provided for @subscriptionExpiring.
  ///
  /// In en, this message translates to:
  /// **'Your subscription expires in {days} days'**
  String subscriptionExpiring(int days);

  /// No description provided for @pendingRequestReminder.
  ///
  /// In en, this message translates to:
  /// **'Employers are waiting for your response on profile view requests'**
  String get pendingRequestReminder;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutAppBody.
  ///
  /// In en, this message translates to:
  /// **'CloseMap connects job seekers and employers through location-based matching. Explore opportunities on the map, apply with your subscription points, and discover roles that fit where you want to work.'**
  String get aboutAppBody;

  /// No description provided for @aboutAppBodySecondary.
  ///
  /// In en, this message translates to:
  /// **'This app is part of the CloseMap platform. For support or partnership inquiries, reach us through the social links above.'**
  String get aboutAppBodySecondary;

  /// No description provided for @leaderBoard.
  ///
  /// In en, this message translates to:
  /// **'Leader Board'**
  String get leaderBoard;

  /// No description provided for @top10Companies.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Companies'**
  String get top10Companies;

  /// No description provided for @pushNotification.
  ///
  /// In en, this message translates to:
  /// **'Push Notification'**
  String get pushNotification;

  /// No description provided for @emailNotification.
  ///
  /// In en, this message translates to:
  /// **'Email Notification'**
  String get emailNotification;

  /// No description provided for @emailOnNewMatch.
  ///
  /// In en, this message translates to:
  /// **'Email on new match'**
  String get emailOnNewMatch;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account. This action cannot be undone.'**
  String get confirmDeleteAccount;

  /// No description provided for @notificationsType1.
  ///
  /// In en, this message translates to:
  /// **'Notifications Type 1'**
  String get notificationsType1;

  /// No description provided for @notificationsType2.
  ///
  /// In en, this message translates to:
  /// **'Notifications Type 2'**
  String get notificationsType2;

  /// No description provided for @notificationsType3.
  ///
  /// In en, this message translates to:
  /// **'Notifications Type 3'**
  String get notificationsType3;

  /// No description provided for @firstPlace.
  ///
  /// In en, this message translates to:
  /// **'First Place'**
  String get firstPlace;

  /// No description provided for @secondPlace.
  ///
  /// In en, this message translates to:
  /// **'Second Place'**
  String get secondPlace;

  /// No description provided for @thirdPlace.
  ///
  /// In en, this message translates to:
  /// **'Third Place'**
  String get thirdPlace;

  /// No description provided for @nthPlace.
  ///
  /// In en, this message translates to:
  /// **'{rank} Place'**
  String nthPlace(int rank);

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully'**
  String get successfully;

  /// No description provided for @applicationSentTo.
  ///
  /// In en, this message translates to:
  /// **'Your Application was sent to {company}!'**
  String applicationSentTo(String company);

  /// No description provided for @renewSubscription.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renewSubscription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
