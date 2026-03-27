// lib/features/admin_audit_logs/presentation/bloc/audit_logs_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/usecases/get_audit_logs_usecase.dart';
import '../../domain/usecases/export_audit_logs_usecase.dart';
import '../../domain/repositories/audit_logs_repository.dart';
import 'audit_logs_event.dart';
import 'audit_logs_state.dart';

class AuditLogsBloc extends Bloc<AuditLogsEvent, AuditLogsState> {
  final GetAuditLogsUseCase getAuditLogsUseCase;
  final ExportAuditLogsUseCase exportAuditLogsUseCase;
  final AuditLogsRepository? auditLogsRepository;

  static const int _pageSize = 20;
  static const Duration _loadMoreRateLimitCooldown = Duration(seconds: 3);
  static const Duration _queuedLoadMoreDelay = Duration(milliseconds: 400);
  bool _isLoadingMore = false;
  DateTime? _loadMoreCooldownUntil;
  bool _isLoadMoreRetryScheduled = false;
  bool _hasQueuedLoadMoreRequest = false;

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

  void _onSelectAuditLog(
    SelectAuditLogEvent event,
    Emitter<AuditLogsState> emit,
  ) {
    if (state is AuditLogsLoaded) {
      final currentState = state as AuditLogsLoaded;
      emit(currentState.copyWith(selectedLog: event.auditLog));
    }
  }

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

  void _onClearFilters(
    ClearFiltersEvent event,
    Emitter<AuditLogsState> emit,
  ) {
    add(const LoadAuditLogsEvent(query: AuditLogsQuery()));
  }

  bool _isRateLimitFailure(String message) {
    return message.contains('429') ||
        message.contains('too many requests') ||
        message.contains('rate limit');
  }

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

  // Extension method for AuditLogsQuery
}

extension on AuditLogsQuery {
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
