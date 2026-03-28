// lib/features/admin_daily_schedule/presentation/bloc/daily_schedule/daily_schedule_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/daily_schedule.dart';
import '../../../domain/entities/monthly_schedule.dart';
import '../../../domain/entities/schedule_params.dart';
import '../../../domain/usecases/get_monthly_schedule.dart';
import '../../../domain/usecases/update_schedule.dart';
import '../../../domain/usecases/bulk_update_schedule.dart';
import '../../../domain/usecases/check_availability.dart';
import '../../../domain/usecases/calculate_total_price.dart';
import '../../../domain/usecases/clone_schedule.dart';
import '../../../domain/usecases/delete_schedule.dart';
import '../../../../../core/error/failures.dart';

part 'daily_schedule_event.dart';
part 'daily_schedule_state.dart';

/// يدير تدفق الجدول اليومي من التحميل حتى التحديث والتحقق والنسخ والحذف.
class DailyScheduleBloc extends Bloc<DailyScheduleEvent, DailyScheduleState> {
  /// يجلب الجدول الشهري من طبقة الاستخدامات.
  final GetMonthlyScheduleUseCase getMonthlyScheduleUseCase;

  /// يحدث إتاحة أو تسعير يوم أو فترة محددة.
  final UpdateScheduleUseCase updateScheduleUseCase;

  /// ينفذ التحديثات الجماعية على نطاق أيام متكرر.
  final BulkUpdateScheduleUseCase bulkUpdateScheduleUseCase;

  /// يتحقق من توفر الوحدة في فترة محددة.
  final CheckAvailabilityUseCase checkAvailabilityUseCase;

  /// يحسب السعر الإجمالي بناءً على أيام ونوع التسعير.
  final CalculateTotalPriceUseCase calculateTotalPriceUseCase;

  /// ينسخ جدولًا من نطاق إلى نطاق آخر.
  final CloneScheduleUseCase cloneScheduleUseCase;

  /// يحذف جدولًا يوميًا محددًا.
  final DeleteScheduleUseCase deleteScheduleUseCase;

