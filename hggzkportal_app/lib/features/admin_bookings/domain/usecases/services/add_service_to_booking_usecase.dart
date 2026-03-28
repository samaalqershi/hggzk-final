import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Adds one service to an existing booking.
/// يضيف خدمة واحدة إلى حجز موجود.
class AddServiceToBookingUseCase
    implements UseCase<bool, AddServiceToBookingParams> {
  /// Repository that performs the service addition.
  /// المستودع الذي ينفذ عملية إضافة الخدمة.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  AddServiceToBookingUseCase(this.repository);

  @override

  /// Delegates the addition request to the bookings repository.
  /// يفوض طلب الإضافة إلى مستودع الحجوزات.
  Future<Either<Failure, bool>> call(AddServiceToBookingParams params) async {
    return await repository.addServiceToBooking(
      bookingId: params.bookingId,
      serviceId: params.serviceId,
    );
  }
}

/// Parameters required to add one service to a booking.
/// المعاملات المطلوبة لإضافة خدمة واحدة إلى حجز.
class AddServiceToBookingParams extends Equatable {
  /// Identifier of the booking to modify.
  /// معرّف الحجز المطلوب تعديله.
  final String bookingId;

  /// Identifier of the service to add.
  /// معرّف الخدمة المطلوب إضافتها.
  final String serviceId;

  /// Creates the addition parameters for a booking and service pair.
  /// ينشئ معاملات الإضافة لزوج الحجز والخدمة.
  const AddServiceToBookingParams({
    required this.bookingId,
    required this.serviceId,
  });

  @override

  /// Comparison keys for the booking and service identifiers.
  /// مفاتيح المقارنة لمعرّفي الحجز والخدمة.
  List<Object> get props => [bookingId, serviceId];
}
