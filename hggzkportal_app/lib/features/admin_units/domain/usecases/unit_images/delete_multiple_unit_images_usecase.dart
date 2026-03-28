// lib/features/admin_units/domain/usecases/unit_images/delete_multiple_unit_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس DeleteMultipleUnitImagesUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeleteMultipleUnitImagesUseCase in the admin unit workflow.
class DeleteMultipleUnitImagesUseCase implements UseCase<bool, List<String>> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من DeleteMultipleUnitImagesUseCase.
  /// This constructor creates an instance of DeleteMultipleUnitImagesUseCase.
  DeleteMultipleUnitImagesUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(List<String> imageIds) async {
    return await repository.deleteMultipleImages(imageIds);
  }
}
