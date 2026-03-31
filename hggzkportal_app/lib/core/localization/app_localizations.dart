import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'locale_manager.dart';

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

  /// Lightweight async translation helper kept for client-chat compatibility.
  static Future<String> translate(
    String key, {
    required Locale locale,
    String? fallback,
    Map<String, Object?> params = const {},
  }) async {
    return AppLocalizations(locale).get(
      key,
      fallback: fallback,
      params: params,
    );
  }

  /// Synchronous translation helper used by repositories and data sources.
  static String translateSync(
    String key, {
    Locale? locale,
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    return AppLocalizations(locale ?? LocaleManager.getCurrentLocale()).get(
      key,
      fallback: fallback,
      params: params,
    );
  }

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

  static const Map<String, String> _legacyKeyAliases = {
    'app.appName': 'appName',
    'common.welcome': 'welcome',
    'common.login': 'login',
    'common.register': 'register',
    'common.email': 'email',
    'common.phone': 'phone',
    'common.password': 'password',
    'common.forgotPassword': 'forgotPassword',
    'common.search': 'search',
    'common.home': 'home',
    'common.favorites': 'favorites',
    'common.bookings': 'bookings',
    'common.profile': 'profile',
    'common.settings': 'settings',
    'common.language': 'language',
    'common.theme': 'theme',
    'common.notifications': 'notifications',
    'common.logout': 'logout',
    'common.cancel': 'cancel',
    'common.confirm': 'confirm',
    'common.save': 'save',
    'common.delete': 'delete',
    'common.edit': 'edit',
    'common.add': 'add',
    'common.remove': 'remove',
    'common.yes': 'yes',
    'common.no': 'no',
    'common.ok': 'ok',
    'common.close': 'close',
    'common.back': 'back',
    'common.next': 'next',
    'common.done': 'done',
    'common.skip': 'skip',
    'common.retry': 'retry',
    'common.loading': 'loading',
    'common.error': 'error',
    'common.success': 'success',
    'common.warning': 'warning',
    'common.info': 'info',
    'common.noData': 'noData',
    'common.noInternet': 'noInternet',
    'common.somethingWentWrong': 'somethingWentWrong',
    'common.tryAgain': 'tryAgain',
    'common.pullToRefresh': 'pullToRefresh',
    'common.releaseToRefresh': 'releaseToRefresh',
    'common.refreshing': 'refreshing',
    'support.help_support': 'help_support',
    'support.need_help': 'need_help',
    'support.support_description': 'support_description',
    'support.send_message': 'send_message',
    'support.your_name': 'your_name',
    'support.subject': 'subject',
    'support.your_message': 'your_message',
    'support.send': 'send',
    'support.contact_info': 'contact_info',
    'support.working_hours': 'working_hours',
    'support.message_sent': 'message_sent',
    'support.support_success_message': 'support_success_message',
    'support.name_required': 'name_required',
    'support.email_required': 'email_required',
    'support.subject_required': 'subject_required',
    'support.message_required': 'message_required',
    'support.reference': 'reference',
  };

  static const Map<String, String> _chatArabicFallbackValues = {
    'chat.inbox.title': 'المحادثات',
    'chat.inbox.searchHint': 'ابحث في المحادثات',
    'chat.inbox.loading': 'جاري التحميل',
    'chat.inbox.retry': 'إعادة المحاولة',
    'chat.inbox.emptyTitle': 'لا توجد محادثات',
    'chat.inbox.emptySearchTitle': 'لا توجد نتائج',
    'chat.inbox.emptySubtitle': 'ابدأ محادثة جديدة',
    'chat.inbox.emptySearchSubtitle': 'جرّب البحث بكلمات أخرى',
    'chat.inbox.startConversation': 'محادثة جديدة',
    'chat.inbox.loginPromptTitle': 'يرجى تسجيل الدخول',
    'chat.inbox.loginPromptBody': 'قم بتسجيل الدخول للوصول إلى محادثاتك',
    'chat.inbox.action.archiveAll': 'أرشفة الكل',
    'chat.inbox.action.settings': 'الإعدادات',
    'chat.inbox.action.unmute': 'إلغاء الكتم',
    'chat.inbox.action.mute': 'كتم',
    'chat.inbox.action.unarchive': 'إلغاء الأرشفة',
    'chat.inbox.action.archive': 'أرشفة',
    'chat.inbox.action.delete': 'حذف',
    'chat.inbox.action.cancel': 'إلغاء',
    'chat.inbox.deleteConversationTitle': 'حذف المحادثة',
    'chat.inbox.deleteConversationMessage': 'هل تريد حذف هذه المحادثة؟',
    'chat.inbox.typing': 'يكتب',
    'chat.inbox.typingMultiple': 'عدة أشخاص يكتبون',
    'chat.inbox.yesterday': 'أمس',
    'chat.inbox.today': 'اليوم',
    'chat.composer.image': 'صورة',
    'chat.composer.camera': 'كاميرا',
    'chat.composer.video': 'فيديو',
    'chat.composer.file': 'ملف',
    'chat.composer.location': 'موقع',
    'chat.composer.shareLocationTitle': 'إرسال موقع',
    'chat.composer.currentLocation': 'موقعي الحالي',
    'chat.composer.otherAddress': 'اختيار من الخريطة',
    'chat.composer.pickLocationOnMapTitle': 'اختيار موقع من الخريطة',
    'chat.composer.pickLocationOnMapHint':
        'حرّك الخريطة أو اضغط على الموقع الذي تريد إرساله',
    'chat.composer.tapMapToSelectLocation': 'اضغط على الخريطة لتحديد الموقع',
    'chat.composer.selectedLocation': 'الموقع المحدد',
    'chat.composer.locationAddressLoading': 'جاري تحديد العنوان...',
    'chat.composer.confirmLocation': 'إرسال هذا الموقع',
    'chat.composer.editHint': 'تعديل الرسالة...',
    'chat.composer.replyHint': 'اكتب ردك...',
    'chat.composer.messageHint': 'اكتب رسالة...',
    'chat.composer.selectedSinglePhoto': 'صورة واحدة محددة',
    'chat.composer.selectedPhotosCount': '{count} صور محددة',
    'chat.composer.selectedSingleVideo': 'فيديو واحد محدد',
    'chat.composer.selectedVideosCount': '{count} فيديوهات محددة',
    'chat.composer.preparingVideo': 'جاري الإعداد',
    'chat.composer.clearAll': 'مسح الكل',
    'chat.composer.slideToCancel': 'اسحب لليسار للإلغاء',
    'chat.composer.releaseToCancel': 'اترك للإلغاء',
    'chat.composer.microphonePermissionRequired':
        'يلزم السماح بالوصول إلى الميكروفون لإرسال رسالة صوتية',
    'chat.loader.loadingConversation': 'جاري تحميل المحادثة...',
    'chat.message.image': 'صورة',
    'chat.message.video': 'فيديو',
    'chat.message.audio': 'رسالة صوتية',
    'chat.message.document': 'مستند',
    'chat.message.location': 'موقع',
    'chat.message.edited': 'معدّل',
    'chat.message.replyTo': 'رد على رسالة',
    'chat.message.repliedContent': 'محتوى الرسالة المرد عليها',
    'chat.message.copied': 'تم النسخ',
    'chat.message.reply': 'رد',
    'chat.message.copy': 'نسخ',
    'chat.message.edit': 'تعديل',
    'chat.message.delete': 'حذف',
    'chat.message.you': 'أنت',
    'chat.message.user': 'مستخدم',
    'chat.message.placeholder': '[محتوى غير نصي]',
    'chat.message.conversationFallback': 'محادثة',
    'chat.message.deletedPlaceholder': '[رسالة محذوفة]',
    'chat.thread.loading': 'جاري تحميل الرسائل...',
    'chat.thread.start': 'ابدأ المحادثة',
    'chat.thread.firstMessageHint': 'اكتب رسالتك الأولى للبدء',
    'chat.thread.editTitle': 'تعديل الرسالة',
    'chat.thread.deleteTitle': 'حذف الرسالة',
    'chat.thread.deleteConfirm': 'هل أنت متأكد من حذف هذه الرسالة؟',
    'chat.thread.action.cancel': 'إلغاء',
    'chat.thread.action.delete': 'حذف',
    'chat.thread.adminGroup': 'إدارة التطبيق',
    'chat.thread.onlineCount': '{count} متصل',
    'chat.thread.onlineNow': 'متصل الآن',
    'chat.thread.lastSeen': 'آخر ظهور {value}',
    'chat.thread.now': 'الآن',
    'chat.thread.today': 'اليوم',
    'chat.thread.minuteAgo': 'منذ {value}د',
    'chat.thread.hourAgo': 'منذ {value}س',
    'chat.thread.dayAgo': 'منذ {value}ي',
    'chat.thread.yesterday': 'أمس',
    'chat.thread.typingSingle': '{name} يكتب',
    'chat.thread.typingDual': '{first} و{second} يكتبان',
    'chat.thread.typingMultiple': 'عدة أشخاص يكتبون',
    'chat.thread.days.sunday': 'الأحد',
    'chat.thread.days.monday': 'الإثنين',
    'chat.thread.days.tuesday': 'الثلاثاء',
    'chat.thread.days.wednesday': 'الأربعاء',
    'chat.thread.days.thursday': 'الخميس',
    'chat.thread.days.friday': 'الجمعة',
    'chat.thread.days.saturday': 'السبت',
    'chat.participant.me': 'أنت',
    'chat.participant.admin': 'مشرف',
    'chat.participant.onlineNow': 'متصل الآن',
    'chat.participant.lastSeen': 'آخر ظهور {value}',
    'chat.participant.now': 'الآن',
    'chat.participant.minuteAgo': 'منذ {value}د',
    'chat.participant.hourAgo': 'منذ {value}س',
    'chat.participant.dayAgo': 'منذ {value}ي',
    'chat.settings.title': 'معلومات المحادثة',
    'chat.settings.info.messages': 'رسائل',
    'chat.settings.info.media': 'وسائط',
    'chat.settings.info.files': 'ملفات',
    'chat.settings.info.members': 'أعضاء',
    'chat.settings.tab.media': 'الوسائط',
    'chat.settings.tab.members': 'الأعضاء',
    'chat.settings.tab.settings': 'الإعدادات',
    'chat.settings.notifications': 'الإشعارات',
    'chat.settings.notificationsEnabled': 'تفعيل الإشعارات',
    'chat.settings.notificationsSubtitle': 'تلقي إشعارات للرسائل الجديدة',
    'chat.settings.notificationSound': 'نغمة الإشعار',
    'chat.settings.soundEnabled': 'تشغيل صوت الإشعار',
    'chat.settings.soundEnabledSubtitle': 'تشغيل صوت عند وصول رسائل جديدة',
    'chat.settings.default': 'افتراضي',
    'chat.settings.privacy': 'الخصوصية',
    'chat.settings.readReceipts': 'إيصالات القراءة',
    'chat.settings.readReceiptsSubtitle':
        'السماح للآخرين بمعرفة متى قرأت رسائلهم',
    'chat.settings.typingIndicator': 'مؤشر الكتابة',
    'chat.settings.typingIndicatorSubtitle': 'إظهار حالة الكتابة في المحادثة',
    'chat.settings.appearance': 'المظهر',
    'chat.settings.chatBackground': 'خلفية المحادثة',
    'chat.settings.theme.default': 'الافتراضي',
    'chat.settings.theme.midnight': 'منتصف الليل',
    'chat.settings.theme.aurora': 'أورورا',
    'chat.settings.theme.sunset': 'الغروب',
    'chat.settings.fontSize': 'حجم الخط',
    'chat.settings.fontSizeSmall': 'صغير',
    'chat.settings.fontSizeMedium': 'متوسط',
    'chat.settings.fontSizeLarge': 'كبير',
    'chat.settings.fontSizeExtraLarge': 'كبير جداً',
    'chat.settings.storage': 'التخزين',
    'chat.settings.autoDownload': 'تنزيل الوسائط تلقائياً',
    'chat.settings.autoDownloadSubtitle':
        'تحميل معاينات الصور والفيديوهات مباشرة داخل الشات',
    'chat.settings.wifiOnly': 'عند استخدام WiFi',
    'chat.settings.clearCache': 'مسح ذاكرة التخزين المؤقت',
    'chat.settings.clearCacheSubtitle': 'حذف الملفات المؤقتة',
    'chat.settings.clearCacheConfirm':
        'سيتم حذف الرسائل والوسائط المخزنة محلياً وسيُعاد تحميلها عند الحاجة.',
    'chat.settings.clearCacheSuccess': 'تم مسح كاش الشات بنجاح',
    'chat.settings.clearCacheFailed': 'تعذر مسح كاش الشات',
    'chat.settings.updateFailed': 'فشل تحديث إعدادات الدردشة',
    'chat.settings.loading': 'جاري التحميل...',
    'chat.settings.noMediaTitle': 'لا توجد وسائط',
    'chat.settings.noMediaSubtitle': 'سيتم عرض الصور والفيديوهات هنا',
    'chat.settings.searchInChat': 'بحث في المحادثة',
    'chat.settings.searchInChatSubtitle': 'ابحث داخل رسائل هذه المحادثة',
    'chat.settings.searchInChatHint': 'اكتب كلمة أو جملة للبحث عنها',
    'chat.settings.searchInChatEmpty': 'ابدأ بالكتابة للبحث داخل المحادثة',
    'chat.settings.exportChat': 'تصدير المحادثة',
    'chat.settings.exportChatSubtitle':
        'إنشاء ملف نصي يحتوي على رسائل هذه المحادثة',
    'chat.settings.exportChatSuccess':
        'تم تصدير المحادثة، وتم نسخ المسار: {path}',
    'chat.settings.exportChatFailed': 'تعذر تصدير المحادثة',
    'chat.newConversation.creatingGroup': 'إنشاء المجموعة...',
    'chat.newConversation.startingDirect': 'بدء المحادثة...',
    'chat.newConversation.pleaseWait': 'الرجاء الانتظار لحظات',
    'chat.newConversation.groupNameRequired': 'الرجاء إدخال اسم المجموعة',
    'chat.newConversation.groupNameMin':
        'اسم المجموعة يجب أن يكون 3 أحرف على الأقل',
    'chat.newConversation.groupMembersMin':
        'يجب اختيار شخصين على الأقل للمجموعة',
    'chat.newConversation.groupMembersMax': 'الحد الأقصى للمجموعة هو 100 عضو',
    'chat.newConversation.groupDescription': 'مجموعة تضم {count} أعضاء',
    'chat.newConversation.createGroupTitle': 'إنشاء مجموعة',
    'chat.newConversation.newConversationTitle': 'محادثة جديدة',
    'chat.newConversation.selectedCount': '{count} محدد',
    'chat.newConversation.next': 'التالي',
    'chat.newConversation.groupNameHint': 'اسم المجموعة',
    'chat.newConversation.membersCount': 'الأعضاء ({count})',
    'chat.newConversation.searchHint': 'البحث عن جهات الاتصال...',
    'chat.newConversation.onlineNow': 'متصل الآن',
    'chat.newConversation.lastSeen': 'آخر ظهور {value}',
    'chat.newConversation.loadingContacts': 'جاري تحميل جهات الاتصال...',
    'chat.newConversation.noContactsTitle': 'لا توجد جهات اتصال',
    'chat.newConversation.noContactsSubtitle':
        'لم يتم العثور على جهات اتصال متاحة',
    'chat.errors.init': 'حدث خطأ في تهيئة المحادثة. يرجى المحاولة مرة أخرى.',
    'chat.errors.server': 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى.',
    'chat.errors.network':
        'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.',
    'chat.errors.auth': 'فشل التحقق من الهوية. يرجى تسجيل الدخول مرة أخرى.',
    'chat.errors.validation':
        'البيانات المدخلة غير صحيحة. تحقق وحاول مرة أخرى.',
    'chat.errors.notFound': 'المحتوى المطلوب غير موجود.',
    'chat.errors.permissionDenied': 'ليس لديك صلاحيات لتنفيذ هذا الإجراء.',
    'chat.errors.timeout': 'انتهت مهلة الاتصال. حاول مرة أخرى.',
    'chat.errors.cache': 'حدث خطأ في الذاكرة المؤقتة.',
    'chat.errors.unknown': 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.',
    'chat.errors.addressRequired': 'يرجى إدخال عنوان لإرساله',
    'chat.errors.locationAddressNotFound':
        'تعذر العثور على هذا العنوان على الخريطة',
    'chat.errors.messageSendFailed': 'فشل إرسال الرسالة',
    'chat.errors.uploadCancelled': 'تم إلغاء الرفع',
    'chat.errors.reactionAddFailed': 'فشل في إضافة التفاعل',
    'chat.errors.reactionRemoveFailed': 'فشل في إزالة التفاعل',
    'chat.system.conversationNotFound': 'المحادثة غير موجودة',
    'chat.system.createdSuccess': 'تم إنشاء المحادثة بنجاح',
  };

  /// يعيد النص المترجم أو المفتاح نفسه عندما لا توجد ترجمة مقابلة.
  /// Returns the localized string or the key itself when no translation exists.
  String get(
    String key, {
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    final normalizedKey = _legacyKeyAliases[key] ?? key;
    var value = _localizedValues[locale.languageCode]?[key] ??
        _localizedValues[locale.languageCode]?[normalizedKey] ??
        _chatArabicFallbackValues[key] ??
        _chatArabicFallbackValues[normalizedKey] ??
        fallback ??
        key;

    if (params.isEmpty) {
      return value;
    }

    params.forEach((name, replacement) {
      value = value.replaceAll('{$name}', '${replacement ?? ''}');
    });

    return value;
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

/// Convenience accessors used throughout widgets during the migration.
extension AppLocalizationsContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String tr(
    String key, {
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    return l10n.get(key, fallback: fallback, params: params);
  }
}