  /// يبني البلوك مع الاعتماديات التي يحتاجها لتنفيذ أوامر الجدول.
  DailyScheduleBloc({
    required this.getMonthlyScheduleUseCase,
    required this.updateScheduleUseCase,
    required this.bulkUpdateScheduleUseCase,
    required this.checkAvailabilityUseCase,
    required this.calculateTotalPriceUseCase,
    required this.cloneScheduleUseCase,
    required this.deleteScheduleUseCase,
  }) : super(const DailyScheduleInitial()) {
    // تسجيل معالجات الأحداث
    on<LoadMonthlyScheduleEvent>(_onLoadMonthlySchedule);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<SelectUnitEvent>(_onSelectUnit);
    on<UpdateSingleDayEvent>(_onUpdateSingleDay);
    on<UpdateDateRangeEvent>(_onUpdateDateRange);
    on<BulkUpdateScheduleEvent>(_onBulkUpdateSchedule);
    on<CheckAvailabilityEvent>(_onCheckAvailability);
    on<CalculateTotalPriceEvent>(_onCalculateTotalPrice);
    on<CloneScheduleEvent>(_onCloneSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
    on<ResetErrorEvent>(_onResetError);
    on<FilterScheduleEvent>(_onFilterSchedule);
  }

  // ===== Event Handlers =====

  /// يحمّل جدول الشهر المطلوب ويحوّل النتيجة إلى حالة جاهزة للعرض.
  Future<void> _onLoadMonthlySchedule(
    LoadMonthlyScheduleEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    // Debug: تتبع حدث تحميل الجدول الشهري
    // (يمكن إزالة هذه الطباعات بعد التأكد من عمل الشاشة)
    // ignore: avoid_print
    print('[DailyScheduleBloc] Loading monthly schedule for unit '
        '${event.unitId}, year=${event.year}, month=${event.month}');
    emit(const DailyScheduleLoading(loadingMessage: 'جاري تحميل الجدول...'));

    final params = GetMonthlyScheduleParams(
      unitId: event.unitId,
      year: event.year,
      month: event.month,
    );

    final result = await getMonthlyScheduleUseCase(params);

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        // ignore: avoid_print
        print('[DailyScheduleBloc] Failed to load monthly schedule: '
            '$message');
        emit(DailyScheduleError(
          errorMessage: message,
        ));
      },
      (monthlySchedule) {
        // ignore: avoid_print
        print('[DailyScheduleBloc] Monthly schedule loaded: '
            '${monthlySchedule.schedules.length} days');
        emit(DailyScheduleLoaded(
          monthlySchedule: monthlySchedule,
          selectedUnitId: event.unitId,
          currentYear: event.year,
          currentMonth: event.month,
        ));
      },
    );
  }

  /// يعيد تحميل الجدول عند الانتقال إلى شهر آخر.
  Future<void> _onChangeMonth(
    ChangeMonthEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is DailyScheduleLoaded) {
      final currentState = state as DailyScheduleLoaded;
      final unitId = currentState.selectedUnitId;

      if (unitId == null) {
        emit(const DailyScheduleError(
          errorMessage: 'لم يتم اختيار وحدة',
        ));
        return;
      }

      add(LoadMonthlyScheduleEvent(
        unitId: unitId,
        year: event.year,
        month: event.month,
      ));
    }
  }

  /// يبدل الوحدة الحالية ثم يحمّل جدولها الشهري.
  Future<void> _onSelectUnit(
    SelectUnitEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    // إذا كانت هناك حالة محملة، نستخدم الشهر والسنة الحالية منها
    if (state is DailyScheduleLoaded) {
      final currentState = state as DailyScheduleLoaded;
      year = currentState.currentYear;
      month = currentState.currentMonth;
    }

    add(LoadMonthlyScheduleEvent(
      unitId: event.unitId,
      year: year,
      month: month,
    ));
  }

  /// يحدث يومًا واحدًا ثم يعيد مزامنة الجدول.
  Future<void> _onUpdateSingleDay(
    UpdateSingleDayEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(DailyScheduleUpdating(
      currentSchedule: currentState.monthlySchedule,
      updatingMessage: 'جاري تحديث اليوم...',
    ));

    // بناء معاملات التحديث
    final params = UpdateScheduleParams(
      unitId: event.unitId,
      startDate: event.date,
      endDate: event.date,
      status: event.status,
      reason: event.reason,
      notes: event.notes,
      priceAmount: event.priceAmount,
      currency: event.currency,
      priceType: event.priceType,
      pricingTier: event.pricingTier,
      overwriteExisting: event.overwriteExisting,
    );

    final result = await updateScheduleUseCase(params);

    result.fold(
      (failure) {
        emit(DailyScheduleError(
          errorMessage: _mapFailureToMessage(failure),
          lastSchedule: currentState.monthlySchedule,
        ));
      },
      (affectedDays) {
        // إعادة تحميل الجدول بعد التحديث الناجح
        _reloadCurrentSchedule(currentState);
      },
    );
  }

  /// معالج حدث تحديث فترة
  ///
  /// يقوم بتحديث إتاحة و/أو تسعير فترة زمنية محددة
  Future<void> _onUpdateDateRange(
    UpdateDateRangeEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(DailyScheduleUpdating(
      currentSchedule: currentState.monthlySchedule,
      updatingMessage: 'جاري تحديث الفترة...',
    ));

    final result = await updateScheduleUseCase(event.params);

    result.fold(
      (failure) => emit(DailyScheduleError(
        errorMessage: _mapFailureToMessage(failure),
        lastSchedule: currentState.monthlySchedule,
      )),
      (affectedDays) {
        // إعادة تحميل الجدول بعد التحديث الناجح
        _reloadCurrentSchedule(currentState);
      },
    );
  }

  /// معالج حدث التحديث الجماعي
  ///
  /// يقوم بالتحديث الجماعي بناءً على أيام الأسبوع المحددة
  Future<void> _onBulkUpdateSchedule(
    BulkUpdateScheduleEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(DailyScheduleUpdating(
      currentSchedule: currentState.monthlySchedule,
      updatingMessage: 'جاري التحديث الجماعي...',
    ));

    final result = await bulkUpdateScheduleUseCase(event.params);

    result.fold(
      (failure) {
        emit(DailyScheduleError(
          errorMessage: _mapFailureToMessage(failure),
          lastSchedule: currentState.monthlySchedule,
        ));
      },
      (affectedDays) {
        // إعادة تحميل الجدول بعد التحديث الناجح
        _reloadCurrentSchedule(currentState);
      },
    );
  }

  /// معالج حدث التحقق من التوفر
  ///
  /// يقوم بالتحقق من توفر الوحدة لفترة محددة
  Future<void> _onCheckAvailability(
    CheckAvailabilityEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(const DailyScheduleLoading(
      loadingMessage: 'جاري التحقق من التوفر...',
    ));

    final result = await checkAvailabilityUseCase(event.params);

    result.fold(
      (failure) {
        emit(DailyScheduleError(
          errorMessage: _mapFailureToMessage(failure),
          lastSchedule: currentState.monthlySchedule,
        ));
      },
      (availabilityResponse) {
        emit(currentState.copyWith(
          availabilityCheckResult: availabilityResponse,
        ));
      },
    );
  }

  /// معالج حدث حساب السعر الإجمالي
  ///
  /// يقوم بحساب السعر الإجمالي لفترة محددة
  Future<void> _onCalculateTotalPrice(
    CalculateTotalPriceEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(const DailyScheduleLoading(
      loadingMessage: 'جاري حساب السعر الإجمالي...',
    ));

    final params = CalculateTotalPriceParams(
      unitId: event.unitId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    final result = await calculateTotalPriceUseCase(params);

    result.fold(
      (failure) {
        emit(DailyScheduleError(
          errorMessage: _mapFailureToMessage(failure),
          lastSchedule: currentState.monthlySchedule,
        ));
      },
      (totalPrice) {
        emit(currentState.copyWith(
          calculatedPrice: totalPrice,
        ));
      },
    );
  }

  /// معالج حدث نسخ الجدول
  ///
  /// يقوم بنسخ جدول من فترة إلى فترة أخرى
  Future<void> _onCloneSchedule(
    CloneScheduleEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(DailyScheduleUpdating(
      currentSchedule: currentState.monthlySchedule,
      updatingMessage: 'جاري نسخ الجدول...',
    ));

    final result = await cloneScheduleUseCase(event.params);

    result.fold(
      (failure) {
        emit(DailyScheduleError(
          errorMessage: _mapFailureToMessage(failure),
          lastSchedule: currentState.monthlySchedule,
        ));
      },
      (affectedDays) {
        // إعادة تحميل الجدول بعد النسخ الناجح
        _reloadCurrentSchedule(currentState);
      },
    );
  }

  /// معالج حدث حذف الجدول
  ///
  /// يقوم بحذف جدول لفترة محددة
  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(DailyScheduleUpdating(
      currentSchedule: currentState.monthlySchedule,
      updatingMessage: 'جاري حذف الجدول...',
    ));

    final result = await deleteScheduleUseCase(event.params);

    result.fold(
      (failure) {
        emit(DailyScheduleError(
          errorMessage: _mapFailureToMessage(failure),
          lastSchedule: currentState.monthlySchedule,
        ));
      },
      (affectedDays) {
        // إعادة تحميل الجدول بعد الحذف الناجح
        _reloadCurrentSchedule(currentState);
      },
    );
  }

  /// معالج حدث إعادة تعيين حالة الأخطاء
  ///
  /// يعيد BLoC إلى الحالة الأولية
  Future<void> _onResetError(
    ResetErrorEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    emit(const DailyScheduleInitial());
  }

  /// معالج حدث تصفية الجدول
  ///
  /// يقوم بتصفية الجدول حسب حالة الإتاحة
  Future<void> _onFilterSchedule(
    FilterScheduleEvent event,
    Emitter<DailyScheduleState> emit,
  ) async {
    if (state is! DailyScheduleLoaded) return;

    final currentState = state as DailyScheduleLoaded;

    emit(currentState.copyWith(
      currentFilter: event.filterStatus,
      clearFilter: event.filterStatus == null,
    ));
  }

  // ===== Helper Methods =====

  /// تحويل Failure إلى رسالة خطأ باللغة العربية
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'حدث خطأ في الاتصال بالخادم';
    } else if (failure is NetworkFailure) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (failure is ValidationFailure) {
      return failure.message.isNotEmpty ? failure.message : 'بيانات غير صالحة';
    } else if (failure is CacheFailure) {
      return 'حدث خطأ في التخزين المؤقت';
    } else if (failure is UnauthorizedFailure) {
      return 'غير مصرح لك بهذا الإجراء';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }

  /// إعادة تحميل الجدول الحالي بعد عملية ناجحة
  void _reloadCurrentSchedule(DailyScheduleLoaded currentState) {
    add(LoadMonthlyScheduleEvent(
      unitId: currentState.selectedUnitId!,
      year: currentState.currentYear,
      month: currentState.currentMonth,
    ));
  }
}
