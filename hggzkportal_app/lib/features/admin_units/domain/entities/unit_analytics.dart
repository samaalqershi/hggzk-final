import 'package:equatable/equatable.dart';

class UnitAnalytics extends Equatable {
  final String unitId;
  final DateTime fromDate;
  final DateTime toDate;
  final String currency;

  final int totalBookings;
  final int confirmedBookings;
  final int completedBookings;
  final int cancelledBookings;

  final double totalRevenue;

  final double occupancyRate;
  final int totalDays;
  final int bookedDays;

  final double averageRating;
  final int totalReviews;

  final int viewCount;
  final int bookingCount;

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
