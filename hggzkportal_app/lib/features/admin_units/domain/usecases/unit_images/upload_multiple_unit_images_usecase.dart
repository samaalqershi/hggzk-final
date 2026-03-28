// lib/features/admin_units/domain/usecases/unit_images/upload_multiple_unit_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/unit_image.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس UploadMultipleUnitImagesUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UploadMultipleUnitImagesUseCase in the admin unit workflow.
class UploadMultipleUnitImagesUseCase
    implements UseCase<List<UnitImage>, UploadMultipleImagesParams> {
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the repository value used by the admin unit workflow.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من UploadMultipleUnitImagesUseCase.
  /// This constructor creates an instance of UploadMultipleUnitImagesUseCase.
  UploadMultipleUnitImagesUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, List<UnitImage>>> call(
      UploadMultipleImagesParams params) async {
    return await repository.uploadMultipleImages(
      unitId: params.unitId,
      tempKey: params.tempKey,
      filePaths: params.filePaths,
      category: params.category,
      tags: params.tags,
      onProgress: params.onProgress,
    );
  }
}

/// يمثل هذا الكلاس UploadMultipleImagesParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UploadMultipleImagesParams in the admin unit workflow.
class UploadMultipleImagesParams {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة filePaths التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the filePaths value used by the admin unit workflow.
  final List<String> filePaths;

  /// يحتفظ هذا الحقل بقيمة category التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the category value used by the admin unit workflow.
  final String? category;

  /// يحتفظ هذا الحقل بقيمة tags التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tags value used by the admin unit workflow.
  final List<String>? tags;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final void Function(String filePath, int sent, int total)? onProgress;

  /// ينشئ هذا المُنشئ مثيلاً من UploadMultipleImagesParams.
  /// This constructor creates an instance of UploadMultipleImagesParams.
  UploadMultipleImagesParams({
    this.unitId,
    this.tempKey,
    required this.filePaths,
    this.category,
    this.tags,
    this.onProgress,
  });
}
