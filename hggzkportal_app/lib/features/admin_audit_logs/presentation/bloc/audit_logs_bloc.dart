import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/usecases/get_audit_logs_usecase.dart';
import '../../domain/usecases/export_audit_logs_usecase.dart';
import '../../domain/repositories/audit_logs_repository.dart';
import 'audit_logs_event.dart';
import 'audit_logs_state.dart';

/// Coordinates audit-log loading, incremental pagination, filtering, export, and detail selection.
/// ينسق تحميل سجلات التدقيق، والتصفح التدريجي، والتصفية، والتصدير، واختيار التفاصيل.
class AuditLogsBloc extends Bloc<AuditLogsEvent, AuditLogsState> {
  /// Use case responsible for fetching paginated audit-log data.
  /// حالة الاستخدام المسؤولة عن جلب بيانات سجلات التدقيق المصفّحة.
  final GetAuditLogsUseCase getAuditLogsUseCase;

  /// Use case responsible for exporting the current audit-log query.
  /// حالة الاستخدام المسؤولة عن تصدير استعلام سجلات التدقيق الحالي.
  final ExportAuditLogsUseCase exportAuditLogsUseCase;

  /// Optional repository used when the UI needs to fetch a single audit-log detail record.
  /// مستودع اختياري يُستخدم عندما تحتاج الواجهة لجلب سجل تدقيق واحد بالتفصيل.
  final AuditLogsRepository? auditLogsRepository;

  /// Default page size used when the query does not specify one.
  /// حجم الصفحة الافتراضي عندما لا يحدد الاستعلام حجمًا صريحًا.
  static const int _pageSize = 20;

  /// Cooldown applied after rate-limited load-more responses.
  /// مهلة تهدئة تُطبّق بعد استجابات تحميل المزيد المقيدة بالمعدل.
  static const Duration _loadMoreRateLimitCooldown = Duration(seconds: 3);

  /// Small delay used before replaying a queued load-more request.
  /// تأخير قصير يُستخدم قبل إعادة تنفيذ طلب تحميل المزيد المؤجل.
  static const Duration _queuedLoadMoreDelay = Duration(milliseconds: 400);

  /// Tracks whether a load-more request is already being processed.
  /// يتتبع ما إذا كان طلب تحميل المزيد قيد التنفيذ بالفعل.
  bool _isLoadingMore = false;

  /// The time until which new load-more requests should be delayed.
  /// الوقت الذي يجب حتى بعده تأجيل طلبات تحميل المزيد الجديدة.
  DateTime? _loadMoreCooldownUntil;

  /// Prevents multiple queued retries from being scheduled at the same time.
  /// يمنع جدولة أكثر من إعادة محاولة مؤجلة في الوقت نفسه.
  bool _isLoadMoreRetryScheduled = false;

  /// Remembers whether another load-more request arrived while one was running.
  /// يتذكر ما إذا وصل طلب تحميل المزيد آخر أثناء تنفيذ طلب سابق.
  bool _hasQueuedLoadMoreRequest = false;

