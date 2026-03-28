import '../../domain/entities/booking_trends.dart';

/// يجمع بيانات اتجاهات الحجوزات والإيرادات والإشغال في شكل قابل للعرض
/// والتحليل داخل لوحة الإدارة.
/// Collects booking, revenue, and occupancy trends in a form suitable for
/// display and analysis inside the admin dashboard.
class BookingTrendsModel extends BookingTrends {
  /// ينشئ حزمة الاتجاهات الكاملة بما فيها السلاسل الزمنية والتحليل.
  /// Creates the full trends bundle including time series and analysis.
  const BookingTrendsModel({
    required super.bookingTrends,
    required super.revenueTrends,
    required super.occupancyTrends,
    required super.analysis,
  });

  /// يبني اتجاهات الحجز من JSON القادم من نقطة التقارير.
  /// Builds booking trends from the JSON returned by the reports endpoint.
  factory BookingTrendsModel.fromJson(Map<String, dynamic> json) {
    return BookingTrendsModel(
      bookingTrends: (json['bookingTrends'] as List? ?? [])
          .map((item) => TimeSeriesDataModel.fromJson(item))
          .toList(),
      revenueTrends: (json['revenueTrends'] as List? ?? [])
          .map((item) => TimeSeriesDataModel.fromJson(item))
          .toList(),
      occupancyTrends: (json['occupancyTrends'] as List? ?? [])
          .map((item) => TimeSeriesDataModel.fromJson(item))
          .toList(),
      analysis: TrendAnalysisModel.fromJson(json['analysis'] ?? {}),
    );
  }

  /// يعيد الاتجاهات إلى JSON بنفس البنية التي يتوقعها الخادم.
  /// Serializes the trends back into the JSON structure expected by the
  /// backend.
  Map<String, dynamic> toJson() {
    return {
      'bookingTrends': bookingTrends
          .map((item) => (item as TimeSeriesDataModel).toJson())
          .toList(),
      'revenueTrends': revenueTrends
          .map((item) => (item as TimeSeriesDataModel).toJson())
          .toList(),
      'occupancyTrends': occupancyTrends
          .map((item) => (item as TimeSeriesDataModel).toJson())
          .toList(),
      'analysis': (analysis as TrendAnalysisModel).toJson(),
    };
  }
}

/// يمثل نقطة زمنية واحدة ضمن سلسلة الاتجاهات مع قيمة اختيارية ووصف
/// مساعد.
/// Represents a single point in a trend series with an optional label and
/// metadata.
class TimeSeriesDataModel extends TimeSeriesData {
  /// ينشئ نقطة السلسلة الزمنية مع تاريخها وقيمتها والبيانات المساعدة.
  /// Creates the time-series point with its date, value, and helper data.
  const TimeSeriesDataModel({
    required super.date,
    required super.value,
    super.label,
    super.metadata,
  });

  /// يبني نقطة السلسلة الزمنية من JSON كما ترد من الخادم.
  /// Builds the time-series point from JSON as returned by the backend.
  factory TimeSeriesDataModel.fromJson(Map<String, dynamic> json) {
    return TimeSeriesDataModel(
      date: DateTime.parse(json['date']),
      value: (json['value'] ?? 0).toDouble(),
      label: json['label'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// يحول نقطة السلسلة الزمنية إلى JSON جاهز للحفظ أو النقل.
  /// Converts the time-series point to JSON ready for storage or transport.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      if (label != null) 'label': label,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// يمثل التحليل النصي والإحصائي للاتجاهات بعد تجميع السلاسل الزمنية.
/// Represents the textual and statistical analysis of trends after the time
/// series are aggregated.
class TrendAnalysisModel extends TrendAnalysis {
  /// ينشئ كائن تحليل الاتجاهات مع النمو ومؤشره والتوقعات والملحوظات.
  /// Creates the trend-analysis object with growth, trend, forecast, and
  /// insights.
  const TrendAnalysisModel({
    required super.growthRate,
    required super.trend,
    required super.forecast,
    required super.seasonalFactors,
    required super.insights,
  });

  /// يبني التحليل من JSON القادم من خدمة التقارير.
  /// Builds the analysis from JSON returned by the reporting service.
  factory TrendAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TrendAnalysisModel(
      growthRate: (json['growthRate'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'stable',
      forecast: (json['forecast'] ?? 0).toDouble(),
      seasonalFactors: Map<String, double>.from(json['seasonalFactors'] ?? {}),
      insights: List<String>.from(json['insights'] ?? []),
    );
  }

  /// يحول التحليل إلى JSON متوافق مع نفس بنية التقرير.
  /// Serializes the analysis into JSON that matches the same report schema.
  Map<String, dynamic> toJson() {
    return {
      'growthRate': growthRate,
      'trend': trend,
      'forecast': forecast,
      'seasonalFactors': seasonalFactors,
      'insights': insights,
    };
  }
}
