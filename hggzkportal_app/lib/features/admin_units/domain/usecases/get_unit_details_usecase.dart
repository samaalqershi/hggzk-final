import 'package:dartz/dartz.dart' hide Unit;
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس GetUnitDetailsUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitDetailsUseCase in the admin unit workflow.
class GetUnitDetailsUseCase implements UseCase<Unit, GetUnitDetailsParams> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitDetailsUseCase.
  /// This constructor creates an instance of GetUnitDetailsUseCase.
  GetUnitDetailsUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, Unit>> call(GetUnitDetailsParams params) async {
    return await repository.getUnitDetails(params.unitId);
  }
}

/// يمثل هذا الكلاس GetUnitDetailsParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitDetailsParams in the admin unit workflow.
class GetUnitDetailsParams extends Equatable {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitDetailsParams.
  /// This constructor creates an instance of GetUnitDetailsParams.
  const GetUnitDetailsParams({required this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [unitId];
}
