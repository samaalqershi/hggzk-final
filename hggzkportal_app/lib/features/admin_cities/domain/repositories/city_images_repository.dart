// lib/features/admin_citys/domain/repositories/city_images_repository.dart

import 'package:hggzkportal/features/admin_cities/domain/entities/city_image.dart';
import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:dio/dio.dart';

/// Repository contract for image operations attached to a city record.
///
/// عقد المستودع الخاص بعمليات الصور المرتبطة بسجل المدينة.
abstract class CityImagesRepository {
  /// Uploads a single media asset and returns the stored image metadata.
  ///
  /// يرفع ملف وسائط واحدًا ويعيد بياناته بعد الحفظ.
  Future<Either<Failure, CityImage>> uploadImage({
    String? cityId,
    String? tempKey,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  });

  /// Retrieves the current gallery items for a city or a temporary draft key.
  ///
  /// يجلب عناصر المعرض الحالية لمدينة محفوظة أو لمفتاح مسودة مؤقت.
  Future<Either<Failure, List<CityImage>>> getCityImages(String? cityId,
      {String? tempKey});

  /// Applies metadata edits to an existing city image.
  ///
  /// يطبّق تعديلات البيانات الوصفية على صورة مدينة موجودة.
  Future<Either<Failure, bool>> updateImage(
    String imageId,
    Map<String, dynamic> data,
  );

  /// Deletes a single image from the gallery.
  ///
  /// يحذف صورة واحدة من المعرض.
  Future<Either<Failure, bool>> deleteImage(String imageId);

  /// Reorders the gallery items to match the user-selected sequence.
  ///
  /// يعيد ترتيب عناصر المعرض لتطابق التسلسل الذي اختاره المستخدم.
  Future<Either<Failure, bool>> reorderImages(
    String? cityId,
    String? tempKey,
    List<String> imageIds,
  );

  /// Marks one image as the primary cover for the city.
  ///
  /// يحدد صورة واحدة لتكون الغلاف الرئيسي للمدينة.
  Future<Either<Failure, bool>> setAsPrimaryImage(
    String? cityId,
    String? tempKey,
    String imageId,
  );

  /// Removes a batch of gallery items in one operation.
  ///
  /// يحذف دفعة من عناصر المعرض في عملية واحدة.
  Future<Either<Failure, bool>> deleteMultipleImages(List<String> imageIds);

  /// Uploads several files and preserves their order and progress callbacks.
  ///
  /// يرفع عدة ملفات مع الحفاظ على الترتيب واستدعاءات التقدم.
  Future<Either<Failure, List<CityImage>>> uploadMultipleImages({
    String? cityId,
    String? tempKey,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  });
}
