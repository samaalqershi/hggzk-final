import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Confirms a booking through the bookings repository.
/// يؤكد الحجز عبر مستودع الحجوزات.
class ConfirmBookingUseCase implements UseCase<bool, ConfirmBookingParams> {
  /// Repository that performs the booking confirmation.
  /// المستودع الذي ينفذ عملية تأكيد الحجز.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  ConfirmBookingUseCase(this.repository);

  @override

  /// Delegates confirmation for the provided booking id.
  /// يفوض عملية التأكيد لمعرّف الحجز المعطى.
  Future<Either<Failure, bool>> call(ConfirmBookingParams params) async {
    return await repository.confirmBooking(bookingId: params.bookingId);
  }
}

/// Parameters required to confirm one booking.
/// المعاملات المطلوبة لتأكيد حجز واحد.
class ConfirmBookingParams extends Equatable {
  /// Identifier of the booking to confirm.
  /// معرّف الحجز المطلوب تأكيده.
  final String bookingId;

  /// Creates the confirmation parameters for one booking.
  /// ينشئ معاملات التأكيد لحجز واحد.
  const ConfirmBookingParams({required this.bookingId});

  @override

  /// Comparison key for the booking being confirmed.
  /// مفتاح المقارنة للحجز الجاري تأكيده.
  List<Object> get props => [bookingId];
}
