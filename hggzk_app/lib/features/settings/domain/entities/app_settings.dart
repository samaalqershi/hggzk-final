import 'package:equatable/equatable.dart';

/// يمثل إعدادات التطبيق العامة التي تتحكم في اللغة والثيم والعملة
/// والتفضيلات الأخرى للمستخدم.
/// Represents the application's general settings that control language, theme,
/// currency, and other user preferences.
class AppSettings extends Equatable {
  /// اللغة الأساسية التي يعتمدها التطبيق في النصوص والواجهة.
  /// Primary language the application uses for localized content and UI text.
  final String preferredLanguage;

  /// العملة الافتراضية المستخدمة لعرض الأسعار والقيم المالية.
  /// Default currency used when presenting prices and monetary values.
  final String preferredCurrency;

  /// المنطقة الزمنية المرجعية المستخدمة في عرض الأوقات والتواريخ.
  /// Reference time zone used when showing times and dates.
  final String timeZone;

  /// يحدد ما إذا كان التطبيق يعمل بالمظهر الداكن.
  /// Indicates whether the application is using the dark theme.
  final bool darkMode;

  /// يحدد ما إذا كان تسجيل الدخول أو التحقق البيومتري مفعّلًا.
  /// Indicates whether biometric authentication is enabled.
  final bool biometricEnabled;

  /// مجموعة تفضيلات الإشعارات التفصيلية المرتبطة بالمستخدم.
  /// Detailed notification preferences associated with the current user.
  final NotificationSettings notificationSettings;

  /// مساحة مرنة لحفظ إعدادات إضافية لا تستحق حقولًا صريحة بعد.
  /// Flexible storage for extra settings that do not yet justify dedicated
  /// fields.
  final Map<String, dynamic> additionalSettings;

  /// آخر وقت معروف تم فيه تحديث الإعدادات أو مزامنتها.
  /// Last known time when the settings were updated or synchronized.
  final DateTime? lastUpdated;

  /// ينشئ حزمة إعدادات كاملة بالقيم الافتراضية أو بالقيم المحفوظة.
  /// Creates a full settings snapshot using either defaults or persisted
  /// values.
  const AppSettings({
    this.preferredLanguage = 'ar',
    this.preferredCurrency = 'YER',
    this.timeZone = 'Asia/Aden',
    this.darkMode = false,
    this.biometricEnabled = false,
    this.notificationSettings = const NotificationSettings(),
    this.additionalSettings = const {},
    this.lastUpdated,
  });

  /// يعيد نسخة جديدة من الإعدادات مع استبدال الحقول المطلوبة فقط.
  /// Returns a new settings object while replacing only the requested fields.
  AppSettings copyWith({
    String? preferredLanguage,
    String? preferredCurrency,
    String? timeZone,
    bool? darkMode,
    bool? biometricEnabled,
    NotificationSettings? notificationSettings,
    Map<String, dynamic>? additionalSettings,
    DateTime? lastUpdated,
  }) {
    return AppSettings(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      timeZone: timeZone ?? this.timeZone,
      darkMode: darkMode ?? this.darkMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      additionalSettings: additionalSettings ?? this.additionalSettings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// يعيد الحقول التي يعتمد عليها `Equatable` عند مقارنة نسخ الإعدادات.
  /// Returns the fields that `Equatable` uses when comparing settings
  /// instances.
  @override
  List<Object?> get props => [
        preferredLanguage,
        preferredCurrency,
        timeZone,
        darkMode,
        biometricEnabled,
        notificationSettings,
        additionalSettings,
        lastUpdated,
      ];
}

/// يمثل مجموعة تفضيلات الإشعارات المضمنة داخل إعدادات التطبيق.
/// Represents the notification-preferences group nested inside app settings.
class NotificationSettings extends Equatable {
  /// يحدد ما إذا كانت إشعارات الحجوزات مسموحًا بها.
  /// Indicates whether booking notifications are enabled.
  final bool bookingNotifications;

  /// يحدد ما إذا كانت الإشعارات الترويجية مسموحًا بها.
  /// Indicates whether promotional notifications are enabled.
  final bool promotionalNotifications;

  /// يحدد ما إذا كانت الإشعارات عبر البريد الإلكتروني مفعلة.
  /// Indicates whether email notifications are enabled.
  final bool emailNotifications;

  /// يحدد ما إذا كانت الإشعارات النصية القصيرة مفعلة.
  /// Indicates whether SMS notifications are enabled.
  final bool smsNotifications;

  /// يحدد ما إذا كانت الإشعارات الفورية داخل الجهاز مفعلة.
  /// Indicates whether push notifications are enabled.
  final bool pushNotifications;

  /// يحدد ما إذا كان التطبيق يشغّل صوتًا عند وصول الإشعار.
  /// Indicates whether the application should play a sound for notifications.
  final bool soundEnabled;

  /// يحدد ما إذا كان التطبيق يهتز عند وصول الإشعار.
  /// Indicates whether the device should vibrate for notifications.
  final bool vibrationEnabled;

  /// اسم النغمة أو المعرف المنطقي المستخدم لصوت الإشعار.
  /// Logical tone name or identifier used for the notification sound.
  final String notificationTone;

  /// تفضيلات مخصصة لكل فئة إشعارات عند الحاجة إلى تحكم أكثر دقة.
  /// Per-category preferences used when finer-grained notification control is
  /// needed.
  final Map<String, bool> categoryPreferences;

  /// ينشئ مجموعة تفضيلات الإشعارات بالقيم الافتراضية أو المخصصة.
  /// Creates the notification-preferences group with default or custom
  /// values.
  const NotificationSettings({
    this.bookingNotifications = true,
    this.promotionalNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationTone = 'default',
    this.categoryPreferences = const {},
  });

  /// يعيد نسخة محدثة من تفضيلات الإشعارات مع الحفاظ على بقية القيم.
  /// Returns an updated notification-preferences object while preserving the
  /// remaining values.
  NotificationSettings copyWith({
    bool? bookingNotifications,
    bool? promotionalNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? notificationTone,
    Map<String, bool>? categoryPreferences,
  }) {
    return NotificationSettings(
      bookingNotifications: bookingNotifications ?? this.bookingNotifications,
      promotionalNotifications:
          promotionalNotifications ?? this.promotionalNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationTone: notificationTone ?? this.notificationTone,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
    );
  }

  /// يعيد الحقول التي تستخدم لمقارنة تفضيلات الإشعارات منطقيًا.
  /// Returns the fields used for logical equality between notification
  /// preferences.
  @override
  List<Object?> get props => [
        bookingNotifications,
        promotionalNotifications,
        emailNotifications,
        smsNotifications,
        pushNotifications,
        soundEnabled,
        vibrationEnabled,
        notificationTone,
        categoryPreferences,
      ];
}
