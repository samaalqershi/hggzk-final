import 'package:equatable/equatable.dart';

/// العربية: يعرّف جميع أحداث لوحة تحليلات الحجوزات من التحميل إلى المقارنة والتصدير.
/// English: Defines every booking-analytics action from loading and filtering to comparison and export.
abstract class BookingAnalyticsEvent extends Equatable {
  /// العربية: ينشئ الأساس المشترك لأحداث التحليلات.
  /// English: Creates the shared base for analytics events.
  const BookingAnalyticsEvent();

  /// العربية: لا توجد حقول مشتركة، لذا تعتمد المقارنة على الفئات الفرعية.
  /// English: No shared fields exist here, so equality is controlled by subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب تحميل التحليلات للفترة الزمنية المحددة مع فلتر عقار اختياري.
/// English: Requests analytics for a specific date range with an optional property filter.
class LoadBookingAnalyticsEvent extends BookingAnalyticsEvent {
  /// العربية: بداية فترة التحليل.
  /// English: The start of the analytics range.
  final DateTime startDate;

  /// العربية: نهاية فترة التحليل.
  /// English: The end of the analytics range.
  final DateTime endDate;

  /// العربية: معرّف العقار عند الحاجة لتضييق التحليلات عليه.
  /// English: Optional property identifier used to scope the analytics.
  final String? propertyId;

  /// العربية: ينشئ طلب تحميل التحليلات.
  /// English: Creates the analytics-load request.
  const LoadBookingAnalyticsEvent({
    required this.startDate,
    required this.endDate,
    this.propertyId,
  });

  /// العربية: يعتمد على الفترة والعقار في المقارنة القيمية.
  /// English: Uses the range and property scope in equality checks.
  @override
  List<Object?> get props => [startDate, endDate, propertyId];
}

/// العربية: يطلب إعادة تحميل بيانات التحليلات الحالية.
/// English: Requests a refresh of the current analytics data.
class RefreshAnalyticsEvent extends BookingAnalyticsEvent {
  /// العربية: ينشئ حدث التحديث بلا مدخلات إضافية.
  /// English: Creates the refresh event with no extra inputs.
  const RefreshAnalyticsEvent();
}

/// العربية: يغيّر الفترة الزمنية المختارة في لوحة التحليلات.
/// English: Changes the active time period in the analytics dashboard.
class ChangePeriodEvent extends BookingAnalyticsEvent {
  /// العربية: الفترة المطلوبة مثل اليوم أو الشهر أو السنة.
  /// English: The requested period such as day, month, or year.
  final AnalyticsPeriod period;

  /// العربية: ينشئ حدث تغيير الفترة.
  /// English: Creates the period-change event.
  const ChangePeriodEvent({required this.period});

  /// العربية: يعتمد على الفترة المختارة فقط.
  /// English: Uses the selected period only for equality.
  @override
  List<Object> get props => [period];
}

/// العربية: يغيّر العقار النشط المستخدم في حسابات التحليلات.
/// English: Changes the active property used for analytics calculations.
class ChangePropertyFilterEvent extends BookingAnalyticsEvent {
  /// العربية: معرّف العقار الجديد أو القيمة الفارغة لإلغاء التصفية.
  /// English: The new property id or null to clear the filter.
  final String? propertyId;

  /// العربية: ينشئ حدث تغيير فلتر العقار.
  /// English: Creates the property-filter change event.
  const ChangePropertyFilterEvent({this.propertyId});

  /// العربية: يعتمد على معرّف العقار فقط.
  /// English: Uses the property id only for equality.
  @override
  List<Object?> get props => [propertyId];
}

/// العربية: يطلب بيانات تقرير الحجوزات الخام للفترة المحددة.
/// English: Requests the raw booking report data for the selected range.
class LoadBookingReportEvent extends BookingAnalyticsEvent {
  /// العربية: بداية نطاق التقرير.
  /// English: The report range start.
  final DateTime startDate;

  /// العربية: نهاية نطاق التقرير.
  /// English: The report range end.
  final DateTime endDate;

  /// العربية: معرّف العقار عند الحاجة لتصفية التقرير.
  /// English: Optional property identifier used to scope the report.
  final String? propertyId;

  /// العربية: ينشئ حدث تحميل التقرير.
  /// English: Creates the report-loading event.
  const LoadBookingReportEvent({
    required this.startDate,
    required this.endDate,
    this.propertyId,
  });

