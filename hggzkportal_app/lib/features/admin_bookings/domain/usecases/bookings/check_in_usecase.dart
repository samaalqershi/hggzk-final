import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Marks a booking as checked in through the bookings repository.
/// يعلّم الحجز على أنه تم تسجيل الوصول إليه عبر مستودع الحجوزات.
class CheckInUseCase implements UseCase<bool, CheckInParams> {
  /// Repository that performs the check-in operation.
  /// المستودع الذي ينفذ عملية تسجيل الوصول.
  final BookingsRepository repository;

  /// Creates the use case with its bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  CheckInUseCase(this.repository);

  @override

  /// Delegates the check-in request for a single booking id.
  /// يفوض طلب تسجيل الوصول لمعرّف حجز واحد.
  Future<Either<Failure, bool>> call(CheckInParams params) async {
    return await repository.checkIn(bookingId: params.bookingId);
  }
}

/// Parameters required to check a booking into the system.
/// المعاملات المطلوبة لتسجيل الحجز كواصل إلى النظام.
class CheckInParams extends Equatable {
  /// Identifier of the booking to check in.
  /// معرّف الحجز المطلوب تسجيل الوصول له.
  final String bookingId;

  /// Creates the check-in parameters for one booking.
  /// ينشئ معاملات تسجيل الوصول لحجز واحد.
  const CheckInParams({required this.bookingId});

  @override

  /// Comparison key for the booking being checked in.
  /// مفتاح المقارنة للحجز الجاري تسجيل الوصول له.
  List<Object> get props => [bookingId];
}
