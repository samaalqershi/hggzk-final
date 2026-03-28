import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking_window_analysis.dart';
import '../../repositories/bookings_repository.dart';

/// يجلب تحليل نافذة الحجز حتى يوضح سلوك الحجوزات المبكرة والمتأخرة
/// للعقار المطلوب.
/// Loads the booking-window analysis so the team can understand early and
/// last-minute booking behavior for the requested property.
class GetBookingWindowAnalysisUseCase
    implements UseCase<BookingWindowAnalysis, GetBookingWindowAnalysisParams> {
  /// المستودع الذي يجمع بيانات نافذة الحجز.
  /// The repository that gathers booking-window data.
  final BookingsRepository repository;

  /// Creates the booking-window analysis use case with the bookings repository.
  GetBookingWindowAnalysisUseCase(this.repository);
  @override

  /// يمرر معرّف العقار إلى المستودع ثم يعيد التحليل الكامل لنافذة الحجز.
  /// Forwards the property id to the repository and returns the full
  /// window-analysis result.
  Future<Either<Failure, BookingWindowAnalysis>> call(
    GetBookingWindowAnalysisParams params,
  ) async {
    return await repository.getBookingWindowAnalysis(
      propertyId: params.propertyId,
    );
  }
}

/// يجمع معرّف العقار المطلوب لتحليل نافذة الحجز في طلب immutable واحد.
/// Collects the property identifier needed for booking-window analysis into
/// one immutable request.
class GetBookingWindowAnalysisParams extends Equatable {
  /// معرّف العقار الذي نحتاج تحليل نافذة الحجز الخاصة به.
  /// The property identifier whose booking-window analysis is requested.
  final String propertyId;

  /// Creates the immutable parameters for booking-window analysis.
  const GetBookingWindowAnalysisParams({required this.propertyId});
  @override

  /// تعتمد المساواة على معرّف العقار وحده لأن الاستعلام يخص عقارًا واحدًا.
  /// Equality depends on the property id alone because the query targets a
  /// single property.
  List<Object> get props => [propertyId];
}
