// lib/features/admin_sections/domain/repositories/section_images_repository.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/section_image.dart';

/// Exposes image management for section content, including draft uploads that
/// are still tied to a temporary key before the section is persisted.
///
/// يوفّر إدارة صور الأقسام بما في ذلك الرفع المؤقت المرتبط بمفتاح draft
/// قبل تثبيت القسم نهائيًا.
abstract class SectionImagesRepository {
  /// Uploads one image either against a saved section or against a temporary
  /// draft key while the section is still being created.
  ///
  /// ترفع صورة واحدة إما إلى قسم محفوظ أو إلى مفتاح مؤقت أثناء إنشاء القسم.
  Future<Either<Failure, SectionImage>> uploadImage({
    String? sectionId,
    String? tempKey,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  });

  /// Reads the ordered image list for a section or for an in-progress draft.
  ///
  /// تقرأ قائمة الصور المرتبة لقسم محفوظ أو مسودة قيد الإنشاء.
  Future<Either<Failure, List<SectionImage>>> getSectionImages(
    String? sectionId, {
    String? tempKey,
  });

  /// Applies metadata changes such as title, alt text, or ordering hints.
  ///
  /// تطبق تغييرات البيانات الوصفية مثل العنوان والنص البديل وتلميحات الترتيب.
  Future<Either<Failure, bool>> updateImage(
    String imageId,
    Map<String, dynamic> data,
  );

  /// Removes a single image from the section image collection.
  ///
  /// تحذف صورة واحدة من مجموعة صور القسم.
  Future<Either<Failure, bool>> deleteImage(String imageId);

  /// Saves a new visual order for the images already attached to the section.
  ///
  /// يحفظ ترتيبًا بصريًا جديدًا للصور المرتبطة بالقسم.
  Future<Either<Failure, bool>> reorderImages(
    String? sectionId,
    String? tempKey,
    List<String> imageIds,
  );

  /// Marks one image as the primary visual used in cards and previews.
  ///
  /// يحدد صورة واحدة كصورة رئيسية تستخدم في البطاقات والمعاينات.
  Future<Either<Failure, bool>> setAsPrimaryImage(
    String? sectionId,
    String? tempKey,
    String imageId,
  );

  /// Removes a batch of images in one server call.
  ///
  /// يحذف مجموعة صور في طلب واحد إلى الخادم.
  Future<Either<Failure, bool>> deleteMultipleImages(List<String> imageIds);

  /// Uploads multiple files and reports progress per file so the UI can keep
  /// the operator informed during long uploads.
  ///
  /// ترفع عدة ملفات مع الإبلاغ عن التقدم لكل ملف حتى تبقى الواجهة
  /// واضحة أثناء الرفع الطويل.
  Future<Either<Failure, List<SectionImage>>> uploadMultipleImages({
    String? sectionId,
    String? tempKey,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  });
}
