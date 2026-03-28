import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Cancels a booking and optionally requests payment refunds.
/// يلغي الحجز ويمكن أن يطلب استرداد المدفوعات أيضًا.
class CancelBookingUseCase implements UseCase<bool, CancelBookingParams> {
  /// Repository that performs the cancellation logic.
  /// المستودع الذي ينفذ منطق الإلغاء.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  CancelBookingUseCase(this.repository);

  @override

  /// Delegates the cancellation request to the repository.
  /// يفوض طلب الإلغاء إلى المستودع.
  Future<Either<Failure, bool>> call(CancelBookingParams params) async {
    return await repository.cancelBooking(
      bookingId: params.bookingId,
      cancellationReason: params.cancellationReason,
      refundPayments: params.refundPayments,
    );
  }
}

/// Parameters required to cancel a booking.
/// المعاملات المطلوبة لإلغاء حجز.
class CancelBookingParams extends Equatable {
  /// Identifier of the booking being cancelled.
  /// معرّف الحجز الجاري إلغاؤه.
  final String bookingId;

  /// Reason shown to the user or backend for the cancellation.
  /// سبب الإلغاء المعروض للمستخدم أو المرسل إلى الخادم.
  final String cancellationReason;

  /// Whether related payments should be refunded.
  /// ما إذا كان يجب استرداد المدفوعات المرتبطة.
  final bool refundPayments;

  /// Creates the cancellation parameters for one booking.
  /// ينشئ معاملات الإلغاء لحجز واحد.
  const CancelBookingParams({
    required this.bookingId,
    required this.cancellationReason,
    this.refundPayments = false,
  });

  @override

  /// Comparison keys for the booking, reason, and refund choice.
  /// مفاتيح المقارنة للحجز والسبب وخيار الاسترداد.
  List<Object> get props => [bookingId, cancellationReason, refundPayments];
}
