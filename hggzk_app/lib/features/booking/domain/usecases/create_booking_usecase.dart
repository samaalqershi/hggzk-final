import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../entities/booking_request.dart';
import '../repositories/booking_repository.dart';

/// Sends a complete booking request to the repository and creates the stay.
/// يرسل طلب الحجز الكامل إلى المستودع ويُنشئ الإقامة.
class CreateBookingUseCase implements UseCase<Booking, BookingRequest> {
  /// Repository that knows how to submit the booking payload.
  /// المستودع الذي يعرف كيفية إرسال بيانات الحجز.
  final BookingRepository repository;

  /// Injects the booking repository used to persist the request.
  /// يحقن مستودع الحجز المستخدم لحفظ الطلب.
  CreateBookingUseCase(this.repository);

  /// Delegates the booking creation to the repository layer.
  /// يفوض إنشاء الحجز إلى طبقة المستودع.
  @override
  Future<Either<Failure, Booking>> call(BookingRequest params) async {
    return await repository.createBooking(params);
  }
}
