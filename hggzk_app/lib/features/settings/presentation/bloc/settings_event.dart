import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';

/// يجمع جميع الأوامر التي تصدرها واجهة الإعدادات حتى يعالجها `SettingsBloc`
/// في مسار واحد واضح يربط بين اختيار المستخدم والحالة المخزنة.
/// Groups every settings command so `SettingsBloc` can handle UI actions and
/// keep the persisted app settings in sync with the user choice.
abstract class SettingsEvent extends Equatable {
  /// ينشئ حدث إعدادات مجردًا يمثل أمرًا واحدًا صادرًا من الواجهة.
  /// Creates an abstract settings event that represents a single UI command.
  const SettingsEvent();

  /// يعيد الحقول التي تعتمد عليها مقارنة أحداث الإعدادات.
  /// Returns the fields used when comparing settings events.
  @override
  List<Object?> get props => [];
}

/// يطلب من `SettingsBloc` إعادة قراءة الإعدادات الحالية من المصدر المعتمد
/// قبل أن تبني الواجهة أي قرار جديد عليها.
/// Tells `SettingsBloc` to reload the current settings from the trusted
/// source before the UI makes another decision on top of them.
class LoadSettingsEvent extends SettingsEvent {
  /// Creates a refresh request that instructs the bloc to fetch settings again.
  const LoadSettingsEvent();
}

/// يحمل رمز اللغة المختار حتى يحفظه البلوك ويعيد تهيئة النصوص بما يطابق
/// لغة الواجهة الجديدة.
/// Carries the selected language code so the bloc can persist it and rebuild
/// the UI in the newly selected locale.
class UpdateLanguageEvent extends SettingsEvent {
  /// رمز اللغة الذي اختاره المستخدم داخل شاشة الإعدادات.
  /// The language code selected by the user in settings.
  final String languageCode;

  /// Creates a language-change event for the supplied locale code.
  const UpdateLanguageEvent(this.languageCode);

  /// تجعل المقارنة تعتمد على رمز اللغة فقط لأن هذا هو الحمولة الفعلية لهذا
  /// الحدث.
  /// Keeps equality tied to the language code because it is the only payload
  /// that defines this event.
  @override
  List<Object> get props => [languageCode];
}

/// ينقل قرار تبديل الوضع الفاتح أو الداكن حتى يطبقه البلوك على الحالة
/// المحفوظة وعلى الواجهة معًا.
/// Carries the light/dark theme choice so the bloc can apply it to both the
/// stored settings and the visible UI.
class UpdateThemeEvent extends SettingsEvent {
  /// يحدد ما إذا كان المستخدم يريد الوضع الداكن أم لا.
  /// Indicates whether the user wants dark mode enabled.
  final bool isDarkMode;

  /// Creates a theme-toggle event for the requested appearance mode.
  const UpdateThemeEvent(this.isDarkMode);

  /// تضمن أن تتغير المساواة بحسب قيمة الوضع فقط لأن بقية الخصائص ثابتة.
  /// Keeps equality based on the mode flag because no other data is needed.
  @override
  List<Object> get props => [isDarkMode];
}

/// يمرر حالة تفعيل البصمة أو إلغائها حتى يحفظها البلوك ويزامنها مع التخزين
/// المحلي والأمان الخاص بالتسجيل.
/// Passes the biometric enable/disable choice so the bloc can persist it and
/// sync secure login storage with the new preference.
class UpdateBiometricEvent extends SettingsEvent {
  /// يوضح ما إذا كانت المصادقة الحيوية مفعلة.
  /// Shows whether biometric authentication should be enabled.
  final bool enabled;

  /// Creates a biometric-preference event for the requested state.
  const UpdateBiometricEvent(this.enabled);

  /// تربط المقارنة بالحالة المطلوبة فقط لأن هذا الحدث لا يحمل غيرها.
  /// Makes equality depend only on the requested biometric state.
  @override
  List<Object> get props => [enabled];
}

