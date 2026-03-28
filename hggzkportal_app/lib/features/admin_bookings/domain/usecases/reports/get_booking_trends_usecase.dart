import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking_trends.dart';
import '../../repositories/bookings_repository.dart';

/// يجلب سلاسل الاتجاه الخاصة بالحجوزات والإيراد والإشغال للفترة المطلوبة.
/// Loads booking, revenue, and occupancy trend series for the requested
/// period.
class GetBookingTrendsUseCase
    implements UseCase<BookingTrends, GetBookingTrendsParams> {
  /// المستودع الذي يحسب أو يجلب بيانات الاتجاهات.
  /// The repository that computes or fetches the trend data.
  final BookingsRepository repository;

  /// Creates the booking-trends use case with the bookings repository.
  GetBookingTrendsUseCase(this.repository);
  @override

  /// يمرر الفترة ومعرّف العقار إلى المستودع ثم يعيد بنية الاتجاهات.
  /// Forwards the time window and property id to the repository and returns
  /// the trend bundle.
  Future<Either<Failure, BookingTrends>> call(
      GetBookingTrendsParams params) async {
    return await repository.getBookingTrends(
      propertyId: params.propertyId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// يجمع معايير جلب الاتجاهات في طلب واحد حتى يبقى الفلتر واضحًا ومحمولًا.
/// Collects the trend-fetch parameters into one request so the filter stays
/// explicit and portable.
class GetBookingTrendsParams extends Equatable {
  /// معرّف العقار عندما نريد اتجاهات عقار واحد فقط.
  /// The property identifier when only one property's trends are needed.
  final String? propertyId;

  /// بداية الفترة التي ستُحسب عليها الاتجاهات.
  /// The start of the period used to compute the trends.
  final DateTime startDate;

  /// نهاية الفترة التي ستُحسب عليها الاتجاهات.
  /// The end of the period used to compute the trends.
  final DateTime endDate;

  /// Creates the immutable parameters for trend retrieval.
  const GetBookingTrendsParams({
    this.propertyId,
    required this.startDate,
    required this.endDate,
  });
  @override

  /// تعتمد المساواة على العقار ونطاق التاريخ لأن هذه القيم تحدد الاتجاهات
  /// المطلوبة.
  /// Equality depends on the property and date range because those values
  /// define the requested trends.
  List<Object?> get props => [propertyId, startDate, endDate];
}
