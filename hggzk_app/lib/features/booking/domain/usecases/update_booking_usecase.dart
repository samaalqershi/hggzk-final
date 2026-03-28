import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `UpdateBookingUseCase`.
class UpdateBookingUseCase implements UseCase<bool, UpdateBookingParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `UpdateBookingUseCase`.
  UpdateBookingUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, bool>> call(UpdateBookingParams params) async {
    return await repository.updateBooking(
      bookingId: params.bookingId,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      guestsCount: params.guestsCount,
      services: params.services,
    );
  }
}

/// العربية: يمثل `UpdateBookingParams`.
class UpdateBookingParams {
  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// العربية: يخزن القيمة `checkIn`.
  final DateTime? checkIn;

  /// العربية: يخزن القيمة `checkOut`.
  final DateTime? checkOut;

  /// العربية: يخزن القيمة `guestsCount`.
  final int? guestsCount;

  /// العربية: يخزن القيمة `services`.
  final List<Map<String, dynamic>>? services;

  /// العربية: ينشئ مثيلًا جديدًا من `UpdateBookingParams`.
  UpdateBookingParams({
    required this.bookingId,
    this.checkIn,
    this.checkOut,
    this.guestsCount,
    this.services,
  });
}
