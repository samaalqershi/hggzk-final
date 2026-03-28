import 'dart:convert';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/app_settings_model.dart';

/// Contract for reading and persisting the app settings snapshot in local
/// storage.
/// عقدة عمل لقراءة وحفظ لقطة إعدادات التطبيق في التخزين المحلي.
abstract class SettingsLocalDataSource {
  /// Loads the current settings snapshot or creates defaults when nothing is
  /// cached yet.
  /// يحمل لقطة الإعدادات الحالية أو ينشئ القيم الافتراضية عند غياب الكاش.
  Future<AppSettingsModel> getSettings();

  /// Stores the full settings snapshot so it can be restored on the next app
  /// launch.
  /// يحفظ لقطة الإعدادات الكاملة حتى يمكن استعادتها عند تشغيل التطبيق مرة
  /// أخرى.
  Future<bool> saveSettings(AppSettingsModel settings);

  /// Updates only the cached language preference and keeps the merged settings
  /// snapshot in sync.
  /// يحدّث تفضيل اللغة المخزن فقط ويُبقي لقطة الإعدادات المدمجة متزامنة.
  Future<bool> updateLanguage(String languageCode);

  /// Updates the cached theme mode and writes the merged settings snapshot
  /// back to storage.
  /// يحدّث وضع السمة المخزن ثم يعيد حفظ لقطة الإعدادات المدمجة.
  Future<bool> updateTheme(bool isDarkMode);

  /// Updates the biometric lock preference in both the dedicated key and the
  /// merged settings snapshot.
  /// يحدّث تفضيل القفل البيومتري في المفتاح المخصص وفي لقطة الإعدادات
  /// المدمجة.
  Future<bool> updateBiometric(bool enabled);

  /// Replaces the stored notification settings and keeps the full settings
  /// snapshot aligned with that change.
  /// يستبدل إعدادات الإشعارات المخزنة ويُبقي لقطة الإعدادات الكاملة متوافقة
  /// مع التغيير.
  Future<bool> updateNotificationSettings(NotificationSettingsModel settings);

  /// Updates the preferred currency used by the UI and any formatted values.
  /// يحدّث العملة المفضلة المستخدمة في الواجهة والقيم المنسقة.
  Future<bool> updateCurrency(String currencyCode);

  /// Updates the preferred time zone used by date and time presentation.
  /// يحدّث المنطقة الزمنية المفضلة المستخدمة في عرض التاريخ والوقت.
  Future<bool> updateTimeZone(String timeZone);

  /// Removes every cached settings key so the app can start with a clean
  /// local state.
  /// يحذف كل مفاتيح الإعدادات المخزنة حتى يبدأ التطبيق بحالة محلية نظيفة.
  Future<bool> clearSettings();

  /// Returns the cached settings snapshot if one exists, otherwise `null`.
  /// يعيد لقطة الإعدادات المخزنة إن وُجدت، وإلا يعيد `null`.
  Future<AppSettingsModel?> getCachedSettings();
}

