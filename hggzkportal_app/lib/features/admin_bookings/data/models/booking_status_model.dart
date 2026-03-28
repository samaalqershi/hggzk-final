import '../../../../../core/enums/booking_status.dart';

/// يمثل توزيع حالات الحجز داخل تقارير الإدارة مع إحصاءات العدد والنسبة
/// والإيراد.
/// Represents the booking-status breakdown inside admin reports with count,
/// percentage, and revenue statistics.
class BookingStatusModel {
  /// حالة الحجز الفعلية كما يتعامل معها التطبيق والـ API.
  /// The actual booking status as used by the app and API.
  final BookingStatus status;

  /// عدد الحجوزات الواقعة تحت هذه الحالة.
  /// Number of bookings that fall under this status.
  final int count;

  /// النسبة المئوية لهذه الحالة من إجمالي الحجوزات.
  /// Percentage of this status relative to the total bookings.
  final double percentage;

  /// الإيراد المرتبط بهذه الحالة داخل لوحة الإدارة.
  /// Revenue associated with this status in the admin dashboard.
  final double revenue;

  /// ينشئ بند حالة حجز واحدًا مع الإحصاءات المرتبطة به.
  /// Creates one booking-status entry with its associated metrics.
  BookingStatusModel({
    required this.status,
    required this.count,
    required this.percentage,
    required this.revenue,
  });

  /// يبني بند الحالة من حمولة JSON قادمة من الخادم أو من طبقة تحليل
  /// وسيطة.
  /// Builds the status item from JSON received from the backend or an
  /// intermediate analytics layer.
  factory BookingStatusModel.fromJson(Map<String, dynamic> json) {
    return BookingStatusModel(
      status: _parseStatus(json['status']),
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  /// يحول حالة الحجز إلى JSON متوافق مع صيغة التقارير في الخادم.
  /// Converts the booking status to JSON compatible with the backend report
  /// format.
  Map<String, dynamic> toJson() {
    return {
      'status': status.displayNameEn,
      'count': count,
      'percentage': percentage,
      'revenue': revenue,
    };
  }

  /// يطابق القيم النصية القادمة من الخادم مع قيم `BookingStatus`
  /// الداخلية.
  /// Maps backend string values to the internal `BookingStatus` enum.
  static BookingStatus _parseStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;

    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'checkedin':
      case 'checked_in':
        return BookingStatus.checkedIn;
      default:
        return BookingStatus.pending;
    }
  }
}

/// يمثل ملخصًا مجمّعًا لتوزيع حالات الحجز عبر كل الحالات المتاحة.
/// Represents an aggregated summary of booking statuses across all possible
/// states.
class BookingStatusStats {
  /// تفصيل الحالات مع العدد والنسبة والإيراد لكل حالة.
  /// Status breakdown with count, percentage, and revenue for each state.
  final List<BookingStatusModel> statusBreakdown;

  /// إجمالي عدد الحجوزات المحتسبة في هذا الملخص.
  /// Total number of bookings included in this summary.
  final int totalBookings;

  /// إجمالي الإيراد المحسوب عبر كل الحالات.
  /// Total revenue calculated across all statuses.
  final double totalRevenue;

  /// ينشئ الملخص الكامل لتوزيع الحالات.
  /// Creates the full booking-status summary.
  BookingStatusStats({
    required this.statusBreakdown,
    required this.totalBookings,
    required this.totalRevenue,
  });

  /// يبني الملخص من خريطة JSON كما تعيدها نقطة التقرير في الخادم.
  /// Builds the summary from the JSON map returned by the reporting endpoint.
  factory BookingStatusStats.fromJson(Map<String, dynamic> json) {
    return BookingStatusStats(
      statusBreakdown: (json['statusBreakdown'] as List? ?? [])
          .map((item) => BookingStatusModel.fromJson(item))
          .toList(),
      totalBookings: json['totalBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
