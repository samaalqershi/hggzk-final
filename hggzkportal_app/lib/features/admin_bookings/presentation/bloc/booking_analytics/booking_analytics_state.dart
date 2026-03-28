import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_report.dart';
import '../../../domain/entities/booking_trends.dart';
import '../../../domain/entities/booking_window_analysis.dart';
import 'booking_analytics_event.dart';

/// العربية: يعرّف الحالات الخاصة بلوحة تحليلات الحجوزات وعمليات التحميل والمقارنة والتصدير.
/// English: Defines the booking-analytics dashboard states for loading, comparison, and export flows.
abstract class BookingAnalyticsState extends Equatable {
  /// العربية: ينشئ الأساس المشترك لحالات التحليلات.
  /// English: Creates the shared base for analytics states.
  const BookingAnalyticsState();

  /// العربية: لا توجد حقول مشتركة، وتُفوض المساواة للفئات الفرعية.
  /// English: No shared fields exist here, so equality is delegated to subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: تمثل الحالة قبل بدء تحميل أي بيانات تحليلية.
/// English: Represents the state before any analytics data has been loaded.
class BookingAnalyticsInitial extends BookingAnalyticsState {}

/// العربية: تشير إلى أن البيانات التحليلية قيد الجلب حاليًا.
/// English: Indicates that analytics data is currently being fetched.
class BookingAnalyticsLoading extends BookingAnalyticsState {}

/// العربية: تحمل نتائج التقرير والاتجاهات وتحليل نافذة الحجز مع مؤشرات التحميل.
/// English: Holds the report, trends, and window analysis results together with loading flags.
class BookingAnalyticsLoaded extends BookingAnalyticsState {
  /// العربية: ملخص تقرير الحجوزات الرئيسي.
  /// English: The main booking report summary.
  final BookingReport report;

  /// العربية: بيانات الاتجاهات الزمنية للحجوزات.
  /// English: Time-based booking trend data.
  final BookingTrends trends;

  /// العربية: تحليل نافذة الحجز عندما يكون متاحًا.
  /// English: Booking window analysis when available.
  final BookingWindowAnalysis? windowAnalysis;

  /// العربية: بداية الفترة الحالية المعروضة.
  /// English: The current displayed period start.
  final DateTime startDate;

  /// العربية: نهاية الفترة الحالية المعروضة.
  /// English: The current displayed period end.
  final DateTime endDate;

  /// العربية: العقار النشط الذي تُحسب عليه النتائج عند وجوده.
  /// English: The active property scope used for calculations when present.
  final String? propertyId;

  /// العربية: الفترة الزمنية المختارة حاليًا في اللوحة.
  /// English: The currently selected analytics period.
  final AnalyticsPeriod currentPeriod;

  /// العربية: يوضح ما إذا كان التقرير قيد التحديث منفصلًا عن بقية البيانات.
  /// English: Indicates whether the report section is loading independently.
  final bool isLoadingReport;

  /// العربية: يوضح ما إذا كانت الاتجاهات قيد التحديث منفصلًا.
  /// English: Indicates whether the trends section is loading independently.
  final bool isLoadingTrends;

  /// العربية: يوضح ما إذا كان تحليل نافذة الحجز قيد التحديث.
  /// English: Indicates whether the window analysis is loading independently.
  final bool isLoadingWindowAnalysis;

  /// العربية: ينشئ حالة التحليلات المكتملة مع بياناتها ومؤشرات تحميلها.
  /// English: Creates the fully loaded analytics state with its data and loading flags.
  const BookingAnalyticsLoaded({
    required this.report,
    required this.trends,
    this.windowAnalysis,
    required this.startDate,
    required this.endDate,
    this.propertyId,
    required this.currentPeriod,
    this.isLoadingReport = false,
    this.isLoadingTrends = false,
    this.isLoadingWindowAnalysis = false,
  });

  /// العربية: ينشئ نسخة معدلة مع إبقاء القيم غير المحددة كما هي.
  /// English: Creates a modified copy while preserving unspecified values.
  BookingAnalyticsLoaded copyWith({
    BookingReport? report,
    BookingTrends? trends,
    BookingWindowAnalysis? windowAnalysis,
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
    AnalyticsPeriod? currentPeriod,
    bool? isLoadingReport,
    bool? isLoadingTrends,
    bool? isLoadingWindowAnalysis,
  }) {
    return BookingAnalyticsLoaded(
      report: report ?? this.report,
      trends: trends ?? this.trends,
      windowAnalysis: windowAnalysis ?? this.windowAnalysis,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      propertyId: propertyId ?? this.propertyId,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      isLoadingReport: isLoadingReport ?? this.isLoadingReport,
      isLoadingTrends: isLoadingTrends ?? this.isLoadingTrends,
      isLoadingWindowAnalysis:
          isLoadingWindowAnalysis ?? this.isLoadingWindowAnalysis,
    );
  }

  /// العربية: يحسب مؤشرات الأداء الرئيسية المعروضة في واجهة التحليلات.
  /// English: Computes the KPI map shown in the analytics UI.
  Map<String, dynamic> get kpis {
    return {
      'totalBookings': report.summary.totalBookings,
      'totalRevenue': report.summary.totalRevenue,
      'averageBookingValue': report.summary.averageBookingValue,
      'occupancyRate': report.summary.occupancyRate,
      'averageStayLength': report.summary.averageStayLength,
      'growthRate': trends.analysis.growthRate,
      'trend': trends.analysis.trend,
      'averageLeadTime': windowAnalysis?.averageLeadTimeInDays ?? 0,
    };
  }