/// Concrete implementation that serializes settings into the shared local
/// storage service.
/// تنفيذ فعلي يحول الإعدادات إلى صيغة قابلة للتخزين داخل خدمة التخزين
/// المحلية المشتركة.
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  /// Local storage adapter used to persist and read serialized settings.
  /// محول التخزين المحلي المستخدم لحفظ وقراءة الإعدادات المسلسلة.
  final LocalStorageService localStorage;

  /// Storage key for the full settings JSON blob.
  /// مفتاح التخزين الخاص بملف JSON الكامل للإعدادات.
  static const String _settingsKey = 'app_settings';

  /// Storage key for the preferred language value.
  /// مفتاح التخزين الخاص بقيمة اللغة المفضلة.
  static const String _languageKey = 'preferred_language';

  /// Storage key for the dark-mode flag.
  /// مفتاح التخزين الخاص بعلم الوضع الداكن.
  static const String _themeKey = 'dark_mode';

  /// Storage key for biometric preference.
  /// مفتاح التخزين الخاص بتفضيل القفل البيومتري.
  static const String _biometricKey = 'biometric_enabled';

  /// Storage key for the preferred currency code.
  /// مفتاح التخزين الخاص برمز العملة المفضلة.
  static const String _currencyKey = 'preferred_currency';

  /// Storage key for the preferred time zone.
  /// مفتاح التخزين الخاص بالمنطقة الزمنية المفضلة.
  static const String _timeZoneKey = 'time_zone';

  /// Storage key for serialized notification settings.
  /// مفتاح التخزين الخاص بإعدادات الإشعارات المسلسلة.
  static const String _notificationKey = 'notification_settings';

  /// Binds the data source to the shared local storage service.
  /// يربط مصدر البيانات بخدمة التخزين المحلية المشتركة.
  SettingsLocalDataSourceImpl({required this.localStorage});

  /// يقرأ لقطة الإعدادات الكاملة من التخزين، أو ينشئ القيم الافتراضية إذا
  /// لم توجد بيانات محفوظة بعد.
  /// Reads the full settings snapshot from storage, or creates defaults when
  /// no persisted data exists yet.
  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      final settingsJson = localStorage.getData(_settingsKey);

      if (settingsJson != null && settingsJson is String) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return AppSettingsModel.fromJson(json);
      }

      // Fall back to defaults when nothing has been persisted yet.
      return _createDefaultSettings();
    } catch (e) {
      throw CacheException('Failed to load settings: $e');
    }
  }

  /// يحفظ لقطة الإعدادات الكاملة بصيغة JSON داخل التخزين المحلي.
  /// Persists the full settings snapshot as JSON in local storage.
  @override
  Future<bool> saveSettings(AppSettingsModel settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      return await localStorage.saveData(_settingsKey, json);
    } catch (e) {
      throw CacheException('Failed to save settings: $e');
    }
  }

  /// يحدّث اللغة المفضلة ويعيد بناء لقطة الإعدادات الموحدة بعد التعديل.
  /// Updates the preferred language and rebuilds the merged settings snapshot
  /// after the change.
  @override
  Future<bool> updateLanguage(String languageCode) async {
    try {
      await localStorage.saveData(_languageKey, languageCode);

      final settings = await getSettings();
      final updatedSettings = AppSettingsModel.fromEntity(
        settings.copyWith(
          preferredLanguage: languageCode,
          lastUpdated: DateTime.now(),
        ),
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException('Failed to update language: $e');
    }
  }

  /// يحدّث وضع المظهر ويحفظه منفصلًا وضمن لقطة الإعدادات الكاملة أيضًا.
  /// Updates the theme mode, storing it both as a dedicated value and within
  /// the complete settings snapshot.
  @override
  Future<bool> updateTheme(bool isDarkMode) async {
    try {
      await localStorage.saveData(_themeKey, isDarkMode);

      final settings = await getSettings();
      final updatedSettings = AppSettingsModel.fromEntity(
        settings.copyWith(
          darkMode: isDarkMode,
          lastUpdated: DateTime.now(),
        ),
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException('Failed to update theme: $e');
    }
  }

  /// يحدّث خيار المصادقة البيومترية ويحافظ على مزامنته داخل الحقول
  /// الإضافية ولقطة الإعدادات.
  /// Updates the biometric-authentication option and keeps it synchronized in
  /// both additional settings and the merged snapshot.
  @override
  Future<bool> updateBiometric(bool enabled) async {
    try {
      await localStorage.saveData(_biometricKey, enabled);

      final settings = await getSettings();
      final updatedSettings = AppSettingsModel.fromEntity(
        settings.copyWith(
          biometricEnabled: enabled,
          additionalSettings: {
            ...settings.additionalSettings,
            'biometricEnabled': enabled,
          },
          lastUpdated: DateTime.now(),
        ),
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException('Failed to update biometric: $e');
    }
  }

  /// يستبدل إعدادات الإشعارات المسلسلة ثم يدمجها داخل لقطة الإعدادات
  /// الكاملة.
  /// Replaces the serialized notification settings and then merges them into
  /// the complete settings snapshot.
  @override
  Future<bool> updateNotificationSettings(
      NotificationSettingsModel settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      await localStorage.saveData(_notificationKey, json);

      final currentSettings = await getSettings();
      final updatedSettings = AppSettingsModel.fromEntity(
        currentSettings.copyWith(
          notificationSettings: settings,
          lastUpdated: DateTime.now(),
        ),
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException('Failed to update notification settings: $e');
    }
  }

  /// يحدّث العملة المفضلة ويعكس هذا التغيير في لقطة الإعدادات المحفوظة.
  /// Updates the preferred currency and reflects that change in the persisted
  /// settings snapshot.
  @override
  Future<bool> updateCurrency(String currencyCode) async {
    try {
      await localStorage.saveData(_currencyKey, currencyCode);

      final settings = await getSettings();
      final updatedSettings = AppSettingsModel.fromEntity(
        settings.copyWith(
          preferredCurrency: currencyCode,
          lastUpdated: DateTime.now(),
        ),
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException('Failed to update currency: $e');
    }
  }

  /// يحدّث المنطقة الزمنية المفضلة ويحفظ نسخة جديدة من الإعدادات بعد ذلك.
  /// Updates the preferred time zone and saves a refreshed settings snapshot
  /// afterward.
  @override
  Future<bool> updateTimeZone(String timeZone) async {
    try {
      await localStorage.saveData(_timeZoneKey, timeZone);

      final settings = await getSettings();
      final updatedSettings = AppSettingsModel.fromEntity(
        settings.copyWith(
          timeZone: timeZone,
          lastUpdated: DateTime.now(),
        ),
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException('Failed to update time zone: $e');
    }
  }

  /// يمسح كل مفاتيح الإعدادات المحلية حتى يعود التطبيق إلى حالة إعدادات
  /// أولية.
  /// Clears every locally stored settings key so the app returns to an
  /// initial settings state.
  @override
  Future<bool> clearSettings() async {
    try {
      await localStorage.removeData(_settingsKey);
      await localStorage.removeData(_languageKey);
      await localStorage.removeData(_themeKey);
      await localStorage.removeData(_biometricKey);
      await localStorage.removeData(_currencyKey);
      await localStorage.removeData(_timeZoneKey);
      await localStorage.removeData(_notificationKey);
      return true;
    } catch (e) {
      throw CacheException('Failed to clear settings: $e');
    }
  }

  /// يعيد لقطة الإعدادات المخزنة حاليًا إن كانت متاحة دون إنشاء قيم
  /// افتراضية جديدة.
  /// Returns the currently cached settings snapshot when available without
  /// creating new defaults.
  @override
  Future<AppSettingsModel?> getCachedSettings() async {
    try {
      final settingsJson = localStorage.getData(_settingsKey);
      if (settingsJson != null && settingsJson is String) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return AppSettingsModel.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Builds the default settings snapshot used when local storage is empty.
  /// ينشئ لقطة الإعدادات الافتراضية المستخدمة عندما يكون التخزين المحلي
  /// فارغًا.
  AppSettingsModel _createDefaultSettings() {
    return AppSettingsModel(
      preferredLanguage: 'ar',
      preferredCurrency: 'YER',
      timeZone: 'Asia/Aden',
      darkMode: false,
      biometricEnabled: false,
      notificationSettings: const NotificationSettingsModel(),
      additionalSettings: const {'biometricEnabled': false},
      lastUpdated: DateTime.now(),
    );
  }
}
