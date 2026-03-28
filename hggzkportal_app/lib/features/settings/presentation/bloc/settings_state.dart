import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';

/// العربية: تغطي دورة الإعدادات من التحميل إلى التحديث والمزامنة والخطأ حتى
/// تبقى شاشة الإعدادات مرتبطة بحالة واضحة واحدة.
abstract class SettingsState extends Equatable {
  /// العربية: تثبت أن حالات الإعدادات تُقارن وفق بياناتها فقط.
  const SettingsState();

  /// العربية: لا توجد حقول مشتركة على مستوى القاعدة.
  @override
  List<Object?> get props => [];
}

/// العربية: حالة البداية قبل تحميل الإعدادات.
class SettingsInitial extends SettingsState {}

/// العربية: تعني أن الإعدادات قيد التحميل الآن.
class SettingsLoading extends SettingsState {}

/// العربية: تمثل إعدادات جاهزة للعرض بعد اكتمال الجلب.
class SettingsLoaded extends SettingsState {
  /// العربية: لقطة الإعدادات المحملة.
  final AppSettings settings;

  /// العربية: تحتفظ بالإعدادات بعد الجلب الناجح.
  const SettingsLoaded(this.settings);

  /// العربية: تعتمد المقارنة على لقطة الإعدادات.
  @override
  List<Object> get props => [settings];
}

/// العربية: تعني أن الإعدادات تُحدّث محليًا أو على الخادم.
class SettingsUpdating extends SettingsState {
  /// العربية: الإعدادات الحالية قبل تطبيق التعديل.
  final AppSettings currentSettings;

  /// العربية: تلتقط اللقطة الحالية أثناء تجهيز التحديث.
  const SettingsUpdating(this.currentSettings);

  /// العربية: تعتمد المقارنة على الإعدادات الحالية.
  @override
  List<Object> get props => [currentSettings];
}

/// العربية: تمثل نجاح تحديث الإعدادات.
class SettingsUpdated extends SettingsState {
  /// العربية: الإعدادات بعد نجاح الحفظ.
  final AppSettings settings;

  /// العربية: رسالة النجاح المعروضة للمستخدم.
  final String message;

  /// العربية: تسجل النتيجة الناجحة مع الرسالة المناسبة.
  const SettingsUpdated(this.settings, {this.message = 'تم التحديث بنجاح'});

  /// العربية: تعتمد المقارنة على الإعدادات والرسالة.
  @override
  List<Object> get props => [settings, message];
}

/// العربية: تمثل فشلًا أثناء قراءة الإعدادات أو حفظها.
class SettingsError extends SettingsState {
  /// العربية: وصف الخطأ الذي سيظهر للمستخدم.
  final String message;

  /// العربية: لقطة الإعدادات الأخيرة قبل الفشل إن وُجدت.
  final AppSettings? lastKnownSettings;

  /// العربية: تسجل الفشل مع احتفاظ اختياري بالإعدادات السابقة.
  const SettingsError(this.message, {this.lastKnownSettings});

  /// العربية: تعتمد المقارنة على الرسالة واللقطة السابقة.
  @override
  List<Object?> get props => [message, lastKnownSettings];
}

/// العربية: تعني أن الإعدادات تُزامن الآن مع الخادم.
class SettingsSyncing extends SettingsState {
  /// العربية: الإعدادات التي يجري مزامنتها حاليًا.
  final AppSettings currentSettings;

  /// العربية: تثبت اللقطة الحالية أثناء المزامنة.
  const SettingsSyncing(this.currentSettings);

  /// العربية: تعتمد المقارنة على الإعدادات الحالية.
  @override
  List<Object> get props => [currentSettings];
}

/// العربية: تعني أن المزامنة انتهت بنجاح.
class SettingsSynced extends SettingsState {
  /// العربية: الإعدادات بعد اكتمال المزامنة.
  final AppSettings settings;

  /// العربية: تلتقط اللقطة النهائية بعد المزامنة.
  const SettingsSynced(this.settings);

  /// العربية: تعتمد المقارنة على الإعدادات النهائية.
  @override
  List<Object> get props => [settings];
}