  /// العربية: يعتمد على الفترة والعقار في المقارنة.
  /// English: Uses the period and property scope in equality checks.
  @override
  List<Object?> get props => [startDate, endDate, propertyId];
}

/// العربية: يطلب بيانات اتجاهات الحجوزات للفترة المحددة.
/// English: Requests booking trend data for the selected range.
class LoadBookingTrendsEvent extends BookingAnalyticsEvent {
  /// العربية: بداية نطاق الاتجاهات.
  /// English: The trend range start.
  final DateTime startDate;

  /// العربية: نهاية نطاق الاتجاهات.
  /// English: The trend range end.
  final DateTime endDate;

  /// العربية: معرّف العقار عند الحاجة لتصفية الاتجاهات.
  /// English: Optional property identifier used to scope the trends.
  final String? propertyId;

  /// العربية: ينشئ حدث تحميل الاتجاهات.
  /// English: Creates the trend-loading event.
  const LoadBookingTrendsEvent({
    required this.startDate,
    required this.endDate,
    this.propertyId,
  });

  /// العربية: يعتمد على الفترة والعقار في المقارنة.
  /// English: Uses the period and property scope in equality checks.
  @override
  List<Object?> get props => [startDate, endDate, propertyId];
}

/// العربية: يطلب تحليل نافذة الحجز لعقار محدد.
/// English: Requests booking window analysis for a specific property.
class LoadBookingWindowAnalysisEvent extends BookingAnalyticsEvent {
  /// العربية: معرّف العقار المطلوب تحليله.
  /// English: The property identifier to analyze.
  final String propertyId;

  /// العربية: ينشئ حدث تحليل نافذة الحجز.
  /// English: Creates the window-analysis event.
  const LoadBookingWindowAnalysisEvent({required this.propertyId});

  /// العربية: يعتمد على معرّف العقار فقط.
  /// English: Uses the property id only for equality.
  @override
  List<Object> get props => [propertyId];
}

/// العربية: يطلب تصدير نتائج التحليلات بالصّيغة المحددة.
/// English: Requests exporting the analytics results in the chosen format.
class ExportAnalyticsReportEvent extends BookingAnalyticsEvent {
  /// العربية: صيغة التصدير المطلوبة.
  /// English: The requested export format.
  final ExportFormat format;

  /// العربية: ينشئ حدث التصدير.
  /// English: Creates the export event.
  const ExportAnalyticsReportEvent({required this.format});

  /// العربية: يعتمد على صيغة التصدير فقط.
  /// English: Uses the export format only for equality.
  @override
  List<Object> get props => [format];
}

/// العربية: يطلب مقارنة فترتين زمنيتين ضمن نفس سياق التحليلات.
/// English: Requests a comparison between two time periods in the same analytics context.
class ComparePeriodsEvent extends BookingAnalyticsEvent {
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

  /// العربية: ينشئ حدث المقارنة.
  /// English: Creates the comparison event.
  const ComparePeriodsEvent({
    required this.period1Start,
    required this.period1End,
    required this.period2Start,
    required this.period2End,
  });

  /// العربية: يعتمد على حدود الفترتين كاملتين.
  /// English: Uses both full ranges for equality.
  @override
  List<Object> get props =>
      [period1Start, period1End, period2Start, period2End];
}

/// العربية: تمثل الفترات الزمنية المتاحة لعرض التحليلات.
/// English: Represents the available time periods for analytics views.
enum AnalyticsPeriod {
  /// العربية: تعرض بيانات يوم واحد.
  /// English: Shows data for a single day.
  day,

  /// العربية: تعرض بيانات أسبوع واحد.
  /// English: Shows data for a single week.
  week,

  /// العربية: تعرض بيانات شهر واحد.
  /// English: Shows data for a single month.
  month,

  /// العربية: تعرض بيانات ربع سنة.
  /// English: Shows data for a quarter.
  quarter,

  /// العربية: تعرض بيانات سنة كاملة.
  /// English: Shows data for a full year.
  year,
}

/// العربية: تمثل صيغ التصدير المتاحة لنتائج التحليلات.
/// English: Represents the available export formats for analytics output.
enum ExportFormat {
  /// العربية: تصدير إلى PDF.
  /// English: Export as PDF.
  pdf,

  /// العربية: تصدير إلى Excel.
  /// English: Export as Excel.
  excel,

  /// العربية: تصدير إلى CSV.
  /// English: Export as CSV.
  csv,
}
