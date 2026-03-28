// lib/features/admin_units/domain/usecases/unit_images/set_primary_unit_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس SetPrimaryUnitImageUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SetPrimaryUnitImageUseCase in the admin unit workflow.
class SetPrimaryUnitImageUseCase
    implements UseCase<bool, SetPrimaryImageParams> {
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the repository value used by the admin unit workflow.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من SetPrimaryUnitImageUseCase.
  /// This constructor creates an instance of SetPrimaryUnitImageUseCase.
  SetPrimaryUnitImageUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(SetPrimaryImageParams params) async {
    return await repository.setAsPrimaryImage(
        params.unitId, params.tempKey, params.imageId);
  }
}

/// يمثل هذا الكلاس SetPrimaryImageParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SetPrimaryImageParams in the admin unit workflow.
class SetPrimaryImageParams {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the imageId value used by the admin unit workflow.
  final String imageId;

  /// ينشئ هذا المُنشئ مثيلاً من SetPrimaryImageParams.
  /// This constructor creates an instance of SetPrimaryImageParams.
  SetPrimaryImageParams({
    this.unitId,
    this.tempKey,
    required this.imageId,
  });
}
