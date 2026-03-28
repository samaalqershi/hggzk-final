// lib/features/admin_units/domain/repositories/unit_images_repository.dart

import 'package:hggzkportal/features/admin_units/domain/entities/unit_image.dart';
import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:dio/dio.dart';

/// يمثل هذا الكلاس المجرد UnitImagesRepository العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitImagesRepository in the admin unit workflow.
abstract class UnitImagesRepository {
  /// Uploads a single unit image and returns the stored media record.
  /// يرفع صورة واحدة للوحدة ويُرجع سجل الوسائط المخزن بعد حفظها.
  Future<Either<Failure, UnitImage>> uploadImage({
    String? unitId,
    String? sectionId,
    String? unitInSectionId,
    String? tempKey,
    required String filePath,
    String? videoThumbnailPath,
    String? category,
    String? alt,
    bool isPrimary,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  });

  /// ينفذ هذا الأسلوب عملية getUnitImages ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitImages operation in the admin unit workflow.
  Future<Either<Failure, List<UnitImage>>> getUnitImages(String? unitId,
      {String? tempKey});

  /// ينفذ هذا الأسلوب عملية updateImage ضمن مسار إدارة الوحدات.
  /// This method performs the updateImage operation in the admin unit workflow.
  Future<Either<Failure, bool>> updateImage(
    String imageId,
    Map<String, dynamic> data,
  );

  /// ينفذ هذا الأسلوب عملية deleteImage ضمن مسار إدارة الوحدات.
  /// This method performs the deleteImage operation in the admin unit workflow.
  Future<Either<Failure, bool>> deleteImage(String imageId);

  /// ينفذ هذا الأسلوب عملية reorderImages ضمن مسار إدارة الوحدات.
  /// This method performs the reorderImages operation in the admin unit workflow.
  Future<Either<Failure, bool>> reorderImages(
    String? unitId,
    String? tempKey,
    List<String> imageIds,
  );

  /// ينفذ هذا الأسلوب عملية setAsPrimaryImage ضمن مسار إدارة الوحدات.
  /// This method performs the setAsPrimaryImage operation in the admin unit workflow.
  Future<Either<Failure, bool>> setAsPrimaryImage(
    String? unitId,
    String? tempKey,
    String imageId,
  );

  /// ينفذ هذا الأسلوب عملية deleteMultipleImages ضمن مسار إدارة الوحدات.
  /// This method performs the deleteMultipleImages operation in the admin unit workflow.
  Future<Either<Failure, bool>> deleteMultipleImages(List<String> imageIds);

  /// ينفذ هذا الأسلوب عملية uploadMultipleImages ضمن مسار إدارة الوحدات.
  /// This method performs the uploadMultipleImages operation in the admin unit workflow.
  Future<Either<Failure, List<UnitImage>>> uploadMultipleImages({
    String? unitId,
    String? tempKey,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  });
}
