import 'package:equatable/equatable.dart';

/// يجمع سلاسل زمنية متعددة وتحليلًا واحدًا حتى تعرض لوحات الإدارة
/// اتجاهات الحجوزات والإيراد والإشغال في قراءة واحدة.
/// Groups multiple time series and one analysis block so admin dashboards can
/// read booking, revenue, and occupancy trends in one place.
class BookingTrends extends Equatable {
  /// سلسلة الاتجاه الخاصة بعدد الحجوزات عبر الزمن.
  /// The time series for booking counts over time.
  final List<TimeSeriesData> bookingTrends;

  /// سلسلة الاتجاه الخاصة بالإيراد عبر الزمن.
  /// The time series for revenue over time.
  final List<TimeSeriesData> revenueTrends;

  /// سلسلة الاتجاه الخاصة بنسبة الإشغال عبر الزمن.
  /// The time series for occupancy rate over time.
  final List<TimeSeriesData> occupancyTrends;

  /// التحليل الأعلى مستوى الذي يفسر الاتجاه العام والتوقعات.
  /// The high-level analysis that explains the overall trend and forecast.
  final TrendAnalysis analysis;

  /// Creates a trend bundle for booking analytics.
  const BookingTrends({
    required this.bookingTrends,
    required this.revenueTrends,
    required this.occupancyTrends,
    required this.analysis,
  });
  @override

  /// تعتمد المساواة على كل سلسلة زمنية وعلى التحليل المرافق لأنها تشكل
  /// نفس الصورة التحليلية.
  /// Equality depends on every time series and the analysis block because
  /// together they form the same analytical snapshot.
  List<Object> get props => [
        bookingTrends,
        revenueTrends,
        occupancyTrends,
        analysis,
      ];
}

/// يمثل نقطة واحدة داخل سلسلة زمنية مثل عدد الحجوزات أو الإيراد أو معدل
/// الإشغال في تاريخ معين.
/// Represents one point in a time series, such as bookings, revenue, or
/// occupancy at a specific date.
class TimeSeriesData extends Equatable {
  /// التاريخ الذي تمثلّه هذه النقطة.
  /// The date represented by this point.
  final DateTime date;

  /// القيمة المقاسة في ذلك التاريخ.
  /// The measured value for that date.
  final double value;

  /// تسمية اختيارية تساعد الواجهة على وصف النقطة أو توضيحها.
  /// Optional label that helps the UI describe or annotate the point.
  final String? label;

  /// بيانات إضافية قد ترافق النقطة مثل المصدر أو الشريحة الزمنية.
  /// Extra metadata that may accompany the point, such as source or time
  /// bucket.
  final Map<String, dynamic>? metadata;

  /// Creates one value in a trend line.
  const TimeSeriesData({
    required this.date,
    required this.value,
    this.label,
    this.metadata,
  });
  @override

  /// تعتمد المساواة على التاريخ والقيمة والبيانات المرافقة لأن النقطة
  /// الزمنية لا تكتمل بدونها.
  /// Equality depends on the date, value, and attached metadata because the
  /// time-series point is incomplete without them.
  List<Object?> get props => [date, value, label, metadata];
}

/// يفسر الاتجاه العام ويعطي توقعًا ومؤشرات موسمية حتى لا تبقى الأرقام
/// الخام بلا سياق.
/// Explains the overall trend and adds a forecast plus seasonal signals so
/// the raw numbers have useful context.
class TrendAnalysis extends Equatable {
  /// معدل النمو المحسوب من السلسلة الزمنية.
  /// The growth rate calculated from the time series.
  final double growthRate;

  /// وصف الاتجاه العام مثل increasing أو decreasing أو stable.
  /// A textual description of the overall trend, such as increasing,
  /// decreasing, or stable.
  final String trend; // 'increasing', 'decreasing', 'stable'

  /// التوقع المستقبلي المستند إلى بيانات الاتجاه الحالية.
  /// The forward-looking forecast derived from the current trend data.
  final double forecast;

  /// العوامل الموسمية التي تؤثر في التذبذب عبر الفترات المختلفة.
  /// Seasonal factors that influence variation across different periods.
  final Map<String, double> seasonalFactors;

  /// ملاحظات تفسيرية مختصرة تساعد الإدارة على فهم السبب المحتمل للحركة.
  /// Short explanatory insights that help admins understand the likely
  /// reason behind the movement.
  final List<String> insights;

  /// Creates a trend-analysis summary for booking metrics.
  const TrendAnalysis({
    required this.growthRate,
    required this.trend,
    required this.forecast,
    required this.seasonalFactors,
    required this.insights,
  });
  @override

  /// تعتمد المساواة على مؤشرات التحليل كلها لأن أي تغير فيها يبدل
  /// التفسير.
  /// Equality depends on every analysis indicator because any change alters
  /// the interpretation.
  List<Object> get props => [
        growthRate,
        trend,
        forecast,
        seasonalFactors,
        insights,
      ];
}
