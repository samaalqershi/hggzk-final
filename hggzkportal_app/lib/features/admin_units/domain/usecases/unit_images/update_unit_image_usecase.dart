// lib/features/admin_units/domain/usecases/unit_images/update_unit_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس UpdateUnitImageUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateUnitImageUseCase in the admin unit workflow.
class UpdateUnitImageUseCase implements UseCase<bool, UpdateImageParams> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateUnitImageUseCase.
  /// This constructor creates an instance of UpdateUnitImageUseCase.
  UpdateUnitImageUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(UpdateImageParams params) async {
    return await repository.updateImage(params.imageId, params.data);
  }
}

/// يمثل هذا الكلاس UpdateImageParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateImageParams in the admin unit workflow.
class UpdateImageParams {
  /// This field keeps the imageId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  final String imageId;

  /// يحتفظ هذا الحقل بقيمة data التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the data value used by the admin unit workflow.
  final Map<String, dynamic> data;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateImageParams.
  /// This constructor creates an instance of UpdateImageParams.
  UpdateImageParams({
    required this.imageId,
    required this.data,
  });
}
