import 'package:equatable/equatable.dart';

/// يمثل هذا الكلاس UnitAnalytics البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitAnalytics in the admin unit workflow.
class UnitAnalytics extends Equatable {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// يحتفظ هذا الحقل بقيمة fromDate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fromDate value used by the admin unit workflow.
  final DateTime fromDate;

  /// يحتفظ هذا الحقل بقيمة toDate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the toDate value used by the admin unit workflow.
  final DateTime toDate;

  /// يحتفظ هذا الحقل بقيمة currency التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the currency value used by the admin unit workflow.
  final String currency;

  /// يحتفظ هذا الحقل بقيمة totalBookings التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the totalBookings value used by the admin unit workflow.
  final int totalBookings;

  /// يحتفظ هذا الحقل بقيمة confirmedBookings التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the confirmedBookings value used by the admin unit workflow.
  final int confirmedBookings;

  /// يحتفظ هذا الحقل بقيمة completedBookings التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the completedBookings value used by the admin unit workflow.
  final int completedBookings;

  /// يحتفظ هذا الحقل بقيمة cancelledBookings التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the cancelledBookings value used by the admin unit workflow.
  final int cancelledBookings;

  /// يحتفظ هذا الحقل بقيمة totalRevenue التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the totalRevenue value used by the admin unit workflow.
  final double totalRevenue;

  /// يحتفظ هذا الحقل بقيمة occupancyRate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the occupancyRate value used by the admin unit workflow.
  final double occupancyRate;

  /// يحتفظ هذا الحقل بقيمة totalDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the totalDays value used by the admin unit workflow.
  final int totalDays;

  /// يحتفظ هذا الحقل بقيمة bookedDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the bookedDays value used by the admin unit workflow.
  final int bookedDays;

  /// يحتفظ هذا الحقل بقيمة averageRating التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the averageRating value used by the admin unit workflow.
  final double averageRating;

  /// يحتفظ هذا الحقل بقيمة totalReviews التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the totalReviews value used by the admin unit workflow.
  final int totalReviews;

  /// يحتفظ هذا الحقل بقيمة viewCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the viewCount value used by the admin unit workflow.
  final int viewCount;

  /// يحتفظ هذا الحقل بقيمة bookingCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the bookingCount value used by the admin unit workflow.
  final int bookingCount;

  /// ينشئ هذا المُنشئ مثيلاً من UnitAnalytics.
  /// This constructor creates an instance of UnitAnalytics.
  const UnitAnalytics({
    required this.unitId,
    required this.fromDate,
    required this.toDate,
    required this.currency,
    required this.totalBookings,
    required this.confirmedBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.occupancyRate,
    required this.totalDays,
    required this.bookedDays,
    required this.averageRating,
    required this.totalReviews,
    required this.viewCount,
    required this.bookingCount,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [
        unitId,
        fromDate,
        toDate,
        currency,
        totalBookings,
        confirmedBookings,
        completedBookings,
        cancelledBookings,
        totalRevenue,
        occupancyRate,
        totalDays,
        bookedDays,
        averageRating,
        totalReviews,
        viewCount,
        bookingCount,
      ];
}
