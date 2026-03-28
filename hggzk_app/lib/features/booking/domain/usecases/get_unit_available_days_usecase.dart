import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unit_available_days.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetUnitAvailableDaysUseCase`.
class GetUnitAvailableDaysUseCase
    implements UseCase<UnitAvailableDays, GetUnitAvailableDaysParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetUnitAvailableDaysUseCase`.
  GetUnitAvailableDaysUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, UnitAvailableDays>> call(
    GetUnitAvailableDaysParams params,
  ) async {
    return repository.getUnitAvailableDays(
      unitId: params.unitId,
      months: params.months,
      excludeBookingId: params.excludeBookingId,
    );
  }
}

/// العربية: يمثل `GetUnitAvailableDaysParams`.
class GetUnitAvailableDaysParams extends Equatable {
  /// العربية: يخزن القيمة `unitId`.
  final String unitId;

  /// العربية: يخزن القيمة `months`.
  final int months;

  /// العربية: يخزن القيمة `excludeBookingId`.
  final String? excludeBookingId;

  /// العربية: ينشئ مثيلًا جديدًا من `GetUnitAvailableDaysParams`.
  const GetUnitAvailableDaysParams({
    required this.unitId,
    this.months = 3,
    this.excludeBookingId,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [unitId, months, excludeBookingId];
}
