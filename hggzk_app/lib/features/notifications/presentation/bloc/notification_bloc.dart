import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_notification_settings_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/dismiss_notification_usecase.dart';
import '../../domain/usecases/update_notification_settings_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// يدير تحميل الإشعارات وتحديث حالتها وتفضيلاتها داخل طبقة العرض.
/// Manages notification loading, state updates, and preferences in the
/// presentation layer.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  /// يحمّل صفحات الإشعارات من طبقة الدومين عند الطلب.
  /// Loads notification pages from the domain layer on demand.
  final GetNotificationsUseCase? getNotificationsUseCase;

  /// يعلّم إشعارًا واحدًا أو مجموعة إشعارات كمقروءة عند تنفيذ الإجراء.
  /// Marks one notification or a batch as read when triggered.
  final MarkAsReadUseCase? markAsReadUseCase;

  /// يزيل الإشعار من الواجهة ومن الحالة المحلية بعد تنفيذ الإخفاء.
  /// Removes a notification from the UI and local state after dismissal.
  final DismissNotificationUseCase? dismissNotificationUseCase;

  /// يحدّث إعدادات الإشعارات المخزنة مثل التنبيهات والتفضيلات المرتبطة.
  /// Updates stored notification settings such as alerts and related
  /// preferences.
  final UpdateNotificationSettingsUseCase? updateNotificationSettingsUseCase;

  /// يجلب عدد الإشعارات غير المقروءة حتى تبقى الشارة متزامنة.
  /// Fetches the unread count so badges stay in sync.
  final GetUnreadCountUseCase? getUnreadCountUseCase;

  /// يسترجع إعدادات الإشعارات المحفوظة لعرضها أو تعديلها.
  /// Retrieves saved notification settings for display or editing.
  final GetNotificationSettingsUseCase? getNotificationSettingsUseCase;

  /// نسخة محلية من الإشعارات لتقليل الطلبات المتكررة أثناء التصفح.
  /// Local notification cache used to reduce repeated requests while browsing.
  List<NotificationEntity> _cachedNotifications = [];

  /// رقم الصفحة الجاري تحميلها أو عرضه من الخادم.
  /// The page number currently being loaded or displayed from the server.
  int _currentPage = 1;

  /// يوضح ما إذا كانت كل الصفحات المتاحة قد جرى الوصول إليها.
  /// Indicates whether all available pages have already been reached.
  bool _hasReachedMax = false;

  /// عدد الإشعارات غير المقروءة المحسوب من المصدر المحلي أو البعيد.
  /// The unread count computed from either local or remote data.
  int _unreadCount = 0;

  /// ينشئ منطق الإشعارات ويربطه بأحداث التحميل والتحديث المختلفة.
  /// Creates the notifications bloc and wires it to loading and update events.
  NotificationBloc({
    this.getNotificationsUseCase,
    this.markAsReadUseCase,
    this.dismissNotificationUseCase,
    this.updateNotificationSettingsUseCase,
    this.getUnreadCountUseCase,
    this.getNotificationSettingsUseCase,
  }) : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
    on<DismissNotificationEvent>(_onDismissNotification);
    on<UpdateNotificationSettingsEvent>(_onUpdateSettings);
    on<LoadUnreadCountEvent>(_onLoadUnreadCount);
    on<LoadNotificationSettingsEvent>(_onLoadNotificationSettings);
  }

  /// يجلب صفحة جديدة من الإشعارات مع دعم التحديث الكامل أو التحميل التدريجي.
  /// Fetches a new notification page with support for full refresh or
  /// incremental loading.
  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (getNotificationsUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }

    final bool isRefresh = event.refresh || event.page <= 1;

    if (isRefresh) {
      _cachedNotifications = [];
      _currentPage = 1;
      _hasReachedMax = false;
      emit(const NotificationLoading());
    }

    final params = GetNotificationsParams(
      page: event.page,
      limit: event.limit,
      type: event.type,
    );

    final result = await getNotificationsUseCase!(params);

    await result.fold(
      (failure) async =>
          emit(NotificationError(message: _mapFailureToMessage(failure))),
      (paginatedResult) async {
        _currentPage = paginatedResult.pageNumber;
        _hasReachedMax = !paginatedResult.hasNextPage;
        _updateCachedNotifications(paginatedResult.items, refresh: isRefresh);
        _emitLoadedState(emit);
      },
    );
  }

  /// يرسل طلب التعليم كمقروء ثم يحدّث الحالة المحلية والشارة.
  /// Sends the mark-as-read request, then updates local state and badges.
  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (markAsReadUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }

    final params = MarkAsReadParams(notificationId: event.notificationId);
    final result = await markAsReadUseCase!(params);

    await result.fold(
      (failure) async =>
          emit(NotificationError(message: _mapFailureToMessage(failure))),
      (_) async {
        _cachedNotifications = _cachedNotifications
            .map((notification) => notification.id == event.notificationId
                ? _markNotificationAsRead(notification)
                : notification)
            .toList(growable: false);
        await _refreshUnreadCount();
        emit(NotificationOperationSuccess(
          message: AppLocalizations.translateSync(
            'notifications.actions.markedRead',
          ),
        ));
        _emitLoadedState(emit);
      },
    );
  }

  /// يعلّم جميع الإشعارات كمقروءة ويعيد مزامنة العدّاد والقائمة.
  /// Marks all notifications as read and re-syncs the counter and list.
  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (markAsReadUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }

    const params = MarkAsReadParams();
    final result = await markAsReadUseCase!(params);

    await result.fold(
      (failure) async =>
          emit(NotificationError(message: _mapFailureToMessage(failure))),
      (_) async {
        _cachedNotifications = _cachedNotifications
            .map((notification) => _markNotificationAsRead(notification))
            .toList(growable: false);
        await _refreshUnreadCount();
        emit(NotificationOperationSuccess(
          message: AppLocalizations.translateSync(
            'notifications.actions.allMarkedRead',
          ),
        ));
        _emitLoadedState(emit);
      },
    );
  }

  /// يخفي الإشعار المحدد من الخادم ثم يزيله من الحالة المحلية.
  /// Dismisses the selected notification from the server and local state.
  Future<void> _onDismissNotification(
    DismissNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (dismissNotificationUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }

    final params =
        DismissNotificationParams(notificationId: event.notificationId);
    final result = await dismissNotificationUseCase!(params);

    await result.fold(
      (failure) async =>
          emit(NotificationError(message: _mapFailureToMessage(failure))),
      (_) async {
        _cachedNotifications = _cachedNotifications
            .where((notification) => notification.id != event.notificationId)
            .toList(growable: false);
        await _refreshUnreadCount();
        emit(NotificationOperationSuccess(
          message: AppLocalizations.translateSync(
            'notifications.actions.dismissed',
          ),
        ));
        _emitLoadedState(emit);
      },
    );
  }

  /// يحدّث إعدادات الإشعارات ويبلّغ الواجهة بنتيجة العملية.
  /// Updates notification settings and reports the operation result to the
  /// UI.
  Future<void> _onUpdateSettings(
    UpdateNotificationSettingsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (updateNotificationSettingsUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }

    final params = UpdateNotificationSettingsParams(settings: event.settings);
    final result = await updateNotificationSettingsUseCase!(params);

    await result.fold(
      (failure) async =>
          emit(NotificationError(message: _mapFailureToMessage(failure))),
      (_) async => emit(NotificationOperationSuccess(
        message: AppLocalizations.translateSync(
          'notifications.actions.settingsUpdated',
        ),
      )),
    );
  }

  /// يجلب إعدادات الإشعارات المخزنة لعرضها في شاشة التفضيلات.
  /// Loads the stored notification settings for the preferences screen.
  Future<void> _onLoadNotificationSettings(
    LoadNotificationSettingsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (getNotificationSettingsUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }

    emit(const NotificationSettingsLoading());

    final result = await getNotificationSettingsUseCase!(
        const GetNotificationSettingsParams());

    await result.fold(
      (failure) async =>
          emit(NotificationError(message: _mapFailureToMessage(failure))),
      (settings) async => emit(NotificationSettingsLoaded(settings: settings)),
    );
  }

  /// يزامن عدّاد غير المقروء مع المصدر البعيد أو مع الحالة المحلية كبديل.
  /// Syncs the unread counter with the remote source or falls back to the
  /// local state.
  Future<void> _onLoadUnreadCount(
    LoadUnreadCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (getUnreadCountUseCase == null) {
      emit(NotificationError(
        message: AppLocalizations.translateSync(
          'notifications.errors.featureNotInitialized',
        ),
      ));
      return;
    }
    final result = await getUnreadCountUseCase!(const GetUnreadCountParams());
    await result.fold(
      (failure) async {
        if (_cachedNotifications.isEmpty && state is! NotificationLoaded) {
          emit(NotificationError(message: _mapFailureToMessage(failure)));
        } else {
          _emitLoadedState(emit);
        }
      },
      (count) async {
        _unreadCount = count;
        if (_cachedNotifications.isNotEmpty || state is NotificationLoaded) {
          _emitLoadedState(emit);
        } else {
          emit(NotificationUnreadCountLoaded(unreadCount: count));
        }
      },
    );
  }

  /// يحول أنواع الفشل الشائعة إلى رسائل مفهومة للمستخدم.
  /// Maps common failure types to user-friendly messages.
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return AppLocalizations.translateSync('notifications.errors.server');
      case NetworkFailure:
        return AppLocalizations.translateSync('notifications.errors.network');
      default:
        return AppLocalizations.translateSync(
            'notifications.errors.unexpected');
    }
  }

  /// يدمج البيانات الجديدة مع النسخة المحلية ويعيد حساب العدد غير المقروء.
  /// Merges new data into the local cache and recalculates the unread count.
  void _updateCachedNotifications(
    List<NotificationEntity> freshNotifications, {
    required bool refresh,
  }) {
    if (refresh) {
      _cachedNotifications = List<NotificationEntity>.from(freshNotifications);
    } else {
      final updated = List<NotificationEntity>.from(_cachedNotifications);
      for (final notification in freshNotifications) {
        final index =
            updated.indexWhere((element) => element.id == notification.id);
        if (index >= 0) {
          updated[index] = notification;
        } else {
          updated.add(notification);
        }
      }
      _cachedNotifications = updated;
    }
    _unreadCount = _cachedNotifications
        .where((notification) => !notification.isRead)
        .length;
  }

  /// ينشئ نسخة من الإشعار مع ضبطه كمقروء إذا كان ما زال غير مقروء.
  /// Builds a copy of a notification marked as read when it is still unread.
  NotificationEntity _markNotificationAsRead(NotificationEntity notification) {
    if (notification.isRead) {
      return notification;
    }

    return NotificationEntity(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      data: notification.data,
      isRead: true,
      createdAt: notification.createdAt,
      readAt: notification.readAt ?? DateTime.now(),
    );
  }

  /// يعيد جلب العدّاد غير المقروء أو يحسبه محليًا إذا تعذر الوصول للمصدر.
  /// Refreshes the unread counter or falls back to local counting if the
  /// source is unavailable.
  Future<void> _refreshUnreadCount() async {
    if (getUnreadCountUseCase == null) {
      _unreadCount = _cachedNotifications
          .where((notification) => !notification.isRead)
          .length;
      return;
    }

    final unreadRes =
        await getUnreadCountUseCase!(const GetUnreadCountParams());
    await unreadRes.fold(
      (failure) async {
        _unreadCount = _cachedNotifications
            .where((notification) => !notification.isRead)
            .length;
      },
      (count) async {
        _unreadCount = count;
      },
    );
  }

  /// يرسل حالة التحميل النهائية إلى الواجهة مع كل البيانات المحسوبة.
  /// Emits the final loaded state to the UI with all computed data.
  void _emitLoadedState(Emitter<NotificationState> emit) {
    emit(NotificationLoaded(
      notifications:
          List<NotificationEntity>.unmodifiable(_cachedNotifications),
      hasReachedMax: _hasReachedMax,
      currentPage: _currentPage,
      unreadCount: _unreadCount,
    ));
  }
}
