// lib/features/admin_units/domain/usecases/unit_images/reorder_unit_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس ReorderUnitImagesUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ReorderUnitImagesUseCase in the admin unit workflow.
class ReorderUnitImagesUseCase implements UseCase<bool, ReorderImagesParams> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من ReorderUnitImagesUseCase.
  /// This constructor creates an instance of ReorderUnitImagesUseCase.
  ReorderUnitImagesUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(ReorderImagesParams params) async {
    return await repository.reorderImages(
        params.unitId, params.tempKey, params.imageIds);
  }
}

/// يمثل هذا الكلاس ReorderImagesParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ReorderImagesParams in the admin unit workflow.
class ReorderImagesParams {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة imageIds التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the imageIds value used by the admin unit workflow.
  final List<String> imageIds;

  /// ينشئ هذا المُنشئ مثيلاً من ReorderImagesParams.
  /// This constructor creates an instance of ReorderImagesParams.
  ReorderImagesParams({
    this.unitId,
    this.tempKey,
    required this.imageIds,
  });
}