/// يحمّل إعدادات الإشعارات الجديدة كما اختارها المستخدم حتى تبقى السجلات
/// والتنبيهات متسقة مع التفضيلات الحالية.
/// Carries the updated notification preferences so the bloc can keep alerting
/// behavior aligned with the current user settings.
class UpdateNotificationSettingsEvent extends SettingsEvent {
  /// حزمة إعدادات الإشعارات المراد حفظها.
  /// The notification settings bundle that should be saved.
  final NotificationSettings settings;

  /// Creates a notification-settings update request for the given values.
  const UpdateNotificationSettingsEvent(this.settings);

  /// تعتمد المساواة على كائن الإعدادات نفسه لأنه يمثل الحالة النهائية.
  /// Bases equality on the settings object itself because it represents the
  /// final notification configuration.
  @override
  List<Object> get props => [settings];
}

/// يحمل رمز العملة المختار حتى يتم حفظه في الإعدادات النشطة وتظهر الأسعار
/// بنفس التنسيق في الواجهة.
/// Carries the selected currency code so the active settings and price widgets
/// stay aligned with the same money format.
class UpdateCurrencyEvent extends SettingsEvent {
  /// رمز العملة الذي يجب اعتماده في العرض والحفظ.
  /// The currency code that should drive display and persistence.
  final String currencyCode;

  /// Creates a currency-change event for the supplied code.
  const UpdateCurrencyEvent(this.currencyCode);

  /// تضمن أن اختلاف رمز العملة هو ما يحدد تمييز الحدث.
  /// Keeps the currency code as the only value that defines this event.
  @override
  List<Object> get props => [currencyCode];
}

/// يمرر المنطقة الزمنية المختارة حتى تبقى الطوابع الزمنية والحسابات
/// المرتبطة بالوقت متسقة مع موقع المستخدم.
/// Carries the selected time zone so timestamps and time-based calculations
/// remain consistent with the user's location.
class UpdateTimeZoneEvent extends SettingsEvent {
  /// المنطقة الزمنية المطلوبة للحفظ.
  /// The time zone value that should be stored.
  final String timeZone;

  /// Creates a time-zone update request for the supplied zone identifier.
  const UpdateTimeZoneEvent(this.timeZone);

  /// تجعل المقارنة تعتمد على معرف المنطقة الزمنية فقط.
  /// Keeps equality bound to the time-zone identifier alone.
  @override
  List<Object> get props => [timeZone];
}

/// يعيد الإعدادات إلى قيمها الافتراضية عندما يريد المستخدم البدء من نقطة
/// نظيفة بدل تعديل القيم الحالية.
/// Restores the settings to their defaults when the user wants a clean slate
/// instead of continuing from the current configuration.
class ResetSettingsEvent extends SettingsEvent {
  /// Creates a reset request that tells the bloc to restore default settings.
  const ResetSettingsEvent();
}

/// يطلب مزامنة حالة الإعدادات المحلية مع أي مصدر أبعد أو عملية حفظ مؤجلة
/// حتى لا تتخلف الواجهة عن الحالة الفعلية.
/// Requests a sync between the local settings snapshot and any remote or
/// deferred persistence layer so the UI does not drift from the real state.
class SyncSettingsEvent extends SettingsEvent {
  /// Creates a synchronization request for the current settings snapshot.
  const SyncSettingsEvent();
}

/// يسجل موافقة المستخدم على سياسة الخصوصية حتى تبنى قرارات الإعدادات اللاحقة
/// على حالة الموافقة نفسها.
/// Records that the user accepted the privacy policy so later settings flows
/// can rely on that consent state.
class AcceptPrivacyPolicyEvent extends SettingsEvent {
  /// Creates a consent-recording event for the privacy policy.
  const AcceptPrivacyPolicyEvent();

  /// لا يحمل هذا الحدث بيانات إضافية لأن الفعل نفسه هو المعلومة المهمة.
  /// This event carries no additional payload because the action itself is
  /// the meaningful piece of state.
  @override
  List<Object?> get props => [];
}
