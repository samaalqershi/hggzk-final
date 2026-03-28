// lib/features/admin_citys/domain/usecases/city_images/upload_multiple_city_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/city_image.dart';
import '../../repositories/city_images_repository.dart';

/// Uploads a batch of city media files while preserving user-selected order.
///
/// يرفع دفعة من ملفات المدينة مع الحفاظ على الترتيب الذي اختاره المستخدم.
class UploadMultipleCityImagesUseCase
    implements UseCase<List<CityImage>, UploadMultipleImagesParams> {
  /// Repository used to send each upload request.
  ///
  /// المستودع المستخدم لإرسال كل طلب رفع.
  final CityImagesRepository repository;

  /// Connects the batch upload flow to the repository layer.
  ///
  /// يربط مسار الرفع الجماعي بطبقة المستودع.
  UploadMultipleCityImagesUseCase(this.repository);
  @override

  /// يمرر قائمة الملفات مع المسودة أو المدينة المستهدفة إلى المستودع ثم
  /// يعيد الصور المرفوعة.
  /// Passes the file list and the target city or draft key to the repository
  /// and returns the uploaded images.
  Future<Either<Failure, List<CityImage>>> call(
      UploadMultipleImagesParams params) async {
    return await repository.uploadMultipleImages(
      cityId: params.cityId,
      tempKey: params.tempKey,
      filePaths: params.filePaths,
      category: params.category,
      tags: params.tags,
      onProgress: params.onProgress,
    );
  }
}

/// يجمع مدخلات الرفع الجماعي للصور في طلب immutable واحد منظم.
/// Collects the inputs for a bulk image upload into one organized immutable
/// request.
class UploadMultipleImagesParams {
  /// Saved city identifier when the images belong to a persisted record.
  ///
  /// معرّف المدينة المحفوظ عندما تتبع الصور لسجل موجود.
  final String? cityId;

  /// Temporary key used before the city is saved.
  ///
  /// مفتاح مؤقت يُستخدم قبل حفظ المدينة.
  final String? tempKey;

  /// File paths selected by the user in the exact upload order.
  ///
  /// مسارات الملفات التي اختارها المستخدم بنفس ترتيب الرفع.
  final List<String> filePaths;

  /// Optional category applied to all uploaded assets in the batch.
  ///
  /// فئة اختيارية تُطبق على جميع الملفات المرفوعة في الدفعة.
  final String? category;

  /// Tags attached to every uploaded asset in the same batch.
  ///
  /// الوسوم المضافة إلى كل ملف مرفوع داخل الدفعة نفسها.
  final List<String>? tags;

  /// Progress hook forwarded for each file so the UI can reflect upload state.
  ///
  /// استدعاء تقدم يُمرر لكل ملف حتى تعكس الواجهة حالة الرفع.
  final void Function(String filePath, int sent, int total)? onProgress;

  /// Groups the batch-upload inputs into one immutable request object.
  ///
  /// يجمع مدخلات الرفع الجماعي في كائن طلب ثابت واحد.
  UploadMultipleImagesParams({
    this.cityId,
    this.tempKey,
    required this.filePaths,
    this.category,
    this.tags,
    this.onProgress,
  });
}
