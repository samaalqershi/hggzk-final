import '../../domain/entities/app_settings.dart';

/// الشبكة.
/// by storage or network layers.
class AppSettingsModel extends AppSettings {
  /// يعتمدان على البنية نفسها.
  /// storage and loading use the same structure.
  const AppSettingsModel({
    super.preferredLanguage,
    super.preferredCurrency,
    super.timeZone,
    super.darkMode,
    super.biometricEnabled,
    super.notificationSettings,
    super.additionalSettings,
    super.lastUpdated,
  });

  /// app.
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      preferredLanguage: json['preferredLanguage'] ?? 'ar',
      preferredCurrency: json['preferredCurrency'] ?? 'YER',
      timeZone: json['timeZone'] ?? 'Asia/Aden',
      darkMode: json['darkMode'] ?? false,
      biometricEnabled: json['biometricEnabled'] ??
          (json['additionalSettings']?['biometricEnabled'] ?? false),
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettingsModel.fromJson(json['notificationSettings'])
          : const NotificationSettings(),
      additionalSettings: json['additionalSettings'] ?? {},
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  /// easily.
  Map<String, dynamic> toJson() {
    return {
      'preferredLanguage': preferredLanguage,
      'preferredCurrency': preferredCurrency,
      'timeZone': timeZone,
      'darkMode': darkMode,
      'biometricEnabled': biometricEnabled,
      'notificationSettings':
          (notificationSettings as NotificationSettingsModel).toJson(),
      'additionalSettings': additionalSettings,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// البيانات نفسها في طبقة التخزين.
  /// needs to be reused in storage.
  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      preferredLanguage: settings.preferredLanguage,
      preferredCurrency: settings.preferredCurrency,
      timeZone: settings.timeZone,
      darkMode: settings.darkMode,
      biometricEnabled: settings.biometricEnabled,
      notificationSettings: settings.notificationSettings,
      additionalSettings: settings.additionalSettings,
      lastUpdated: settings.lastUpdated,
    );
  }
}

/// app settings.
class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    super.bookingNotifications,
    super.promotionalNotifications,
    super.emailNotifications,
    super.smsNotifications,
    super.pushNotifications,
    super.soundEnabled,
    super.vibrationEnabled,
    super.notificationTone,
    super.categoryPreferences,
  });

  /// التطبيق.
  /// app can read.
  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      bookingNotifications: json['bookingNotifications'] ?? true,
      promotionalNotifications: json['promotionalNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      pushNotifications: json['pushNotifications'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      notificationTone: json['notificationTone'] ?? 'default',
      categoryPreferences:
          Map<String, bool>.from(json['categoryPreferences'] ?? {}),
    );
  }

  /// الإعدادات الكامل.
  /// embedded inside the full settings record.
  Map<String, dynamic> toJson() {
    return {
      'bookingNotifications': bookingNotifications,
      'promotionalNotifications': promotionalNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'notificationTone': notificationTone,
      'categoryPreferences': categoryPreferences,
    };
  }
}
