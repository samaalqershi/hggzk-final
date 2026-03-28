import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `AddServicesToBookingUseCase`.
class AddServicesToBookingUseCase
    implements UseCase<Booking, AddServicesToBookingParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `AddServicesToBookingUseCase`.
  AddServicesToBookingUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, Booking>> call(
      AddServicesToBookingParams params) async {
    return await repository.addServicesToBooking(
      bookingId: params.bookingId,
      serviceId: params.serviceId,
      quantity: params.quantity,
    );
  }
}

/// العربية: يمثل `AddServicesToBookingParams`.
class AddServicesToBookingParams extends Equatable {
  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;

  /// العربية: يخزن القيمة `quantity`.
  final int quantity;

  /// العربية: ينشئ مثيلًا جديدًا من `AddServicesToBookingParams`.
  const AddServicesToBookingParams({
    required this.bookingId,
    required this.serviceId,
    required this.quantity,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [bookingId, serviceId, quantity];
}
