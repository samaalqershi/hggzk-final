import '../../domain/entities/app_settings.dart';

/// يحول بيانات الإعدادات الخام إلى كيان مجال موحد يمكن لبقية الطبقات
/// استهلاكه بسهولة.
/// Converts raw settings data into a normalized domain entity consumable by
/// the rest of the app.
class AppSettingsModel extends AppSettings {
  /// ينشئ نموذج إعدادات يمكن تمريره بين طبقات التخزين والمجال.
  /// Creates a settings model that can move between data and domain layers.
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

  /// يحول خريطة JSON الخام إلى نموذج إعدادات منسق للقيم المتوقعة.
  /// Converts a raw JSON map into a settings model with normalized values.
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

  /// يحول النموذج الحالي إلى خريطة JSON قابلة للتخزين أو الإرسال.
  /// Converts the current model into a JSON map suitable for storage or
  /// transport.
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

  /// ينشئ نموذج بيانات من كيان المجال عند الحاجة إلى التخزين أو التسلسل.
  /// Creates a data model from the domain entity when persistence or
  /// serialization is required.
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

/// يمثل نموذج بيانات تفضيلات الإشعارات داخل إعدادات التطبيق.
/// Represents the data-model form of notification preferences inside app
/// settings.
class NotificationSettingsModel extends NotificationSettings {
  /// ينشئ نموذج بيانات لتفضيلات الإشعارات بالقيم الممررة أو الافتراضية.
  /// Creates a data model for notification preferences with supplied or
  /// default values.
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

  /// يحول بيانات JSON الخام إلى نموذج تفضيلات إشعارات صالح للاستخدام.
  /// Converts raw JSON into a usable notification-preferences model.
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

  /// يحول النموذج إلى خريطة JSON قابلة للتخزين أو الإرسال إلى الخلفية.
  /// Converts the model into a JSON map that can be stored or sent to the
  /// backend.
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
