import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Removes one service from an existing booking.
/// يزيل خدمة واحدة من حجز موجود.
class RemoveServiceFromBookingUseCase
    implements UseCase<bool, RemoveServiceFromBookingParams> {
  /// Repository that performs the service removal.
  /// المستودع الذي ينفذ عملية إزالة الخدمة.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  RemoveServiceFromBookingUseCase(this.repository);

  @override

  /// Delegates the removal request to the bookings repository.
  /// يفوض طلب الإزالة إلى مستودع الحجوزات.
  Future<Either<Failure, bool>> call(
      RemoveServiceFromBookingParams params) async {
    return await repository.removeServiceFromBooking(
      bookingId: params.bookingId,
      serviceId: params.serviceId,
    );
  }
}

/// Parameters required to remove one service from a booking.
/// المعاملات المطلوبة لإزالة خدمة واحدة من حجز.
class RemoveServiceFromBookingParams extends Equatable {
  /// Identifier of the booking to modify.
  /// معرّف الحجز المطلوب تعديله.
  final String bookingId;

  /// Identifier of the service to remove.
  /// معرّف الخدمة المطلوب إزالتها.
  final String serviceId;

  /// Creates the removal parameters for a booking and service pair.
  /// ينشئ معاملات الإزالة لزوج الحجز والخدمة.
  const RemoveServiceFromBookingParams({
    required this.bookingId,
    required this.serviceId,
  });

  @override

  /// Comparison keys for the booking and service identifiers.
  /// مفاتيح المقارنة لمعرّفي الحجز والخدمة.
  List<Object> get props => [bookingId, serviceId];
}
