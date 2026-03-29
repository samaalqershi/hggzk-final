import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';

/// يمثل لقطات حالة ميزة الإعدادات كما تحتاجها الواجهة.
/// Represents the settings feature state snapshots required by the UI.
abstract class SettingsState extends Equatable {
  /// ينشئ حالة إعدادات مجردة تمثل لقطة واحدة للواجهة.
  /// Creates an abstract settings state representing one UI snapshot.
  const SettingsState();

  /// يعيد الحقول التي تشارك في المقارنة بين الحالات.
  /// Returns the fields that participate in state equality.
  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية قبل تنفيذ أي قراءة أو تحديث للإعدادات.
/// Initial state before any settings read or update has been performed.
class SettingsInitial extends SettingsState {}

/// تشير إلى أن الإعدادات الحالية ما زالت قيد التحميل.
/// Indicates that the current settings are still loading.
class SettingsLoading extends SettingsState {}

/// تحمل الإعدادات المحملة الجاهزة للعرض والتحرير.
/// Carries the loaded settings ready for display and editing.
class SettingsLoaded extends SettingsState {
  /// الإعدادات الحالية التي ستعتمد عليها الواجهة.
  /// Current settings used by the UI.
  final AppSettings settings;

  /// ينشئ حالة محملة مع الإعدادات الفعلية.
  /// Creates a loaded state with the actual settings payload.
  const SettingsLoaded(this.settings);

  /// يعيد الحقول المستخدمة في المقارنة بين الحالات المحملة.
  /// Returns the fields used when comparing loaded states.
  @override
  List<Object> get props => [settings];
}

/// تشير إلى أن تحديثًا قيد التنفيذ مع الاحتفاظ بنسخة مرجعية من الإعدادات
/// الحالية.
/// Indicates that an update is running while keeping a reference copy of the
/// current settings.
class SettingsUpdating extends SettingsState {
  /// الإعدادات الحالية قبل اكتمال التحديث.
  /// Current settings before the update fully completes.
  final AppSettings currentSettings;

  /// ينشئ حالة تحديث مع الإعدادات المرجعية الحالية.
  /// Creates an updating state with the current reference settings.
  const SettingsUpdating(this.currentSettings);

  /// يعيد الحقول المستخدمة في المقارنة أثناء حالة التحديث.
  /// Returns the fields used in equality during the updating state.
  @override
  List<Object> get props => [currentSettings];
}

/// تؤكد نجاح آخر تحديث مع الإعدادات الجديدة ورسالة مناسبة للواجهة.
/// Confirms the latest successful update together with refreshed settings and
/// a UI-friendly message.
class SettingsUpdated extends SettingsState {
  /// الإعدادات بعد تطبيق التحديث بنجاح.
  /// Settings after the successful update is applied.
  final AppSettings settings;

  /// رسالة النجاح التي يمكن عرضها للمستخدم.
  /// Success message that can be shown to the user.
  final String message;

  /// ينشئ حالة نجاح محدثة مع الإعدادات الجديدة ورسالة اختيارية.
  /// Creates the updated-success state with refreshed settings and an optional
  /// message.
  const SettingsUpdated(this.settings, {required this.message});

  /// يعيد الحقول المشاركة في مقارنة حالة التحديث الناجح.
  /// Returns the fields participating in equality for the updated state.
  @override
  List<Object> get props => [settings, message];
}

/// تحمل معلومات الخطأ مع إمكانية الاحتفاظ بآخر إعدادات صالحة معروفة.
/// Carries error information while optionally preserving the last known valid
/// settings.
class SettingsError extends SettingsState {
  /// رسالة الخطأ التي تحتاجها الواجهة لإبلاغ المستخدم.
  /// Error message surfaced to the UI.
  final String message;

  /// آخر نسخة صالحة من الإعدادات يمكن للواجهة الاستمرار في عرضها.
  /// Last known valid settings the UI can keep showing.
  final AppSettings? lastKnownSettings;

  /// ينشئ حالة خطأ مع الرسالة وآخر إعدادات معروفة إن وجدت.
  /// Creates an error state with the message and optional last-known settings.
  const SettingsError(this.message, {this.lastKnownSettings});

  /// يعيد الحقول المستخدمة في المقارنة لحالة الخطأ.
  /// Returns the fields used in equality for the error state.
  @override
  List<Object?> get props => [message, lastKnownSettings];
}

/// تشير إلى أن مزامنة الإعدادات مع جهة خارجية ما زالت جارية.
/// Indicates that settings synchronization with an external source is still in
/// progress.
class SettingsSyncing extends SettingsState {
  /// الإعدادات الحالية التي يتم مزامنتها.
  /// Current settings being synchronized.
  final AppSettings currentSettings;

  /// ينشئ حالة مزامنة مع الإعدادات الجاري إرسالها أو توحيدها.
  /// Creates a syncing state with the settings currently being synchronized.
  const SettingsSyncing(this.currentSettings);

  /// يعيد الحقول المستخدمة في المقارنة لحالة المزامنة.
  /// Returns the fields used in equality for the syncing state.
  @override
  List<Object> get props => [currentSettings];
}

/// تؤكد اكتمال المزامنة وتعيد الإعدادات النهائية المتفقة مع المصدر المعتمد.
/// Confirms synchronization completion and returns the final settings aligned
/// with the source of truth.
class SettingsSynced extends SettingsState {
  /// الإعدادات النهائية بعد نجاح المزامنة.
  /// Final settings after synchronization succeeds.
  final AppSettings settings;

  /// ينشئ حالة نجاح المزامنة مع الإعدادات النهائية.
  /// Creates the synchronized-success state with the final settings.
  const SettingsSynced(this.settings);

  /// يعيد الحقول المستخدمة في المقارنة بعد اكتمال المزامنة.
  /// Returns the fields used in equality after synchronization completes.
  @override
  List<Object> get props => [settings];
}
