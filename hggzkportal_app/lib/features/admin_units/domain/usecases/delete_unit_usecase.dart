import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس DeleteUnitUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeleteUnitUseCase in the admin unit workflow.
class DeleteUnitUseCase implements UseCase<bool, String> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من DeleteUnitUseCase.
  /// This constructor creates an instance of DeleteUnitUseCase.
  DeleteUnitUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(String unitId) async {
    return await repository.deleteUnit(unitId);
  }
}
