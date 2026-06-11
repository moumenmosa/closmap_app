// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كلوز ماب';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get companyName => 'اسم الشركة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get jobSeeker => 'باحث عن عمل';

  @override
  String get employer => 'صاحب عمل';

  @override
  String get agreeTerms => 'أوافق على الشروط والأحكام';

  @override
  String get verifyEmail => 'تأكيد البريد';

  @override
  String get enterOtp => 'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك';

  @override
  String get verifyEmailInstructions =>
      'أرسلنا رابط تأكيد إلى بريدك. افتحه ثم عد إلى هنا.';

  @override
  String get verifyEmailHint =>
      'تحقق من مجلد الرسائل غير المرغوب فيها إذا لم يصل البريد خلال دقائق.';

  @override
  String get emailVerifiedButton => 'تم تأكيد بريدي';

  @override
  String get emailNotVerifiedYet =>
      'لم يتم تأكيد البريد بعد. افتح الرابط في بريدك أولاً.';

  @override
  String get verificationEmailSent => 'تم إرسال بريد التأكيد. تحقق من بريدك.';

  @override
  String get resendVerificationEmail => 'إعادة إرسال بريد التأكيد';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String get done => 'تم';

  @override
  String get home => 'الرئيسية';

  @override
  String get jobs => 'الوظائف';

  @override
  String get headquarters => 'المقرات';

  @override
  String get people => 'الأشخاص';

  @override
  String get mapView => 'الخريطة';

  @override
  String get listView => 'القائمة';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'المسمى الوظيفي، المهارات، الشركة...';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get applyNow => 'تقديم الآن';

  @override
  String get applied => 'المُقدَّم عليها';

  @override
  String get saved => 'المحفوظة';

  @override
  String get matched => 'المطابقة';

  @override
  String get requests => 'الطلبات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get subscriptions => 'الاشتراكات';

  @override
  String get exploringSpots => 'نقاط الاستكشاف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get next => 'التالي';

  @override
  String get start => 'ابدأ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get viewed => 'تمت المشاهدة';

  @override
  String get rejected => 'مرفوض';

  @override
  String get expired => 'منتهي';

  @override
  String get active => 'نشط';

  @override
  String get draft => 'مسودة';

  @override
  String get all => 'الكل';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get points => 'النقاط';

  @override
  String get bronze => 'برونزي';

  @override
  String get silver => 'فضي';

  @override
  String get gold => 'ذهبي';

  @override
  String get noSubscription => 'لا يوجد اشتراك حالي';

  @override
  String daysLeft(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String get addSpot => 'إضافة نقطة';

  @override
  String get spotName => 'اسم نقطة الاستكشاف';

  @override
  String get distance => 'المسافة';

  @override
  String get add => 'إضافة';

  @override
  String get addJobPost => 'إضافة وظيفة';

  @override
  String get applicants => 'المتقدمون';

  @override
  String get newApplicants => 'متقدمون جدد';

  @override
  String get unlockedProfiles => 'ملفات مفتوحة';

  @override
  String get rejectedProfiles => 'ملفات مرفوضة';

  @override
  String get matchingCandidates => 'مرشحون مطابقون';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get publish => 'نشر';

  @override
  String get insufficientPoints => 'نقاط غير كافية';

  @override
  String get applicationSubmitted => 'تم تقديم الطلب بنجاح';

  @override
  String get readMore => 'اقرأ المزيد';

  @override
  String get today => 'اليوم';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get biometricLogin => 'الدخول بالبصمة';

  @override
  String get accountLocked => 'محاولات كثيرة. حاول مرة أخرى بعد 15 دقيقة.';

  @override
  String get filters => 'الفلاتر';

  @override
  String get clear => 'مسح';

  @override
  String get filter => 'تصفية';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get addNewPlan => 'إضافة خطة';

  @override
  String get buyPoints => 'شراء نقاط';

  @override
  String get confirmAction => 'هل أنت متأكد؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String kmAway(String distance) {
    return 'على بعد $distance كم';
  }

  @override
  String hoursLeft(int hours) {
    return 'متبقي $hours ساعة';
  }

  @override
  String get jobExpired => 'انتهت صلاحية هذه الوظيفة';

  @override
  String get swipeToRemove => 'اسحب لليمين للإزالة';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get education => 'التعليم';

  @override
  String get experience => 'الخبرة';

  @override
  String get languages => 'اللغات';

  @override
  String get skills => 'المهارات';

  @override
  String get resume => 'السيرة الذاتية';

  @override
  String get aboutCompany => 'عن الشركة';

  @override
  String get uploadPhoto => 'رفع صورة';

  @override
  String get headquartersLocation => 'موقع المقر';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get totalJobPosts => 'إجمالي الوظائف';

  @override
  String get totalApplicants => 'إجمالي المتقدمين';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get continueText => 'متابعة';

  @override
  String get passwordResetSent => 'تم إرسال رابط إعادة تعيين كلمة المرور';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get profileUpdateLimit => 'يمكنك تحديث ملفك مرة واحدة كل 24 ساعة';

  @override
  String get setupFirebase => 'لم يتم إعداد Firebase بعد. راجع README.md';

  @override
  String get seedDemoData => 'إضافة الكتالوج (مسؤول)';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get errorGeneric => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get passwordWeak =>
      'كلمة المرور يجب أن تكون 8+ أحرف مع أحرف كبيرة وصغيرة ورقم ورمز خاص';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get otpInvalid => 'رمز التحقق غير صحيح';

  @override
  String get bookmark => 'حفظ';

  @override
  String get remove => 'إزالة';

  @override
  String get sendRequest => 'إرسال طلب';

  @override
  String get contactUnlocked => 'تمت مشاركة معلومات الاتصال';

  @override
  String get requestDeclined => 'تم رفض الطلب';

  @override
  String renewalDate(String date) {
    return 'التجديد: $date';
  }

  @override
  String get mockPaymentNote => 'دفع تجريبي — لا يتم خصم مبلغ حقيقي';

  @override
  String get selectPlan => 'اختر الخطة';

  @override
  String get pointsStore => 'متجر النقاط';

  @override
  String get validUntilSubscription => 'صالحة حتى انتهاء الاشتراك';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get maritalStatus => 'الحالة الاجتماعية';

  @override
  String get single => 'أعزب';

  @override
  String get married => 'متزوج';

  @override
  String get nationality => 'الجنسية';

  @override
  String get countryOfResidence => 'بلد الإقامة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get ongoing => 'أعمل هنا حالياً';

  @override
  String get proficiency => 'مستوى الإتقان';

  @override
  String get beginner => 'مبتدئ';

  @override
  String get intermediate => 'متوسط';

  @override
  String get advanced => 'متقدم';

  @override
  String get native => 'لغة أم/ثنائي اللغة';

  @override
  String get linkedIn => 'ملف LinkedIn';

  @override
  String get otherLinks => 'روابط أخرى';

  @override
  String get companySector => 'قطاع الشركة';

  @override
  String get companyActivity => 'نشاط الشركة';

  @override
  String get companySize => 'حجم الشركة';

  @override
  String get dateEstablished => 'تاريخ التأسيس';

  @override
  String get coverPhoto => 'صورة الغلاف';

  @override
  String get registrationNumber => 'رقم السجل';

  @override
  String get operatingHours => 'ساعات العمل';

  @override
  String get servicesOffered => 'الخدمات المقدمة';

  @override
  String get jobTitle => 'المسمى الوظيفي';

  @override
  String get salaryRange => 'نطاق الراتب';

  @override
  String get jobType => 'نوع الوظيفة';

  @override
  String get fullTime => 'دوام كامل';

  @override
  String get partTime => 'دوام جزئي';

  @override
  String get remote => 'عن بُعد';

  @override
  String get onSite => 'في الموقع';

  @override
  String get hybrid => 'هجين';

  @override
  String get validityPeriod => 'مدة الصلاحية';

  @override
  String get location => 'الموقع';

  @override
  String get duties => 'المهام والمسؤوليات';

  @override
  String get matchingScore => 'درجة التطابق';

  @override
  String get unlockProfile => 'فتح الملف';

  @override
  String get headhunting => 'البحث عن مواهب';

  @override
  String get jobPosts => 'الوظائف المنشورة';

  @override
  String get sideMenu => 'القائمة';

  @override
  String get emptyApplied => 'لا توجد طلبات بعد';

  @override
  String get emptySaved => 'لا توجد وظائف محفوظة';

  @override
  String get emptyMatched => 'لا توجد وظائف مطابقة';

  @override
  String get emptyRequests => 'لا توجد طلبات معلقة';

  @override
  String get emptyNotifications => 'لا توجد إشعارات';

  @override
  String get emptySpots => 'لم يتم تحديد نقاط استكشاف';

  @override
  String get defineSpotHint => 'حدد نقطة لتلقي إشعارات الوظائف المطابقة';

  @override
  String get confirmApprove =>
      'مشاركة معلومات الاتصال والسيرة الذاتية مع هذه الشركة؟';

  @override
  String get confirmReject => 'رفض طلب عرض الملف الشخصي؟';

  @override
  String get lowPointsWarning => 'رصيد النقاط منخفض';

  @override
  String subscriptionExpiring(int days) {
    return 'ينتهي اشتراكك خلال $days أيام';
  }

  @override
  String get pendingRequestReminder =>
      'أصحاب العمل ينتظرون ردك على طلبات عرض الملف';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get aboutAppBody =>
      'كلوز ماب يربط الباحثين عن عمل وأصحاب العمل من خلال المطابقة المبنية على الموقع. استكشف الفرص على الخريطة، قدّم باستخدام نقاط اشتراكك، واكتشف الوظائف التي تناسب مكان عملك.';

  @override
  String get aboutAppBodySecondary =>
      'هذا التطبيق جزء من منصة كلوز ماب. للدعم أو الشراكة، تواصل معنا عبر روابط التواصل أعلاه.';

  @override
  String get leaderBoard => 'لوحة المتصدرين';

  @override
  String get top10Companies => 'أفضل 10 شركات';

  @override
  String get pushNotification => 'إشعارات الدفع';

  @override
  String get emailNotification => 'إشعارات البريد';

  @override
  String get emailOnNewMatch => 'بريد عند تطابق جديد';

  @override
  String get deleteMyAccount => 'حذف حسابي';

  @override
  String get confirmDeleteAccount =>
      'سيتم حذف حسابك نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get notificationsType1 => 'نوع الإشعار 1';

  @override
  String get notificationsType2 => 'نوع الإشعار 2';

  @override
  String get notificationsType3 => 'نوع الإشعار 3';

  @override
  String get firstPlace => 'المركز الأول';

  @override
  String get secondPlace => 'المركز الثاني';

  @override
  String get thirdPlace => 'المركز الثالث';

  @override
  String nthPlace(int rank) {
    return 'المركز $rank';
  }

  @override
  String get successfully => 'تم بنجاح';

  @override
  String applicationSentTo(String company) {
    return 'تم إرسال طلبك إلى $company!';
  }

  @override
  String get renewSubscription => 'تجديد';
}
