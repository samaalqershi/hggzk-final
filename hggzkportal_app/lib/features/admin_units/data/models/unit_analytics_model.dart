import '../../domain/entities/unit_analytics.dart';

/// يمثل هذا الكلاس UnitAnalyticsModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitAnalyticsModel in the admin unit workflow.
class UnitAnalyticsModel extends UnitAnalytics {
  /// This constructor creates a new UnitAnalyticsModel instance.
  /// ينشئ مثيلًا جديدًا من UnitAnalyticsModel.
  const UnitAnalyticsModel({
    required super.unitId,
    required super.fromDate,
    required super.toDate,
    required super.currency,
    required super.totalBookings,
    required super.confirmedBookings,
    required super.completedBookings,
    required super.cancelledBookings,
    required super.totalRevenue,
    required super.occupancyRate,
    required super.totalDays,
    required super.bookedDays,
    required super.averageRating,
    required super.totalReviews,
    required super.viewCount,
    required super.bookingCount,
  });

  /// ينفذ هذا الأسلوب عملية _asInt ضمن مسار إدارة الوحدات.
  /// This method performs the _asInt operation in the admin unit workflow.
  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  /// ينفذ هذا الأسلوب عملية _asDouble ضمن مسار إدارة الوحدات.
  /// This method performs the _asDouble operation in the admin unit workflow.
  static double _asDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  /// ينشئ هذا المُنشئ مثيلاً من UnitAnalyticsModel.
  /// This constructor creates an instance of UnitAnalyticsModel.
  factory UnitAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UnitAnalyticsModel(
      unitId: json['unitId']?.toString() ?? json['UnitId']?.toString() ?? '',
      fromDate: DateTime.parse(
          json['fromDate']?.toString() ?? json['FromDate'].toString()),
      toDate: DateTime.parse(
          json['toDate']?.toString() ?? json['ToDate'].toString()),
      currency: (json['currency'] ?? json['Currency'] ?? 'YER').toString(),
      totalBookings: _asInt(json['totalBookings'] ?? json['TotalBookings']),
      confirmedBookings:
          _asInt(json['confirmedBookings'] ?? json['ConfirmedBookings']),
      completedBookings:
          _asInt(json['completedBookings'] ?? json['CompletedBookings']),
      cancelledBookings:
          _asInt(json['cancelledBookings'] ?? json['CancelledBookings']),
      totalRevenue: _asDouble(json['totalRevenue'] ?? json['TotalRevenue']),
      occupancyRate: _asDouble(json['occupancyRate'] ?? json['OccupancyRate']),
      totalDays: _asInt(json['totalDays'] ?? json['TotalDays']),
      bookedDays: _asInt(json['bookedDays'] ?? json['BookedDays']),
      averageRating: _asDouble(json['averageRating'] ?? json['AverageRating']),
      totalReviews: _asInt(json['totalReviews'] ?? json['TotalReviews']),
      viewCount: _asInt(json['viewCount'] ?? json['ViewCount']),
      bookingCount: _asInt(json['bookingCount'] ?? json['BookingCount']),
    );
  }
}