  /// Creates the bloc with the use cases and optional repository needed by the UI.
  /// ينشئ البلوك مع حالات الاستخدام والمستودع الاختياري الذي تحتاجه الواجهة.
  AuditLogsBloc({
    required this.getAuditLogsUseCase,
    required this.exportAuditLogsUseCase,
    AuditLogsRepository? repository,
  })  : auditLogsRepository = repository,
        super(AuditLogsInitial()) {
    on<LoadAuditLogsEvent>(_onLoadAuditLogs);
    on<LoadMoreAuditLogsEvent>(_onLoadMoreAuditLogs);
    on<RefreshAuditLogsEvent>(_onRefreshAuditLogs);
    on<FilterAuditLogsEvent>(_onFilterAuditLogs);
    on<ExportAuditLogsEvent>(_onExportAuditLogs);
    on<SelectAuditLogEvent>(_onSelectAuditLog);
    on<LoadAuditLogDetailsEvent>(_onLoadAuditLogDetails);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  /// Loads the first page of audit logs for the supplied query and resets paging flags.
  /// يحمّل الصفحة الأولى من سجلات التدقيق للاستعلام المعطى ويعيد ضبط أعلام التصفح.
  Future<void> _onLoadAuditLogs(
    LoadAuditLogsEvent event,
    Emitter<AuditLogsState> emit,
  ) async {
    _isLoadingMore = false;
    _loadMoreCooldownUntil = null;
    _isLoadMoreRetryScheduled = false;
    _hasQueuedLoadMoreRequest = false;
    emit(AuditLogsLoading());

    final query = event.query.copyWith(
      pageNumber: event.query.pageNumber ?? 1,
      pageSize: event.query.pageSize ?? _pageSize,
    );

    final result = await getAuditLogsUseCase(query);

    result.fold(
      (failure) => emit(AuditLogsError(message: failure.message)),
      (paginatedResult) {
        final effectivePageSize = _resolvePageSize(
          requestedPageSize: query.pageSize,
          serverPageSize: paginatedResult.pageSize,
        );
        final hasReachedMax = _computeHasReachedMax(
          loadedItemsCount: paginatedResult.items.length,
          lastPageItemCount: paginatedResult.items.length,
          totalCount: paginatedResult.totalCount,
          pageSize: effectivePageSize,
        );

        emit(AuditLogsLoaded(
          auditLogs: paginatedResult.items,
          totalCount: paginatedResult.totalCount,
          currentPage: paginatedResult.pageNumber,
          pageSize: effectivePageSize,
          hasReachedMax: hasReachedMax,
          currentQuery: query,
        ));
      },
    );
  }

  /// Appends the next page of audit logs while preserving existing items and selection state.
  /// يضيف الصفحة التالية من سجلات التدقيق مع الحفاظ على العناصر والحالة المختارة الحالية.
  Future<void> _onLoadMoreAuditLogs(
    LoadMoreAuditLogsEvent event,
    Emitter<AuditLogsState> emit,
  ) async {
    if (state is! AuditLogsLoaded) return;

    final currentState = state as AuditLogsLoaded;
    if (currentState.hasReachedMax) return;

    if (_isLoadingMore) {
      _hasQueuedLoadMoreRequest = true;
      return;
    }

    final now = DateTime.now();
    if (_loadMoreCooldownUntil != null &&
        now.isBefore(_loadMoreCooldownUntil!)) {
      _hasQueuedLoadMoreRequest = true;
      _scheduleQueuedLoadMore(
        _loadMoreCooldownUntil!.difference(now),
      );
      return;
    }

    _hasQueuedLoadMoreRequest = false;
    _isLoadingMore = true;
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final query = currentState.currentQuery.copyWith(pageNumber: nextPage);

    final result = await getAuditLogsUseCase(query);

    result.fold(
      (failure) {
        final failureMessage = failure.message.toLowerCase();
        if (_isRateLimitFailure(failureMessage)) {
          _loadMoreCooldownUntil =
              DateTime.now().add(_loadMoreRateLimitCooldown);
          _hasQueuedLoadMoreRequest = true;
          _scheduleQueuedLoadMore(_loadMoreRateLimitCooldown);
        }
        // Keep already loaded items; avoid switching full page to error state.
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginatedResult) {
        _loadMoreCooldownUntil = null;

        final existingIds = currentState.auditLogs.map((log) => log.id).toSet();
        final uniqueNewItems = paginatedResult.items
            .where((log) => !existingIds.contains(log.id))
            .toList();
        final mergedItems = <AuditLog>[
          ...currentState.auditLogs,
          ...uniqueNewItems,
        ];

        final effectivePageSize = _resolvePageSize(
          requestedPageSize: currentState.pageSize,
          serverPageSize: paginatedResult.pageSize,
        );
        final hasReachedMax = _computeHasReachedMax(
          loadedItemsCount: mergedItems.length,
          lastPageItemCount: paginatedResult.items.length,
          totalCount: paginatedResult.totalCount,
          pageSize: effectivePageSize,
        );

        emit(currentState.copyWith(
          auditLogs: mergedItems,
          totalCount: paginatedResult.totalCount,
          currentPage: paginatedResult.pageNumber > 0
              ? paginatedResult.pageNumber
              : nextPage,
          pageSize: effectivePageSize,
          hasReachedMax: hasReachedMax,
          isLoadingMore: false,
        ));
      },
    );

    _isLoadingMore = false;

    if (_hasQueuedLoadMoreRequest) {
      final delay = _loadMoreCooldownUntil == null
          ? _queuedLoadMoreDelay
          : _loadMoreCooldownUntil!.difference(DateTime.now());
      _scheduleQueuedLoadMore(delay);
    }
  }

  /// Replays the current query when the user asks for a fresh refresh from the UI.
  /// يعيد تنفيذ الاستعلام الحالي عندما يطلب المستخدم تحديثًا جديدًا من الواجهة.
  Future<void> _onRefreshAuditLogs(
    RefreshAuditLogsEvent event,
    Emitter<AuditLogsState> emit,
  ) async {
    if (state is AuditLogsLoaded) {
      final currentState = state as AuditLogsLoaded;
      add(LoadAuditLogsEvent(query: currentState.currentQuery));
    } else {
      add(const LoadAuditLogsEvent(query: AuditLogsQuery()));
    }
  }

  /// Builds a query from the provided filters and restarts loading from the first page.
  /// يبني استعلامًا من الفلاتر المعطاة ويعيد التحميل من الصفحة الأولى.
  Future<void> _onFilterAuditLogs(
    FilterAuditLogsEvent event,
    Emitter<AuditLogsState> emit,
  ) async {
    final query = AuditLogsQuery(
      pageNumber: 1,
      pageSize: _pageSize,
      userId: event.userId,
      from: event.from,
      to: event.to,
      operationType: event.operationType,
      searchTerm: event.searchTerm,
    );

    add(LoadAuditLogsEvent(query: query));
  }

  /// Exports the current audit-log query and emits either the exported data or an error.
  /// يصدّر استعلام سجلات التدقيق الحالي ويصدر البيانات المصدّرة أو حالة خطأ.
  Future<void> _onExportAuditLogs(
    ExportAuditLogsEvent event,
    Emitter<AuditLogsState> emit,
  ) async {
    emit(AuditLogsExporting());

    final result = await exportAuditLogsUseCase(event.query);

    result.fold(
      (failure) => emit(AuditLogsError(message: failure.message)),
      (logs) => emit(AuditLogsExported(exportedLogs: logs)),
    );
  }

  /// Stores the chosen audit log so details panels can react to the selection.
  /// يخزن سجل التدقيق المختار حتى تستجيب لوحات التفاصيل للاختيار.
  void _onSelectAuditLog(
    SelectAuditLogEvent event,
    Emitter<AuditLogsState> emit,
  ) {
    if (state is AuditLogsLoaded) {
      final currentState = state as AuditLogsLoaded;
      emit(currentState.copyWith(selectedLog: event.auditLog));
    }
  }

  /// Loads full details for one audit log when the repository is available.
  /// يحمّل التفاصيل الكاملة لسجل تدقيق واحد عندما يكون المستودع متاحًا.
  Future<void> _onLoadAuditLogDetails(
    LoadAuditLogDetailsEvent event,
    Emitter<AuditLogsState> emit,
  ) async {
    if (auditLogsRepository == null) return;
    if (state is! AuditLogsLoaded) return;
    final currentState = state as AuditLogsLoaded;
    emit(currentState.copyWith(loadingDetails: true));
    final result =
        await auditLogsRepository!.getAuditLogDetails(event.auditLogId);
    result.fold(
      (_) => emit(currentState.copyWith(loadingDetails: false)),
      (log) =>
          emit(currentState.copyWith(selectedLog: log, loadingDetails: false)),
    );
  }

  /// Clears all filters by starting over with a default empty query.
  /// يمسح جميع الفلاتر عبر البدء من جديد باستعلام افتراضي فارغ.
  void _onClearFilters(
    ClearFiltersEvent event,
    Emitter<AuditLogsState> emit,
  ) {
    add(const LoadAuditLogsEvent(query: AuditLogsQuery()));
  }

  /// Detects rate-limit style failures so load-more retries can be delayed safely.
  /// يكتشف أخطاء تحديد المعدل حتى يمكن تأخير إعادة محاولة تحميل المزيد بأمان.
  bool _isRateLimitFailure(String message) {
    return message.contains('429') ||
        message.contains('too many requests') ||
        message.contains('rate limit');
  }

  /// Chooses the best page size between the requested value, server echo, and fallback default.
  /// يختار أفضل حجم للصفحة بين القيمة المطلوبة واستجابة الخادم والقيمة الافتراضية.
  int _resolvePageSize({
    required int? requestedPageSize,
    required int serverPageSize,
  }) {
    if (serverPageSize > 0) return serverPageSize;
    if (requestedPageSize != null && requestedPageSize > 0) {
      return requestedPageSize;
    }
    return _pageSize;
  }

  /// Determines whether the current set of items has reached the end of the dataset.
  /// يحدد ما إذا كانت العناصر الحالية وصلت إلى نهاية مجموعة البيانات.
  bool _computeHasReachedMax({
    required int loadedItemsCount,
    required int lastPageItemCount,
    required int totalCount,
    required int pageSize,
  }) {
    if (lastPageItemCount <= 0) return true;

    if (totalCount > 0) {
      return loadedItemsCount >= totalCount;
    }

    return lastPageItemCount < pageSize;
  }

  /// Schedules a queued load-more request after the requested delay if one is still needed.
  /// يجدول طلب تحميل المزيد المؤجل بعد المهلة المطلوبة إذا كان ما يزال مطلوبًا.
  void _scheduleQueuedLoadMore(Duration delay) {
    if (_isLoadMoreRetryScheduled) return;

    final safeDelay = delay.isNegative ? Duration.zero : delay;
    _isLoadMoreRetryScheduled = true;

    Future<void>.delayed(safeDelay, () {
      _isLoadMoreRetryScheduled = false;
      if (isClosed) return;

      final currentState = state;
      if (currentState is! AuditLogsLoaded) return;
      if (currentState.hasReachedMax || currentState.isLoadingMore) return;

      add(const LoadMoreAuditLogsEvent());
    });
  }
}

/// Convenience extension that copies an audit-log query while overriding only selected fields.
/// امتداد مساعد ينسخ استعلام سجلات التدقيق مع استبدال الحقول المطلوبة فقط.
extension on AuditLogsQuery {
  /// Returns a new query value with any supplied fields replaced.
  /// يعيد قيمة استعلام جديدة مع استبدال أي حقول معطاة.
  AuditLogsQuery copyWith({
    int? pageNumber,
    int? pageSize,
    String? userId,
    DateTime? from,
    DateTime? to,
    String? searchTerm,
    String? operationType,
    String? entityType,
    String? recordId,
    String? relatedToBookingId,
  }) {
    return AuditLogsQuery(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      userId: userId ?? this.userId,
      from: from ?? this.from,
      to: to ?? this.to,
      searchTerm: searchTerm ?? this.searchTerm,
      operationType: operationType ?? this.operationType,
      entityType: entityType ?? this.entityType,
      recordId: recordId ?? this.recordId,
      relatedToBookingId: relatedToBookingId ?? this.relatedToBookingId,
    );
  }
}
