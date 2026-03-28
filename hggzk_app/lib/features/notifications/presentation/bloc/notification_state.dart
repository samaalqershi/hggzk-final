import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

/// يمثل لقطات حالة ميزة الإشعارات كما تحتاجها واجهات العرض.
/// Represents the notifications feature state snapshots needed by the UI.
abstract class NotificationState extends Equatable {
  /// يعرّف الأساس المشترك لجميع حالات الإشعارات حتى يمكن مقارنتها بثبات.
  /// Defines the shared base for notification states so they can be compared
  /// deterministically.
  const NotificationState();

  @override

  /// يحدد القيم التي تدخل في مقارنة الحالة لتفادي إعادة البناء غير الضرورية.
  /// Lists the values used for state comparison to avoid unnecessary rebuilds.
  List<Object?> get props => [];
}

/// الحالة الابتدائية قبل تحميل أي بيانات.
/// Initial state before any notification data is loaded.
class NotificationInitial extends NotificationState {
  /// ينشئ حالة البداية التي تعني أن الشاشة لم تحصل على بيانات بعد.
  /// Creates the startup state that means the screen has not received data
  /// yet.
  const NotificationInitial();
}

/// تشير إلى أن قائمة الإشعارات قيد التحميل.
/// Indicates that the notifications list is loading.
class NotificationLoading extends NotificationState {
  /// ينشئ حالة انتظار تعرضها الواجهة أثناء جلب قائمة الإشعارات.
  /// Creates the waiting state shown while the UI fetches notifications.
  const NotificationLoading();
}

/// تشير إلى أن إعدادات الإشعارات قيد التحميل.
/// Indicates that notification settings are loading.
class NotificationSettingsLoading extends NotificationState {
  /// ينشئ حالة انتظار خاصة بتحميل تفضيلات الإشعارات.
  /// Creates the loading state dedicated to notification preferences.
  const NotificationSettingsLoading();
}

/// تحمل الإشعارات الحالية مع معلومات الصفحة والعدد غير المقروء.
/// Carries the current notifications list together with paging and unread
/// count information.
class NotificationLoaded extends NotificationState {
  /// الإشعارات التي ستعرضها الواجهة بالترتيب الحالي.
  /// The notifications that should be rendered in their current order.
  final List<NotificationEntity> notifications;

  /// يوضح ما إذا كانت كل الصفحات المتاحة قد تم تحميلها بالفعل.
  /// Indicates whether all available pages have already been loaded.
  final bool hasReachedMax;

  /// رقم الصفحة الحالية الذي تعتمد عليه عملية التمرير أو التحميل المتدرج.
  /// The current page number used by pagination and infinite scrolling.
  final int currentPage;

  /// العدد الحالي للإشعارات غير المقروءة داخل القائمة المحلية.
  /// The current unread notification count in the local list.
  final int unreadCount;

  /// ينشئ حالة التحميل الكاملة مع بيانات القائمة والصفحة والعدد غير المقروء.
  /// Creates the fully loaded state with list, paging, and unread-count data.
  const NotificationLoaded({
    required this.notifications,
    required this.hasReachedMax,
    required this.currentPage,
    required this.unreadCount,
  });

  @override

  /// يضمن أن تغيّر أي جزء من بيانات القائمة أو الترقيم ينتج حالة جديدة.
  /// Ensures any change in list or paging data yields a distinct state.
  List<Object> get props =>
      [notifications, hasReachedMax, currentPage, unreadCount];

  /// ينشئ نسخة معدلة من الحالة مع الإبقاء على القيم غير الممررة كما هي.
  /// Creates a modified copy of the state while preserving omitted values.
  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    bool? hasReachedMax,
    int? currentPage,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// يحمل عدد الإشعارات غير المقروءة فقط.
/// Carries only the unread notifications count.
class NotificationUnreadCountLoaded extends NotificationState {
  /// العدد الحالي للإشعارات غير المقروءة الذي تحتاجه الشارة أو العدّاد.
  /// The current unread count needed by badges or counters.
  final int unreadCount;

  /// ينشئ حالة خفيفة مخصّصة لعرض العدد غير المقروء فقط.
  /// Creates a lightweight state dedicated to the unread count only.
  const NotificationUnreadCountLoaded({required this.unreadCount});

  @override

  /// يربط تغير العدد غير المقروء بتغير الحالة حتى تعكس الواجهة ذلك مباشرة.
  /// Binds unread-count changes to the state so the UI reflects them directly.
  List<Object?> get props => [unreadCount];
}

/// تحمل إعدادات الإشعارات بعد تحميلها أو تحديثها.
/// Carries notification settings after they are loaded or refreshed.
class NotificationSettingsLoaded extends NotificationState {
  /// مفاتيح الإعدادات وقيمها المنطقية كما وصلت من طبقة البيانات.
  /// Setting keys and boolean values as received from the data layer.
  final Map<String, bool> settings;

  /// ينشئ حالة تحتوي على الإعدادات الحالية لميزات الإشعارات.
  /// Creates a state containing the current notification feature settings.
  const NotificationSettingsLoaded({required this.settings});

  @override

  /// يضمن أن أي تغيير في خريطة الإعدادات ينتج حالة مميزة.
  /// Ensures any settings-map change produces a distinct state.
  List<Object> get props => [settings];
}

/// يؤكد نجاح عملية جانبية مثل الإخفاء أو التعليم كمقروء.
/// Confirms a side operation such as dismissal or mark-as-read succeeded.
class NotificationOperationSuccess extends NotificationState {
  /// الرسالة التي تعكس نتيجة العملية كي تعرضها الواجهة أو الشريط العلوي.
  /// The message describing the operation result for the UI or snackbars.
  final String message;

  /// ينشئ حالة نجاح خفيفة لعمليات الإشعارات الجانبية.
  /// Creates a lightweight success state for side notification actions.
  const NotificationOperationSuccess({required this.message});

  @override

  /// يربط نجاح العملية بالنص الذي يوضّح ما حدث للمستخدم.
  /// Binds the success state to the message shown to the user.
  List<Object> get props => [message];
}

/// يحمل رسالة خطأ متعلقة بميزة الإشعارات.
/// Carries an error message related to the notifications feature.
class NotificationError extends NotificationState {
  /// نص الخطأ الموجّه للواجهة أو لرسالة التنبيه.
  /// The error text intended for the UI or a warning message.
  final String message;

  /// ينشئ حالة خطأ حتى تعرض الواجهة سبب فشل العملية الحالية.
  /// Creates an error state so the UI can present the current failure reason.
  const NotificationError({required this.message});

  @override

  /// يربط الخطأ بالنص الخاص به حتى يتغير العرض عند تغير الرسالة.
  /// Binds the error to its message so the view updates when the text changes.
  List<Object> get props => [message];
}
