import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit_analytics.dart';
import '../repositories/units_repository.dart';

class GetUnitAnalyticsUseCase
    implements UseCase<UnitAnalytics, GetUnitAnalyticsParams> {
  final UnitsRepository repository;

  GetUnitAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, UnitAnalytics>> call(
    GetUnitAnalyticsParams params,
  ) async {
    return await repository.getUnitAnalytics(
      unitId: params.unitId,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

class GetUnitAnalyticsParams extends Equatable {
  final String unitId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const GetUnitAnalyticsParams({
    required this.unitId,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [unitId, fromDate, toDate];
}
