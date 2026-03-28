import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/booking_report.dart';
import '../../../domain/entities/booking_trends.dart';
import '../../../domain/entities/booking_window_analysis.dart';
import '../../../domain/usecases/reports/get_booking_report_usecase.dart';
import '../../../domain/usecases/reports/get_booking_trends_usecase.dart';
import '../../../domain/usecases/reports/get_booking_window_analysis_usecase.dart';
import 'booking_analytics_event.dart';
import 'booking_analytics_state.dart';

/// العربية: يدير تحميل التقارير والاتجاهات وتحليل نافذة الحجز ومقارنة الفترات.
/// English: Manages report loading, trend loading, window analysis, and period comparison.
class BookingAnalyticsBloc
    extends Bloc<BookingAnalyticsEvent, BookingAnalyticsState> {
  /// العربية: يجلب ملخص تقرير الحجوزات للفترة المطلوبة.
  /// English: Fetches the booking report summary for the requested range.
  final GetBookingReportUseCase getBookingReportUseCase;

  /// العربية: يجلب بيانات الاتجاهات الخاصة بالحجوزات.
  /// English: Fetches booking trend data.
  final GetBookingTrendsUseCase getBookingTrendsUseCase;

  /// العربية: يجلب تحليل نافذة الحجز عندما يكون العقار محددًا.
  /// English: Fetches booking window analysis when a property is selected.
  final GetBookingWindowAnalysisUseCase getBookingWindowAnalysisUseCase;

  /// العربية: بداية الفترة الحالية المستخدمة عند التحديث أو المقارنة.
  /// English: The current period start reused by refresh or comparison actions.
  DateTime _currentStartDate =
      DateTime.now().subtract(const Duration(days: 30));

  /// العربية: نهاية الفترة الحالية المستخدمة عند التحديث أو المقارنة.
  /// English: The current period end reused by refresh or comparison actions.
  DateTime _currentEndDate = DateTime.now();

  /// العربية: العقار النشط الذي تُحسب عليه التحليلات عند وجوده.
  /// English: The active property scope used for analytics when present.
  String? _currentPropertyId;

  /// العربية: الفترة الزمنية النشطة في الواجهة.
  /// English: The active time period shown in the UI.
  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.month;

  /// العربية: ينشئ BLoC التحليلات ويربط الأحداث بمعالجاتها.
  /// English: Creates the analytics bloc and wires events to their handlers.
  BookingAnalyticsBloc({
    required this.getBookingReportUseCase,
    required this.getBookingTrendsUseCase,
    required this.getBookingWindowAnalysisUseCase,
  }) : super(BookingAnalyticsInitial()) {
    on<LoadBookingAnalyticsEvent>(_onLoadBookingAnalytics);
    on<RefreshAnalyticsEvent>(_onRefreshAnalytics);
    on<ChangePeriodEvent>(_onChangePeriod);
    on<ChangePropertyFilterEvent>(_onChangePropertyFilter);
    on<LoadBookingReportEvent>(_onLoadBookingReport);
    on<LoadBookingTrendsEvent>(_onLoadBookingTrends);
    on<LoadBookingWindowAnalysisEvent>(_onLoadBookingWindowAnalysis);
    on<ExportAnalyticsReportEvent>(_onExportAnalyticsReport);
    on<ComparePeriodsEvent>(_onComparePeriods);
  }

  /// العربية: يجلب التقرير والاتجاهات وتحليل النافذة ثم يبني حالة التحليلات المكتملة.
  /// English: Loads the report, trends, and window analysis before building the full analytics state.
  Future<void> _onLoadBookingAnalytics(
    LoadBookingAnalyticsEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    emit(BookingAnalyticsLoading());

    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    _currentPropertyId = event.propertyId;

    try {
      // تحميل التقرير
      final reportResult = await getBookingReportUseCase(
        GetBookingReportParams(
          startDate: event.startDate,
          endDate: event.endDate,
          propertyId: event.propertyId,
        ),
      );

      // تحميل الاتجاهات
      final trendsResult = await getBookingTrendsUseCase(
        GetBookingTrendsParams(
          startDate: event.startDate,
          endDate: event.endDate,
          propertyId: event.propertyId,
        ),
      );

      // تحميل تحليل نافذة الحجز (إذا كان هناك propertyId)
      BookingWindowAnalysis? windowAnalysis;
      if (event.propertyId != null) {
        final windowResult = await getBookingWindowAnalysisUseCase(
          GetBookingWindowAnalysisParams(propertyId: event.propertyId!),
        );
        windowAnalysis = windowResult.fold(
          (_) => null,
          (analysis) => analysis,
        );
      }

      // معالجة النتائج
      BookingReport? report;
      BookingTrends? trends;
      String? errorMessage;

      reportResult.fold(
        (failure) => errorMessage = failure.message,
        (r) => report = r,
      );

      trendsResult.fold(
        (failure) => errorMessage ??= failure.message,
        (t) => trends = t,
      );

      if (report != null && trends != null) {
        emit(BookingAnalyticsLoaded(
          report: report!,
          trends: trends!,
          windowAnalysis: windowAnalysis,
          startDate: event.startDate,
          endDate: event.endDate,
          propertyId: event.propertyId,
          currentPeriod: _currentPeriod,
        ));
      } else {
        emit(BookingAnalyticsError(
          message: errorMessage ?? 'فشل تحميل التحليلات',
        ));
      }
    } catch (e) {
      emit(BookingAnalyticsError(message: e.toString()));
    }
  }

  /// العربية: يعيد تحميل التحليلات باستخدام آخر فترة وعقار محفوظين.
  /// English: Reloads analytics using the last saved period and property scope.
  Future<void> _onRefreshAnalytics(
    RefreshAnalyticsEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    add(LoadBookingAnalyticsEvent(
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      propertyId: _currentPropertyId,
    ));
  }

  /// العربية: يغيّر الفترة المختارة ثم يحسب نطاقًا زمنيًا مناسبًا لها.
  /// English: Changes the selected period and recalculates a matching date range.
  Future<void> _onChangePeriod(
    ChangePeriodEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    _currentPeriod = event.period;

    final dateRange = _calculateDateRangeForPeriod(event.period);

    add(LoadBookingAnalyticsEvent(
      startDate: dateRange.start,
      endDate: dateRange.end,
      propertyId: _currentPropertyId,
    ));
  }

  /// العربية: يبدّل العقار النشط ثم يعيد تحميل التحليلات ضمن نفس الفترة.
  /// English: Switches the active property and reloads analytics for the same period.
  Future<void> _onChangePropertyFilter(
    ChangePropertyFilterEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    _currentPropertyId = event.propertyId;

    add(LoadBookingAnalyticsEvent(
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      propertyId: event.propertyId,
    ));
  }

  /// العربية: يعيد تحميل التقرير فقط مع الحفاظ على بقية البيانات الحالية.
  /// English: Reloads only the report while keeping the rest of the current data.
  Future<void> _onLoadBookingReport(
    LoadBookingReportEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    if (state is BookingAnalyticsLoaded) {
      final currentState = state as BookingAnalyticsLoaded;
      emit(currentState.copyWith(isLoadingReport: true));

      final result = await getBookingReportUseCase(
        GetBookingReportParams(
          startDate: event.startDate,
          endDate: event.endDate,
          propertyId: event.propertyId,
        ),
      );

      result.fold(
        (failure) => emit(BookingAnalyticsError(message: failure.message)),
        (report) => emit(currentState.copyWith(
          report: report,
          isLoadingReport: false,
        )),
      );
    }
  }

  /// العربية: يعيد تحميل الاتجاهات فقط مع الحفاظ على بقية بيانات التحليلات.
  /// English: Reloads only the trends while preserving the rest of the analytics data.
  Future<void> _onLoadBookingTrends(
    LoadBookingTrendsEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    if (state is BookingAnalyticsLoaded) {
      final currentState = state as BookingAnalyticsLoaded;
      emit(currentState.copyWith(isLoadingTrends: true));

      final result = await getBookingTrendsUseCase(
        GetBookingTrendsParams(
          startDate: event.startDate,
          endDate: event.endDate,
          propertyId: event.propertyId,
        ),
      );

      result.fold(
        (failure) => emit(BookingAnalyticsError(message: failure.message)),
        (trends) => emit(currentState.copyWith(
          trends: trends,
          isLoadingTrends: false,
        )),
      );
    }
  }

  /// العربية: يعيد تحميل تحليل نافذة الحجز فقط عندما يكون هناك حالة مكتملة.
  /// English: Reloads only the booking window analysis when a loaded state is available.
  Future<void> _onLoadBookingWindowAnalysis(
    LoadBookingWindowAnalysisEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    if (state is BookingAnalyticsLoaded) {
      final currentState = state as BookingAnalyticsLoaded;
      emit(currentState.copyWith(isLoadingWindowAnalysis: true));

      final result = await getBookingWindowAnalysisUseCase(
        GetBookingWindowAnalysisParams(propertyId: event.propertyId),
      );

      result.fold(
        (failure) => emit(BookingAnalyticsError(message: failure.message)),
        (analysis) => emit(currentState.copyWith(
          windowAnalysis: analysis,
          isLoadingWindowAnalysis: false,
        )),
      );
    }
  }

  /// العربية: يحاكي أو ينفذ تصدير التقرير ثم يعيد حالة العرض الأصلية بعد الانتهاء.
  /// English: Simulates or performs the export and then restores the original view state.
  Future<void> _onExportAnalyticsReport(
    ExportAnalyticsReportEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    if (state is BookingAnalyticsLoaded) {
      final currentState = state as BookingAnalyticsLoaded;
      emit(BookingAnalyticsExporting(
        report: currentState.report,
        trends: currentState.trends,
        windowAnalysis: currentState.windowAnalysis,
        format: event.format,
      ));

      // تنفيذ منطق التصدير
      await Future.delayed(const Duration(seconds: 2));

      emit(BookingAnalyticsExportSuccess(
        report: currentState.report,
        trends: currentState.trends,
        windowAnalysis: currentState.windowAnalysis,
        message: 'تم تصدير التقرير بنجاح',
      ));

      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  /// العربية: يجلب تقريري فترتين مختلفتين ثم ينتج مقارنة مباشرة بينهما.
  /// English: Fetches two period reports and produces a direct comparison between them.
  Future<void> _onComparePeriods(
    ComparePeriodsEvent event,
    Emitter<BookingAnalyticsState> emit,
  ) async {
    emit(BookingAnalyticsLoading());

    try {
      // تحميل بيانات الفترة الأولى
      final period1ReportResult = await getBookingReportUseCase(
        GetBookingReportParams(
          startDate: event.period1Start,
          endDate: event.period1End,
          propertyId: _currentPropertyId,
        ),
      );

      // تحميل بيانات الفترة الثانية
      final period2ReportResult = await getBookingReportUseCase(
        GetBookingReportParams(
          startDate: event.period2Start,
          endDate: event.period2End,
          propertyId: _currentPropertyId,
        ),
      );

      BookingReport? period1Report;
      BookingReport? period2Report;

      period1ReportResult.fold(
        (_) => {},
        (report) => period1Report = report,
      );

      period2ReportResult.fold(
        (_) => {},
        (report) => period2Report = report,
      );

      if (period1Report != null && period2Report != null) {
        final comparison = _compareReports(period1Report!, period2Report!);

        emit(BookingAnalyticsComparison(
          period1Report: period1Report!,
          period2Report: period2Report!,
          comparison: comparison,
          period1Start: event.period1Start,
          period1End: event.period1End,
          period2Start: event.period2Start,
          period2End: event.period2End,
        ));
      } else {
        emit(const BookingAnalyticsError(
          message: 'فشل تحميل بيانات المقارنة',
        ));
      }
    } catch (e) {
      emit(BookingAnalyticsError(message: e.toString()));
    }
  }

  /// العربية: يحول الفترة المختارة إلى نطاق تاريخ مناسب للتحميل من الخادم.
  /// English: Converts the selected period into a backend-friendly date range.
  DateRange _calculateDateRangeForPeriod(AnalyticsPeriod period) {
    final now = DateTime.now();
    DateTime start, end;

    switch (period) {
      case AnalyticsPeriod.day:
        start = DateTime(now.year, now.month, now.day);
        end = now;
        break;
      case AnalyticsPeriod.week:
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;
      case AnalyticsPeriod.month:
        start = DateTime(now.year, now.month - 1, now.day);
        end = now;
        break;
      case AnalyticsPeriod.quarter:
        start = DateTime(now.year, now.month - 3, now.day);
        end = now;
        break;
      case AnalyticsPeriod.year:
        start = DateTime(now.year - 1, now.month, now.day);
        end = now;
        break;
    }

    return DateRange(start: start, end: end);
  }

  /// العربية: يقارن بين ملخصي تقريرين ويعيد الفروقات الأساسية كنسب مئوية.
  /// English: Compares two report summaries and returns the main percentage deltas.
  Map<String, dynamic> _compareReports(
    BookingReport report1,
    BookingReport report2,
  ) {
    final comparison = <String, dynamic>{};

    // مقارنة إجمالي الحجوزات
    comparison['bookingsChange'] = _calculatePercentageChange(
      report1.summary.totalBookings.toDouble(),
      report2.summary.totalBookings.toDouble(),
    );

    // مقارنة الإيرادات
    comparison['revenueChange'] = _calculatePercentageChange(
      report1.summary.totalRevenue,
      report2.summary.totalRevenue,
    );

    // مقارنة معدل الإشغال
    comparison['occupancyChange'] = _calculatePercentageChange(
      report1.summary.occupancyRate,
      report2.summary.occupancyRate,
    );

    // مقارنة متوسط مدة الإقامة
    comparison['stayLengthChange'] = _calculatePercentageChange(
      report1.summary.averageStayLength,
      report2.summary.averageStayLength,
    );

    return comparison;
  }

  /// العربية: يحسب نسبة التغيّر بين قيمة قديمة وأخرى جديدة مع حماية من القسمة على صفر.
  /// English: Calculates percentage change between old and new values while guarding against division by zero.
  double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100 : 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
}

/// العربية: يمثل نطاقًا زمنيًا بسيطًا يستخدمه BLoC التحليلات عند طلب البيانات.
/// English: Represents a simple time range used by the analytics bloc when requesting data.
class DateRange {
  /// العربية: بداية النطاق الزمني.
  /// English: The start of the time range.
  final DateTime start;

  /// العربية: نهاية النطاق الزمني.
  /// English: The end of the time range.
  final DateTime end;

  /// العربية: ينشئ نطاق التاريخ من البداية إلى النهاية.
  /// English: Creates a date range from the start to the end.
  DateRange({required this.start, required this.end});
}
