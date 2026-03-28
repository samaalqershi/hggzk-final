import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// حزمة ترجمة محلية خفيفة تحفظ النصوص الأساسية بعيدًا عن طبقات الواجهة.
/// Lightweight localization bundle that keeps common strings out of the UI layer.
class AppLocalizations {
  /// ينشئ حزمة الترجمة المرتبطة بلغة محددة ليستخدمها التطبيق في العرض.
  /// Creates the localization bundle tied to a specific language for app
  /// rendering.
  AppLocalizations(this.locale);

  /// اللغة الحالية التي تحدد النصوص والتنسيقات المناسبة.
  /// The active locale used to resolve strings and formatting.
  final Locale locale;

  /// يستخرج كائن الترجمة النشط من شجرة الواجهات الحالية.
  /// Looks up the active localization object from the current widget tree.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// مفوض يعرّف `MaterialApp` على حزمة الترجمات هذه.
  /// Delegate that exposes this localization bundle to `MaterialApp`.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// جميع المفوضين المطلوبين لغلاف البورتال وإطار Flutter.
  /// All delegates required by the portal shell and the Flutter framework.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// اللغات التي تستطيع هذه الحزمة النصية خدمتها مباشرة.
  /// Locales this embedded dictionary can serve directly.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// جدول نصوص داخل الذاكرة يُستخدم عندما لا نحتاج إلى طبقة ARB مولدة.
  /// In-memory string table used when a generated ARB layer is unnecessary.
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'hggzk portal',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'phone': 'Phone',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'search': 'Search',
      'home': 'Home',
      'favorites': 'Favorites',
      'bookings': 'Bookings',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'remove': 'Remove',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'skip': 'Skip',
      'retry': 'Retry',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',
      'noData': 'No data available',
      'noInternet': 'No internet connection',
      'somethingWentWrong': 'Something went wrong',
      'tryAgain': 'Try again',
      'pullToRefresh': 'Pull to refresh',
      'releaseToRefresh': 'Release to refresh',
      'refreshing': 'Refreshing...',
      'help_support': 'Help & Support',
      'need_help': 'Need Help?',
      'support_description': 'We are here to help you 24/7.',
      'send_message': 'Send Message',
      'your_name': 'Your Name',
      'subject': 'Subject',
      'your_message': 'Your Message',
      'send': 'Send',
      'contact_info': 'Contact Information',
      'working_hours': 'Working Hours',
      'message_sent': 'Message Sent!',
      'support_success_message': 'Thank you for contacting us.',
      'name_required': 'Name is required',
      'email_required': 'Email is required',
      'subject_required': 'Subject is required',
      'message_required': 'Message is required',
      'reference': 'Reference',
    },
    'ar': {
      'appName': 'حجزك بورتال',
      'welcome': 'مرحباً',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'phone': 'الهاتف',
      'password': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'search': 'بحث',
      'home': 'الرئيسية',
      'favorites': 'المفضلة',
      'bookings': 'الحجوزات',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'theme': 'المظهر',
      'notifications': 'الإشعارات',
      'logout': 'تسجيل الخروج',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'remove': 'إزالة',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
      'close': 'إغلاق',
      'back': 'رجوع',
      'next': 'التالي',
      'done': 'تم',
      'skip': 'تخطي',
      'retry': 'إعادة المحاولة',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'info': 'معلومة',
      'noData': 'لا توجد بيانات',
      'noInternet': 'لا يوجد اتصال بالإنترنت',
      'somethingWentWrong': 'حدث خطأ ما',
      'tryAgain': 'حاول مرة أخرى',
      'pullToRefresh': 'اسحب للتحديث',
      'releaseToRefresh': 'اترك للتحديث',
      'refreshing': 'جاري التحديث...',
      'help_support': 'الدعم والمساعدة',
      'need_help': 'هل تحتاج مساعدة؟',
      'support_description': 'نحن هنا لمساعدتك على مدار الساعة.',
      'send_message': 'إرسال رسالة',
      'your_name': 'الاسم',
      'subject': 'الموضوع',
      'your_message': 'رسالتك',
      'send': 'إرسال',
      'contact_info': 'معلومات التواصل',
      'working_hours': 'ساعات العمل',
      'message_sent': 'تم إرسال الرسالة',
      'support_success_message': 'شكرًا لتواصلك معنا.',
      'name_required': 'الاسم مطلوب',
      'email_required': 'البريد الإلكتروني مطلوب',
      'subject_required': 'الموضوع مطلوب',
      'message_required': 'الرسالة مطلوبة',
      'reference': 'رقم المرجع',
    },
  };

  /// يعيد النص المترجم أو المفتاح نفسه عندما لا توجد ترجمة مقابلة.
  /// Returns the localized string or the key itself when no translation exists.
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  /// ينسق التاريخ وفق ترتيب مناسب للغة النشطة.
  /// Formats a date using the ordering appropriate for the active locale.
  String formatDate(DateTime date) {
    return intl.DateFormat.yMd(locale.languageCode).format(date);
  }

  /// ينسق الوقت وفق النمط الزمني الذي يتوقعه المستخدم في هذه اللغة.
  /// Formats time in the standard style expected by the active locale.
  String formatTime(DateTime time) {
    return intl.DateFormat.Hm(locale.languageCode).format(time);
  }
}

/// Bridge that lets Flutter load the lightweight localization bundle synchronously.
/// جسر يتيح لـ Flutter تحميل حزمة الترجمة الخفيفة بشكل متزامن.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  /// ينشئ delegate الترجمة المستخدم لتسجيل حزمة اللغات داخل Flutter.
  /// Creates the localization delegate used to register the language bundle
  /// with Flutter.
  const _AppLocalizationsDelegate();

  @override

  /// ينشئ كائن الترجمة المتزامن مباشرة من اللغة المطلوبة دون تحميل خارجي.
  /// Builds the localization object synchronously from the requested locale
  /// without external loading.
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  /// يعيد `true` فقط للغات الموجودة ضمن القائمة المدعومة.
  /// Returns `true` only for locales included in the supported list.
  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  /// هذا المفوض ثابت، لذلك لا يحتاج إلى إعادة تحميل.
  /// This delegate is static, so reloading is never required.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
