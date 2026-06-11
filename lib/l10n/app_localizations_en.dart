// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CloseMap';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone Number';

  @override
  String get companyName => 'Company Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get jobSeeker => 'Job Seeker';

  @override
  String get employer => 'Employer';

  @override
  String get agreeTerms => 'I agree to the Terms and Conditions';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get enterOtp => 'Enter the 6-digit code sent to your email';

  @override
  String get verifyEmailInstructions =>
      'We sent a verification link to your email. Open it, then return here.';

  @override
  String get verifyEmailHint =>
      'Check your spam folder if you do not see the email within a few minutes.';

  @override
  String get emailVerifiedButton => 'I\'ve verified my email';

  @override
  String get emailNotVerifiedYet =>
      'Email not verified yet. Open the link in your inbox first.';

  @override
  String get verificationEmailSent =>
      'Verification email sent. Check your inbox.';

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get done => 'Done';

  @override
  String get home => 'Home';

  @override
  String get jobs => 'Jobs';

  @override
  String get headquarters => 'Headquarters';

  @override
  String get people => 'People';

  @override
  String get mapView => 'Map';

  @override
  String get listView => 'List';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Job title, skills, company...';

  @override
  String get currentLocation => 'Current location';

  @override
  String get noResults => 'No results found';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get applied => 'Applied';

  @override
  String get saved => 'Saved';

  @override
  String get matched => 'Matched';

  @override
  String get requests => 'Requests';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get exploringSpots => 'Exploring Spots';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Next';

  @override
  String get start => 'Start';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get pending => 'Pending';

  @override
  String get viewed => 'Viewed';

  @override
  String get rejected => 'Rejected';

  @override
  String get expired => 'Expired';

  @override
  String get active => 'Active';

  @override
  String get draft => 'Draft';

  @override
  String get all => 'All';

  @override
  String get payNow => 'Pay Now';

  @override
  String get points => 'Points';

  @override
  String get bronze => 'Bronze';

  @override
  String get silver => 'Silver';

  @override
  String get gold => 'Gold';

  @override
  String get noSubscription => 'No current subscription';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get addSpot => 'Add Spot';

  @override
  String get spotName => 'Exploring Spot Name';

  @override
  String get distance => 'Distance';

  @override
  String get add => 'Add';

  @override
  String get addJobPost => 'Add Job Post';

  @override
  String get applicants => 'Applicants';

  @override
  String get newApplicants => 'New Applicants';

  @override
  String get unlockedProfiles => 'Unlocked Profiles';

  @override
  String get rejectedProfiles => 'Rejected Profiles';

  @override
  String get matchingCandidates => 'Matching Candidates';

  @override
  String get seeAll => 'See All';

  @override
  String get publish => 'Publish';

  @override
  String get insufficientPoints => 'Insufficient points';

  @override
  String get applicationSubmitted => 'Application submitted successfully';

  @override
  String get readMore => 'Read more';

  @override
  String get today => 'Today';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get biometricLogin => 'Login with biometrics';

  @override
  String get accountLocked => 'Too many attempts. Try again in 15 minutes.';

  @override
  String get filters => 'Filters';

  @override
  String get clear => 'Clear';

  @override
  String get filter => 'Filter';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get addNewPlan => 'Add New Plan';

  @override
  String get buyPoints => 'Buy Points';

  @override
  String get confirmAction => 'Are you sure?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String kmAway(String distance) {
    return '$distance KM away';
  }

  @override
  String hoursLeft(int hours) {
    return '$hours hours left';
  }

  @override
  String get jobExpired => 'This job posting has expired';

  @override
  String get swipeToRemove => 'Swipe right to remove';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get education => 'Education';

  @override
  String get experience => 'Experience';

  @override
  String get languages => 'Languages';

  @override
  String get skills => 'Skills';

  @override
  String get resume => 'Resume';

  @override
  String get aboutCompany => 'About the Company';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get headquartersLocation => 'Headquarters Location';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalJobPosts => 'Total Job Posts';

  @override
  String get totalApplicants => 'Total Applicants';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get continueText => 'Continue';

  @override
  String get passwordResetSent => 'Password reset email sent';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateLimit =>
      'You can only update your profile once every 24 hours';

  @override
  String get setupFirebase =>
      'Firebase is not configured yet. See README.md for setup steps.';

  @override
  String get seedDemoData => 'Seed catalog (admin)';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordWeak =>
      'Password must be 8+ chars with upper, lower, number and special character';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get otpInvalid => 'Invalid verification code';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get remove => 'Remove';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get contactUnlocked => 'Contact information shared';

  @override
  String get requestDeclined => 'Request declined';

  @override
  String renewalDate(String date) {
    return 'Renewal: $date';
  }

  @override
  String get mockPaymentNote => 'Mock payment — no real charge';

  @override
  String get selectPlan => 'Select Plan';

  @override
  String get pointsStore => 'Points Store';

  @override
  String get validUntilSubscription => 'Valid until subscription expiry';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get maritalStatus => 'Marital Status';

  @override
  String get single => 'Single';

  @override
  String get married => 'Married';

  @override
  String get nationality => 'Nationality';

  @override
  String get countryOfResidence => 'Country of Residence';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get ongoing => 'Currently working here';

  @override
  String get proficiency => 'Proficiency';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get native => 'Native/Bilingual';

  @override
  String get linkedIn => 'LinkedIn Profile';

  @override
  String get otherLinks => 'Other Links';

  @override
  String get companySector => 'Company Sector';

  @override
  String get companyActivity => 'Company Activity';

  @override
  String get companySize => 'Company Size';

  @override
  String get dateEstablished => 'Date of Establishment';

  @override
  String get coverPhoto => 'Cover Photo';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get operatingHours => 'Operating Hours';

  @override
  String get servicesOffered => 'Services Offered';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get salaryRange => 'Salary Range';

  @override
  String get jobType => 'Job Type';

  @override
  String get fullTime => 'Full-Time';

  @override
  String get partTime => 'Part-Time';

  @override
  String get remote => 'Remote';

  @override
  String get onSite => 'On Site';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get validityPeriod => 'Validity Period';

  @override
  String get location => 'Location';

  @override
  String get duties => 'Duties & Responsibilities';

  @override
  String get matchingScore => 'Matching Score';

  @override
  String get unlockProfile => 'Unlock Profile';

  @override
  String get headhunting => 'Headhunting';

  @override
  String get jobPosts => 'Job Posts';

  @override
  String get sideMenu => 'Menu';

  @override
  String get emptyApplied => 'No applications yet';

  @override
  String get emptySaved => 'No saved jobs';

  @override
  String get emptyMatched => 'No matched jobs yet';

  @override
  String get emptyRequests => 'No pending requests';

  @override
  String get emptyNotifications => 'No notifications';

  @override
  String get emptySpots => 'No exploring spots defined';

  @override
  String get defineSpotHint =>
      'Define a spot to receive job match notifications';

  @override
  String get confirmApprove =>
      'Share your contact info and CV with this company?';

  @override
  String get confirmReject => 'Decline this profile view request?';

  @override
  String get lowPointsWarning => 'Your points balance is low';

  @override
  String subscriptionExpiring(int days) {
    return 'Your subscription expires in $days days';
  }

  @override
  String get pendingRequestReminder =>
      'Employers are waiting for your response on profile view requests';

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutAppBody =>
      'CloseMap connects job seekers and employers through location-based matching. Explore opportunities on the map, apply with your subscription points, and discover roles that fit where you want to work.';

  @override
  String get aboutAppBodySecondary =>
      'This app is part of the CloseMap platform. For support or partnership inquiries, reach us through the social links above.';

  @override
  String get leaderBoard => 'Leader Board';

  @override
  String get top10Companies => 'Top 10 Companies';

  @override
  String get pushNotification => 'Push Notification';

  @override
  String get emailNotification => 'Email Notification';

  @override
  String get emailOnNewMatch => 'Email on new match';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get confirmDeleteAccount =>
      'This will permanently delete your account. This action cannot be undone.';

  @override
  String get notificationsType1 => 'Notifications Type 1';

  @override
  String get notificationsType2 => 'Notifications Type 2';

  @override
  String get notificationsType3 => 'Notifications Type 3';

  @override
  String get firstPlace => 'First Place';

  @override
  String get secondPlace => 'Second Place';

  @override
  String get thirdPlace => 'Third Place';

  @override
  String nthPlace(int rank) {
    return '$rank Place';
  }

  @override
  String get successfully => 'Successfully';

  @override
  String applicationSentTo(String company) {
    return 'Your Application was sent to $company!';
  }

  @override
  String get renewSubscription => 'Renew';
}
