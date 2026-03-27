
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unit_available_days.dart';
import '../repositories/booking_repository.dart';

class GetUnitAvailableDaysUseCase
    implements UseCase<UnitAvailableDays, GetUnitAvailableDaysParams> {
  final BookingRepository repository;

  GetUnitAvailableDaysUseCase(this.repository);

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

class GetUnitAvailableDaysParams extends Equatable {
  final String unitId;
  final int months;
  final String? excludeBookingId;

  const GetUnitAvailableDaysParams({
    required this.unitId,
    this.months = 3,
    this.excludeBookingId,
  });

  @override
  List<Object?> get props => [unitId, months, excludeBookingId];
}
