import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit_type.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس GetUnitTypesByPropertyUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitTypesByPropertyUseCase in the admin unit workflow.
class GetUnitTypesByPropertyUseCase implements UseCase<List<UnitType>, String> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitTypesByPropertyUseCase.
  /// This constructor creates an instance of GetUnitTypesByPropertyUseCase.
  GetUnitTypesByPropertyUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, List<UnitType>>> call(String propertyTypeId) async {
    return await repository.getUnitTypesByProperty(propertyTypeId);
  }
}
