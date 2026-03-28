import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit_type.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس GetUnitFieldsUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitFieldsUseCase in the admin unit workflow.
class GetUnitFieldsUseCase implements UseCase<List<UnitTypeField>, String> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitFieldsUseCase.
  /// This constructor creates an instance of GetUnitFieldsUseCase.
  GetUnitFieldsUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, List<UnitTypeField>>> call(String unitTypeId) async {
    return await repository.getUnitFields(unitTypeId);
  }
}
