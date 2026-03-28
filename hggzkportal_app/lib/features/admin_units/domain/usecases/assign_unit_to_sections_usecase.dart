import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس AssignUnitToSectionsUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for AssignUnitToSectionsUseCase in the admin unit workflow.
class AssignUnitToSectionsUseCase
    implements UseCase<bool, AssignUnitToSectionsParams> {
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the repository value used by the admin unit workflow.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من AssignUnitToSectionsUseCase.
  /// This constructor creates an instance of AssignUnitToSectionsUseCase.
  AssignUnitToSectionsUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(AssignUnitToSectionsParams params) async {
    return await repository.assignUnitToSections(
      params.unitId,
      params.sectionIds,
    );
  }
}

/// يمثل هذا الكلاس AssignUnitToSectionsParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for AssignUnitToSectionsParams in the admin unit workflow.
class AssignUnitToSectionsParams extends Equatable {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// يحتفظ هذا الحقل بقيمة sectionIds التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the sectionIds value used by the admin unit workflow.
  final List<String> sectionIds;

  /// ينشئ هذا المُنشئ مثيلاً من AssignUnitToSectionsParams.
  /// This constructor creates an instance of AssignUnitToSectionsParams.
  const AssignUnitToSectionsParams({
    required this.unitId,
    required this.sectionIds,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [unitId, sectionIds];
}
