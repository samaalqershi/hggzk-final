import '../../domain/entities/booking_report.dart';

/// Converts report payloads from analytics endpoints into the booking-report
/// entity consumed by the portal.
///
/// يحول حمولة التقارير القادمة من نقاط التحليلات إلى كيان التقرير المستخدم
/// داخل البوابة.
class BookingReportModel extends BookingReport {
  /// Creates the immutable report snapshot shared by charts and exports.
  ///
  /// ينشئ لقطة التقرير غير القابلة للتعديل والمستخدمة في الرسوم والتصدير.
  const BookingReportModel({
    required super.items,
    required super.summary,
    required super.startDate,
    required super.endDate,
  });

  /// Parses the overall booking report and its itemized daily breakdown.
  ///
  /// يحلل تقرير الحجز الكامل مع تفصيله اليومي.
  factory BookingReportModel.fromJson(Map<String, dynamic> json) {
    return BookingReportModel(
      items: (json['items'] as List? ?? [])
          .map((item) => BookingReportItemModel.fromJson(item))
          .toList(),
      summary: BookingReportSummaryModel.fromJson(json['summary'] ?? json),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  /// Serializes the report back into the analytics API shape.
  ///
  /// يعيد التقرير إلى شكل الـ API الخاص بالتحليلات.
  Map<String, dynamic> toJson() {
    return {
      'items': items
          .map((item) => (item as BookingReportItemModel).toJson())
          .toList(),
      'summary': (summary as BookingReportSummaryModel).toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

/// Represents one daily analytics row inside the booking report.
///
/// يمثل صفًا تحليليًا يوميًا داخل تقرير الحجز.
class BookingReportItemModel extends BookingReportItem {
  /// Creates a single day summary for booking activity and revenue.
  ///
  /// ينشئ ملخص يوم واحد لنشاط الحجز والإيراد.
  const BookingReportItemModel({
    required super.date,
    required super.count,
    required super.revenue,
    required super.checkIns,
    required super.checkOuts,
    required super.cancellations,
    required super.bookingsByStatus,
  });

  /// Parses the daily row exactly as the chart and table need it.
  ///
  /// يحلل الصف اليومي بالشكل الذي تحتاجه اللوحة والجدول.
  factory BookingReportItemModel.fromJson(Map<String, dynamic> json) {
    return BookingReportItemModel(
      date: DateTime.parse(json['date']),
      count: json['count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      checkIns: json['checkIns'] ?? 0,
      checkOuts: json['checkOuts'] ?? 0,
      cancellations: json['cancellations'] ?? 0,
      bookingsByStatus: Map<String, int>.from(json['bookingsByStatus'] ?? {}),
    );
  }

  /// Serializes the row for reporting export or caching.
  ///
  /// يعيد الصف لاستخدامه في التصدير أو التخزين المؤقت.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      'revenue': revenue,
      'checkIns': checkIns,
      'checkOuts': checkOuts,
      'cancellations': cancellations,
      'bookingsByStatus': bookingsByStatus,
    };
  }
}

/// Holds the high-level metrics displayed above the daily report rows.
///
/// يحتفظ بالمؤشرات العليا المعروضة فوق الصفوف اليومية في التقرير.
class BookingReportSummaryModel extends BookingReportSummary {
  /// Creates the aggregate summary shared by the report dashboard.
  ///
  /// ينشئ الملخص التجميعي المشترك في لوحة التقارير.
  const BookingReportSummaryModel({
    required super.totalBookings,
    required super.totalRevenue,
    required super.averageBookingValue,
    required super.occupancyRate,
    required super.totalNights,
    required super.averageStayLength,
    required super.bookingsBySource,
    required super.revenueByPaymentMethod,
  });

  /// Parses the top-line metrics that drive the summary cards and charts.
  ///
  /// يحلل المقاييس العليا التي تغذي بطاقات الملخص والرسوم.
  factory BookingReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingReportSummaryModel(
      totalBookings: json['totalBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageBookingValue: (json['averageBookingValue'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      totalNights: json['totalNights'] ?? 0,
      averageStayLength: (json['averageStayLength'] ?? 0).toDouble(),
      bookingsBySource: Map<String, int>.from(json['bookingsBySource'] ?? {}),
      revenueByPaymentMethod:
          Map<String, double>.from(json['revenueByPaymentMethod'] ?? {}),
    );
  }

  /// Serializes the summary to the payload expected by the analytics API.
  ///
  /// يعيد الملخص إلى الحمولة المتوقعة من واجهة التحليلات.
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'averageBookingValue': averageBookingValue,
      'occupancyRate': occupancyRate,
      'totalNights': totalNights,
      'averageStayLength': averageStayLength,
      'bookingsBySource': bookingsBySource,
      'revenueByPaymentMethod': revenueByPaymentMethod,
    };
  }
}
