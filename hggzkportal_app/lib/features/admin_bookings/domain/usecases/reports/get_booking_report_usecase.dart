import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking_report.dart';
import '../../repositories/bookings_repository.dart';

/// يجلب تقرير الحجوزات للفترة الزمنية المحددة مع دعم فلتر العقار عند
/// الحاجة.
/// Loads a booking report for the requested date range with an optional
/// property filter.
class GetBookingReportUseCase
    implements UseCase<BookingReport, GetBookingReportParams> {
  /// المستودع الذي يوفّر بيانات التقرير المجمّعة.
  /// The repository that provides the aggregated report data.
  final BookingsRepository repository;

  /// Creates the booking-report use case with the bookings repository.
  GetBookingReportUseCase(this.repository);
  @override

  /// يمرر نطاق التاريخ ومعرّف العقار إلى المستودع ثم يعيد التقرير الناتج.
  /// Forwards the date range and property id to the repository and returns
  /// the resulting report.
  Future<Either<Failure, BookingReport>> call(
      GetBookingReportParams params) async {
    return await repository.getBookingReport(
      startDate: params.startDate,
      endDate: params.endDate,
      propertyId: params.propertyId,
    );
  }
}

/// يجمع حدود التقرير والفلاتر الاختيارية في كائن واحد لاستهلاك use case.
/// Collects the report bounds and optional filters into one object consumed
/// by the use case.
class GetBookingReportParams extends Equatable {
  /// بداية الفترة الزمنية للتقرير.
  /// The start of the reporting period.
  final DateTime startDate;

  /// نهاية الفترة الزمنية للتقرير.
  /// The end of the reporting period.
  final DateTime endDate;

  /// معرّف العقار عند طلب تقرير خاص بعقار واحد.
  /// The property identifier when requesting a property-specific report.
  final String? propertyId;

  /// Creates the immutable parameters for booking report retrieval.
  const GetBookingReportParams({
    required this.startDate,
    required this.endDate,
    this.propertyId,
  });
  @override

  /// تعتمد المساواة على نطاق التاريخ والعقار لأن أي تغيير فيهما يغيّر
  /// التقرير بالكامل.
  /// Equality depends on the date range and property because changing either
  /// one changes the report entirely.
  List<Object?> get props => [startDate, endDate, propertyId];
}
