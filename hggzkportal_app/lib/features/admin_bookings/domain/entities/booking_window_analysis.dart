import 'package:equatable/equatable.dart';

/// يلخص سلوك الحجز بحسب مدة التقديم قبل الوصول حتى يفهم الفريق هل
/// الحجوزات تحدث مبكرًا أم في اللحظة الأخيرة.
/// Summarizes booking behavior by lead-time window so the team can see
/// whether bookings happen early or at the last minute.
class BookingWindowAnalysis extends Equatable {
  /// متوسط عدد الأيام بين وقت الحجز ووقت الوصول.
  /// The average number of days between booking time and arrival time.
  final double averageLeadTimeInDays;

  /// عدد الحجوزات التي تمت في آخر لحظة.
  /// The number of bookings made at the last minute.
  final int bookingsLastMinute;

  /// عدد الحجوزات التي تمت قبل الموعد بوقت كافٍ.
  /// The number of bookings made well in advance.
  final int bookingsAdvance;

  /// توزيع الحجوزات عبر نطاقات زمنية مختلفة قبل الوصول.
  /// The distribution of bookings across different lead-time buckets.
  final Map<String, int> bookingsByLeadTime;

  /// الشرائح الزمنية التفصيلية التي تشرح كل نافذة حجز.
  /// Detailed time segments that explain each booking window.
  final List<LeadTimeSegment> segments;

  /// الرؤى العامة التي تشرح ما تعنيه الأرقام بالنسبة للفريق.
  /// The high-level insights that explain what the numbers mean for the team.
  final WindowInsights insights;

  /// Creates a booking-window analysis snapshot.
  const BookingWindowAnalysis({
    required this.averageLeadTimeInDays,
    required this.bookingsLastMinute,
    required this.bookingsAdvance,
    required this.bookingsByLeadTime,
    required this.segments,
    required this.insights,
  });
  @override

  /// تعتمد المساواة على كل مؤشرات النافذة لأن الصورة التحليلية تعتمد
  /// عليها مجتمعة.
  /// Equality depends on all window indicators because the analytical picture
  /// is built from them together.
  List<Object> get props => [
        averageLeadTimeInDays,
        bookingsLastMinute,
        bookingsAdvance,
        bookingsByLeadTime,
        segments,
        insights,
      ];
}

/// يصف شريحة زمنية واحدة ضمن تحليل نافذة الحجز مثل من 0 إلى 3 أيام أو من
/// 7 إلى 14 يومًا.
/// Describes one lead-time bucket inside the booking-window analysis, such as
/// 0-3 days or 7-14 days.
class LeadTimeSegment extends Equatable {
  /// اسم الشريحة كما يظهر في التقارير أو الرسوم.
  /// The segment name as shown in reports or charts.
  final String name;

  /// أقل عدد أيام يدخل ضمن هذه الشريحة.
  /// The minimum number of days included in this segment.
  final int minDays;

  /// أعلى عدد أيام يدخل ضمن هذه الشريحة.
  /// The maximum number of days included in this segment.
  final int maxDays;

  /// عدد الحجوزات الواقعة داخل هذه الشريحة.
  /// The number of bookings that fall into this segment.
  final int bookingsCount;

  /// النسبة المئوية لهذه الشريحة من إجمالي الحجوزات.
  /// The percentage this segment represents out of all bookings.
  final double percentage;

  /// متوسط قيمة الحجز ضمن هذه الشريحة.
  /// The average booking value within this segment.
  final double averageValue;

  /// Creates one lead-time segment for the analysis.
  const LeadTimeSegment({
    required this.name,
    required this.minDays,
    required this.maxDays,
    required this.bookingsCount,
    required this.percentage,
    required this.averageValue,
  });
  @override

  /// تعتمد المساواة على حدود الشريحة ونتائجها لأنها تمثل فئة زمنية واحدة
  /// محددة.
  /// Equality depends on the segment bounds and values because they represent
  /// one specific time bucket.
  List<Object> get props => [
        name,
        minDays,
        maxDays,
        bookingsCount,
        percentage,
        averageValue,
      ];
}

/// يجمع التوصيات والنمط الأمثل وسلوك النافذة بشكل يوجّه فريق التشغيل
/// نحو القرار العملي.
/// Groups recommendations, the optimal booking window, and observed patterns
/// into an actionable summary for the operations team.
class WindowInsights extends Equatable {
  /// الوصف النصي لنافذة الحجز التي تبدو الأكثر فاعلية.
  /// The textual description of the booking window that appears most
  /// effective.
  final String optimalBookingWindow;

  /// التوصيات العملية المستخلصة من التحليل.
  /// The practical recommendations extracted from the analysis.
  final List<String> recommendations;

  /// الأنماط أو الإشارات الإضافية التي تدعم التفسير التحليلي.
  /// Extra patterns or signals that support the analytical interpretation.
  final Map<String, dynamic> patterns;

  /// Creates the insight bundle for booking-window analysis.
  const WindowInsights({
    required this.optimalBookingWindow,
    required this.recommendations,
    required this.patterns,
  });
  @override

  /// تعتمد المساواة على نافذة الحجز الأفضل والتوصيات والأنماط المرافقة.
  /// Equality depends on the optimal window, recommendations, and attached
  /// patterns.
  List<Object> get props => [
        optimalBookingWindow,
        recommendations,
        patterns,
      ];
}
