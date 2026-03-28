import '../../domain/entities/booking_window_analysis.dart';

/// يجمع تحليل نافذة الحجز على مستوى العقار، بما في ذلك متوسط مدة الحجز
/// وتقسيمات الحجز المبكر والمؤشرات الإرشادية.
/// Collects the booking-window analysis for a property, including average
/// lead time, booking segments, and guidance signals.
class BookingWindowAnalysisModel extends BookingWindowAnalysis {
  /// ينشئ تحليل نافذة الحجز الكامل مع الأجزاء الزمنية والرؤى النصية.
  /// Creates the full booking-window analysis with time segments and textual
  /// insights.
  const BookingWindowAnalysisModel({
    required super.averageLeadTimeInDays,
    required super.bookingsLastMinute,
    required super.bookingsAdvance,
    required super.bookingsByLeadTime,
    required super.segments,
    required super.insights,
  });

  /// يبني تحليل نافذة الحجز من JSON القادم من خدمة التقارير.
  /// Builds the booking-window analysis from JSON returned by the reporting
  /// service.
  factory BookingWindowAnalysisModel.fromJson(Map<String, dynamic> json) {
    return BookingWindowAnalysisModel(
      averageLeadTimeInDays: (json['averageLeadTimeInDays'] ?? 0).toDouble(),
      bookingsLastMinute: json['bookingsLastMinute'] ?? 0,
      bookingsAdvance: json['bookingsAdvance'] ?? 0,
      bookingsByLeadTime:
          Map<String, int>.from(json['bookingsByLeadTime'] ?? {}),
      segments: (json['segments'] as List? ?? [])
          .map((item) => LeadTimeSegmentModel.fromJson(item))
          .toList(),
      insights: WindowInsightsModel.fromJson(json['insights'] ?? {}),
    );
  }

  /// يحول تحليل نافذة الحجز إلى JSON متوافق مع نفس نموذج التقارير.
  /// Serializes the booking-window analysis into JSON compatible with the same
  /// reporting model.
  Map<String, dynamic> toJson() {
    return {
      'averageLeadTimeInDays': averageLeadTimeInDays,
      'bookingsLastMinute': bookingsLastMinute,
      'bookingsAdvance': bookingsAdvance,
      'bookingsByLeadTime': bookingsByLeadTime,
      'segments': segments
          .map((item) => (item as LeadTimeSegmentModel).toJson())
          .toList(),
      'insights': (insights as WindowInsightsModel).toJson(),
    };
  }
}

/// يمثل شريحة زمنية واحدة من نافذة الحجز المبكر مع عدد الحجوزات والنسبة
/// والمتوسط المالي.
/// Represents one lead-time segment with booking count, share, and average
/// value.
class LeadTimeSegmentModel extends LeadTimeSegment {
  /// ينشئ شريحة زمنية واحدة ضمن تحليل نافذة الحجز.
  /// Creates one lead-time segment inside the booking-window analysis.
  const LeadTimeSegmentModel({
    required super.name,
    required super.minDays,
    required super.maxDays,
    required super.bookingsCount,
    required super.percentage,
    required super.averageValue,
  });

  /// يبني الشريحة الزمنية من JSON كما تعيده خدمة التحليل.
  /// Builds the lead-time segment from JSON as returned by the analysis
  /// service.
  factory LeadTimeSegmentModel.fromJson(Map<String, dynamic> json) {
    return LeadTimeSegmentModel(
      name: json['name'] ?? '',
      minDays: json['minDays'] ?? 0,
      maxDays: json['maxDays'] ?? 0,
      bookingsCount: json['bookingsCount'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      averageValue: (json['averageValue'] ?? 0).toDouble(),
    );
  }

  /// يحول الشريحة الزمنية إلى JSON بنفس المفاتيح التي يتوقعها الخادم.
  /// Serializes the lead-time segment using the keys expected by the backend.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'minDays': minDays,
      'maxDays': maxDays,
      'bookingsCount': bookingsCount,
      'percentage': percentage,
      'averageValue': averageValue,
    };
  }
}

/// يمثل الرؤى النهائية والتحسينات المقترحة الناتجة عن تحليل نافذة الحجز.
/// Represents the final insights and suggested improvements produced by the
/// booking-window analysis.
class WindowInsightsModel extends WindowInsights {
  /// ينشئ حزمة الرؤى النصية الخاصة بنافذة الحجز.
  /// Creates the text insights bundle for the booking window.
  const WindowInsightsModel({
    required super.optimalBookingWindow,
    required super.recommendations,
    required super.patterns,
  });

  /// يبني الرؤى من JSON القادم من طبقة التقارير أو التحليلات.
  /// Builds the insights from JSON returned by the reports or analytics
  /// layer.
  factory WindowInsightsModel.fromJson(Map<String, dynamic> json) {
    return WindowInsightsModel(
      optimalBookingWindow: json['optimalBookingWindow'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      patterns: json['patterns'] ?? {},
    );
  }

  /// يحول الرؤى إلى JSON ليبقى التسلسل متوافقًا مع بقية طبقة البيانات.
  /// Serializes the insights to JSON so they stay compatible with the rest of
  /// the data layer.
  Map<String, dynamic> toJson() {
    return {
      'optimalBookingWindow': optimalBookingWindow,
      'recommendations': recommendations,
      'patterns': patterns,
    };
  }
}