  /// العربية: يعتمد على البيانات الأساسية ومؤشرات التحميل والفترة المختارة.
  /// English: Uses the core data, loading flags, and selected period for equality.
  @override
  List<Object?> get props => [
        report,
        trends,
        windowAnalysis,
        startDate,
        endDate,
        propertyId,
        currentPeriod,
        isLoadingReport,
        isLoadingTrends,
        isLoadingWindowAnalysis,
      ];
}

/// العربية: تمثل فشلًا في جلب بيانات التحليلات أو معالجتها.
/// English: Represents a failure while loading or processing analytics data.
class BookingAnalyticsError extends BookingAnalyticsState {
  /// العربية: الرسالة الموجهة للمستخدم أو السجل التشخيصي.
  /// English: The message shown to the user or diagnostic log.
  final String message;

  /// العربية: ينشئ حالة الخطأ مع الرسالة التوضيحية.
  /// English: Creates the error state with its explanatory message.
  const BookingAnalyticsError({required this.message});

  /// العربية: يعتمد على رسالة الخطأ فقط.
  /// English: Uses the error message only for equality.
  @override
  List<Object> get props => [message];
}

/// العربية: تمثل أن التحليلات قيد التصدير بالصّيغة المختارة.
/// English: Represents analytics currently being exported in the chosen format.
class BookingAnalyticsExporting extends BookingAnalyticsState {
  /// العربية: ملخص التقرير الجاري تصديره.
  /// English: The report summary being exported.
  final BookingReport report;

  /// العربية: بيانات الاتجاهات المرافقة للتصدير.
  /// English: Trend data included in the export.
  final BookingTrends trends;

  /// العربية: تحليل نافذة الحجز إذا كان جزءًا من التصدير.
  /// English: Booking window analysis included when available.
  final BookingWindowAnalysis? windowAnalysis;

  /// العربية: صيغة التصدير المطلوبة.
  /// English: The requested export format.
  final ExportFormat format;

  /// العربية: ينشئ حالة التصدير الجارية.
  /// English: Creates the in-progress export state.
  const BookingAnalyticsExporting({
    required this.report,
    required this.trends,
    this.windowAnalysis,
    required this.format,
  });

  /// العربية: يعتمد على البيانات المصدّرة والصيغة المختارة.
  /// English: Uses the export data and selected format for equality.
  @override
  List<Object?> get props => [report, trends, windowAnalysis, format];
}

/// العربية: تمثل نجاح تصدير التحليلات مع رسالة تأكيد.
/// English: Represents a successful analytics export with a confirmation message.
class BookingAnalyticsExportSuccess extends BookingAnalyticsState {
  /// العربية: ملخص التقرير المصدّر.
  /// English: The exported report summary.
  final BookingReport report;

  /// العربية: بيانات الاتجاهات المرافقة للتصدير.
  /// English: Trend data included in the export.
  final BookingTrends trends;

  /// العربية: تحليل نافذة الحجز إذا كان ضمن المخرجات.
  /// English: Booking window analysis when part of the output.
  final BookingWindowAnalysis? windowAnalysis;

  /// العربية: الرسالة التي تؤكد نجاح التصدير.
  /// English: The message confirming export success.
  final String message;

  /// العربية: ينشئ حالة نجاح التصدير.
  /// English: Creates the export-success state.
  const BookingAnalyticsExportSuccess({
    required this.report,
    required this.trends,
    this.windowAnalysis,
    required this.message,
  });

  /// العربية: يعتمد على البيانات المصدّرة ورسالة النجاح.
  /// English: Uses the exported data and success message for equality.
  @override
  List<Object?> get props => [report, trends, windowAnalysis, message];
}

/// العربية: تمثل نتائج مقارنة بين فترتين تحليليتين.
/// English: Represents the results of comparing two analytics periods.
class BookingAnalyticsComparison extends BookingAnalyticsState {
  /// العربية: تقرير الفترة الأولى.
  /// English: The first period's report.
  final BookingReport period1Report;

  /// العربية: تقرير الفترة الثانية.
  /// English: The second period's report.
  final BookingReport period2Report;

  /// العربية: خريطة المقارنة التي تلخص الفروقات المحسوبة.
  /// English: The comparison map summarizing calculated deltas.
  final Map<String, dynamic> comparison;

  /// العربية: بداية الفترة الأولى.
  /// English: The start of the first period.
  final DateTime period1Start;

  /// العربية: نهاية الفترة الأولى.
  /// English: The end of the first period.
  final DateTime period1End;

  /// العربية: بداية الفترة الثانية.
  /// English: The start of the second period.
  final DateTime period2Start;

  /// العربية: نهاية الفترة الثانية.
  /// English: The end of the second period.
  final DateTime period2End;

  /// العربية: ينشئ حالة المقارنة بين الفترتين.
  /// English: Creates the comparison state for the two periods.
  const BookingAnalyticsComparison({
    required this.period1Report,
    required this.period2Report,
    required this.comparison,
    required this.period1Start,
    required this.period1End,
    required this.period2Start,
    required this.period2End,
  });

  /// Uses both reports, comparison metrics, and period ranges for equality.
  ///
  /// يعتمد على التقريرين ومؤشرات المقارنة ونطاقي الفترتين في المساواة القيمية.
  @override
  List<Object> get props => [
        period1Report,
        period2Report,
        comparison,
        period1Start,
        period1End,
        period2Start,
        period2End,
      ];
}
