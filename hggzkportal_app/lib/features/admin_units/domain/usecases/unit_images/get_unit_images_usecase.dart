// lib/features/admin_units/domain/usecases/unit_images/get_unit_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/unit_image.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس GetUnitImagesUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitImagesUseCase in the admin unit workflow.
class GetUnitImagesUseCase
    implements UseCase<List<UnitImage>, GetUnitImagesParams> {
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the repository value used by the admin unit workflow.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitImagesUseCase.
  /// This constructor creates an instance of GetUnitImagesUseCase.
  GetUnitImagesUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, List<UnitImage>>> call(
      GetUnitImagesParams params) async {
    return await repository.getUnitImages(params.unitId,
        tempKey: params.tempKey);
  }
}

/// يمثل هذا الكلاس GetUnitImagesParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitImagesParams in the admin unit workflow.
class GetUnitImagesParams {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitImagesParams.
  /// This constructor creates an instance of GetUnitImagesParams.
  GetUnitImagesParams({this.unitId, this.tempKey});
}
