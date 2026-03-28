import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unit_availability.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `CheckAvailabilityUseCase`.
class CheckAvailabilityUseCase
    implements UseCase<UnitAvailability, CheckAvailabilityParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `CheckAvailabilityUseCase`.
  CheckAvailabilityUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, UnitAvailability>> call(
    CheckAvailabilityParams params,
  ) async {
    return await repository.checkAvailability(
      unitId: params.unitId,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      adultsCount: params.adultsCount,
      childrenCount: params.childrenCount,
      guestsCount: params.guestsCount,
      excludeBookingId: params.excludeBookingId,
    );
  }
}

/// العربية: يمثل `CheckAvailabilityParams`.
class CheckAvailabilityParams extends Equatable {
  /// العربية: يخزن القيمة `unitId`.
  final String unitId;

  /// العربية: يخزن القيمة `checkIn`.
  final DateTime checkIn;

  /// العربية: يخزن القيمة `checkOut`.
  final DateTime checkOut;

  /// العربية: يخزن القيمة `adultsCount`.
  final int adultsCount;

  /// العربية: يخزن القيمة `childrenCount`.
  final int childrenCount;

  /// العربية: يخزن القيمة `guestsCount`.
  final int guestsCount;

  /// العربية: يخزن القيمة `excludeBookingId`.
  final String? excludeBookingId;

  /// العربية: ينشئ مثيلًا جديدًا من `CheckAvailabilityParams`.
  const CheckAvailabilityParams({
    required this.unitId,
    required this.checkIn,
    required this.checkOut,
    required this.adultsCount,
    required this.childrenCount,
    this.excludeBookingId,
  }) : guestsCount = adultsCount + childrenCount;

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        unitId,
        checkIn,
        checkOut,
        adultsCount,
        childrenCount,
        guestsCount,
        excludeBookingId
      ];
}
