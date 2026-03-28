import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit_analytics.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس GetUnitAnalyticsUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitAnalyticsUseCase in the admin unit workflow.
class GetUnitAnalyticsUseCase
    implements UseCase<UnitAnalytics, GetUnitAnalyticsParams> {
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the repository value used by the admin unit workflow.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitAnalyticsUseCase.
  /// This constructor creates an instance of GetUnitAnalyticsUseCase.
  GetUnitAnalyticsUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
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

/// يمثل هذا الكلاس GetUnitAnalyticsParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitAnalyticsParams in the admin unit workflow.
class GetUnitAnalyticsParams extends Equatable {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// يحتفظ هذا الحقل بقيمة fromDate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fromDate value used by the admin unit workflow.
  final DateTime? fromDate;

  /// يحتفظ هذا الحقل بقيمة toDate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the toDate value used by the admin unit workflow.
  final DateTime? toDate;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitAnalyticsParams.
  /// This constructor creates an instance of GetUnitAnalyticsParams.
  const GetUnitAnalyticsParams({
    required this.unitId,
    this.fromDate,
    this.toDate,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, fromDate, toDate];
}
