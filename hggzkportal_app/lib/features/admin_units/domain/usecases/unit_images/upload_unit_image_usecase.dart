// lib/features/admin_units/domain/usecases/unit_images/upload_unit_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/unit_image.dart';
import '../../repositories/unit_images_repository.dart';

/// يمثل هذا الكلاس UploadUnitImageUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UploadUnitImageUseCase in the admin unit workflow.
class UploadUnitImageUseCase implements UseCase<UnitImage, UploadImageParams> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImagesRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من UploadUnitImageUseCase.
  /// This constructor creates an instance of UploadUnitImageUseCase.
  UploadUnitImageUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, UnitImage>> call(UploadImageParams params) async {
    return await repository.uploadImage(
      unitId: params.unitId,
      sectionId: params.sectionId,
      unitInSectionId: params.unitInSectionId,
      tempKey: params.tempKey,
      filePath: params.filePath,
      videoThumbnailPath: params.videoThumbnailPath,
      category: params.category,
      alt: params.alt,
      isPrimary: params.isPrimary,
      order: params.order,
      tags: params.tags,
      onSendProgress: params.onSendProgress,
    );
  }
}

/// يمثل هذا الكلاس UploadImageParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UploadImageParams in the admin unit workflow.
class UploadImageParams {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة sectionId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the sectionId value used by the admin unit workflow.
  final String? sectionId;

  /// يحتفظ هذا الحقل بقيمة unitInSectionId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitInSectionId value used by the admin unit workflow.
  final String? unitInSectionId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة filePath التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the filePath value used by the admin unit workflow.
  final String filePath;

  /// يحتفظ هذا الحقل بقيمة videoThumbnailPath التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the videoThumbnailPath value used by the admin unit workflow.
  final String? videoThumbnailPath;

  /// يحتفظ هذا الحقل بقيمة category التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the category value used by the admin unit workflow.
  final String? category;

  /// يحتفظ هذا الحقل بقيمة alt التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the alt value used by the admin unit workflow.
  final String? alt;

  /// يحتفظ هذا الحقل بقيمة isPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimary value used by the admin unit workflow.
  final bool isPrimary;

  /// يحتفظ هذا الحقل بقيمة order التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the order value used by the admin unit workflow.
  final int? order;

  /// يحتفظ هذا الحقل بقيمة tags التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tags value used by the admin unit workflow.
  final List<String>? tags;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final void Function(int sent, int total)? onSendProgress;

  /// ينشئ هذا المُنشئ مثيلاً من UploadImageParams.
  /// This constructor creates an instance of UploadImageParams.
  UploadImageParams({
    this.unitId,
    this.sectionId,
    this.unitInSectionId,
    this.tempKey,
    required this.filePath,
    this.videoThumbnailPath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
    this.onSendProgress,
  });
}
