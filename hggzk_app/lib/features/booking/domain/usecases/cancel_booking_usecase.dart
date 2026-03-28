import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `CancelBookingUseCase`.
class CancelBookingUseCase implements UseCase<bool, CancelBookingParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `CancelBookingUseCase`.
  CancelBookingUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, bool>> call(CancelBookingParams params) async {
    return await repository.cancelBooking(
      bookingId: params.bookingId,
      userId: params.userId,
      reason: params.reason,
      refundPayments: params.refundPayments,
    );
  }
}

/// العربية: يمثل `CancelBookingParams`.
class CancelBookingParams extends Equatable {
  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// العربية: يخزن القيمة `reason`.
  final String reason;

  /// العربية: يخزن القيمة `refundPayments`.
  final bool refundPayments;

  /// العربية: ينشئ مثيلًا جديدًا من `CancelBookingParams`.
  const CancelBookingParams({
    required this.bookingId,
    required this.userId,
    required this.reason,
    this.refundPayments = false,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [bookingId, userId, reason, refundPayments];
}
