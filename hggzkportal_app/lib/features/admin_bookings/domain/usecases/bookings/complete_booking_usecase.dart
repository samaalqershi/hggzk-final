import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Marks a booking as completed in the bookings repository.
/// يعلّم الحجز على أنه مكتمل في مستودع الحجوزات.
class CompleteBookingUseCase implements UseCase<bool, CompleteBookingParams> {
  /// Repository that performs the completion operation.
  /// المستودع الذي ينفذ عملية الإكمال.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  CompleteBookingUseCase(this.repository);

  @override

  /// Delegates the completion request for one booking id.
  /// يفوض طلب إكمال الحجز لمعرّف حجز واحد.
  Future<Either<Failure, bool>> call(CompleteBookingParams params) async {
    return await repository.completeBooking(bookingId: params.bookingId);
  }
}

/// Parameters required to complete one booking.
/// المعاملات المطلوبة لإكمال حجز واحد.
class CompleteBookingParams extends Equatable {
  /// Identifier of the booking to complete.
  /// معرّف الحجز المطلوب إكماله.
  final String bookingId;

  /// Creates the completion parameters for one booking.
  /// ينشئ معاملات الإكمال لحجز واحد.
  const CompleteBookingParams({required this.bookingId});

  @override

  /// Comparison key for the booking being completed.
  /// مفتاح المقارنة للحجز الجاري إكماله.
  List<Object> get props => [bookingId];
}
