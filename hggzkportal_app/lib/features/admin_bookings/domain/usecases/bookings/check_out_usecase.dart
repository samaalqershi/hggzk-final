import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Marks a booking as checked out through the bookings repository.
/// يعلّم الحجز على أنه تم تسجيل المغادرة له عبر مستودع الحجوزات.
class CheckOutUseCase implements UseCase<bool, CheckOutParams> {
  /// Repository that performs the check-out operation.
  /// المستودع الذي ينفذ عملية تسجيل المغادرة.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  CheckOutUseCase(this.repository);

  @override

  /// Delegates the check-out request for a single booking id.
  /// يفوض طلب تسجيل المغادرة لمعرّف حجز واحد.
  Future<Either<Failure, bool>> call(CheckOutParams params) async {
    return await repository.checkOut(bookingId: params.bookingId);
  }
}

/// Parameters required to check a booking out of the system.
/// المعاملات المطلوبة لتسجيل الحجز كمغادر من النظام.
class CheckOutParams extends Equatable {
  /// Identifier of the booking to check out.
  /// معرّف الحجز المطلوب تسجيل المغادرة له.
  final String bookingId;

  /// Creates the check-out parameters for one booking.
  /// ينشئ معاملات تسجيل المغادرة لحجز واحد.
  const CheckOutParams({required this.bookingId});

  @override

  /// Comparison key for the booking being checked out.
  /// مفتاح المقارنة للحجز الجاري تسجيل المغادرة له.
  List<Object> get props => [bookingId];
}
