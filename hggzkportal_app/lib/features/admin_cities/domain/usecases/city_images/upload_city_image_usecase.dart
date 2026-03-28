// lib/features/admin_citys/domain/usecases/city_images/upload_city_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/city_image.dart';
import '../../repositories/city_images_repository.dart';

/// Uploads one city media asset and returns its persisted metadata.
///
/// يرفع ملف وسائط واحدًا للمدينة ويعيد بياناته بعد الحفظ.
class UploadCityImageUseCase implements UseCase<CityImage, UploadImageParams> {
  /// Repository used to perform the upload request.
  ///
  /// المستودع المستخدم لتنفيذ طلب الرفع.
  final CityImagesRepository repository;

  /// Connects the upload use case to the repository boundary.
  ///
  /// يربط use case الرفع بحد المستودع.
  UploadCityImageUseCase(this.repository);
  @override

  /// يمرر بيانات الملف ومعاينته وخصائصه إلى المستودع ثم يعيد الصورة
  /// المحفوظة.
  /// Passes the file data, preview flags, and metadata to the repository and
  /// returns the saved image record.
  Future<Either<Failure, CityImage>> call(UploadImageParams params) async {
    return await repository.uploadImage(
      cityId: params.cityId,
      tempKey: params.tempKey,
      filePath: params.filePath,
      category: params.category,
      alt: params.alt,
      isPrimary: params.isPrimary,
      order: params.order,
      tags: params.tags,
      onSendProgress: params.onSendProgress,
    );
  }
}

/// يجمع كل تفاصيل رفع صورة مدينة واحدة في طلب immutable واحد.
/// Collects all details for uploading one city image into a single immutable
/// request.
class UploadImageParams {
  /// Saved city identifier when the file belongs to an existing record.
  ///
  /// معرّف المدينة المحفوظ عندما ينتمي الملف إلى سجل موجود.
  final String? cityId;

  /// Temporary draft key used before the city itself exists.
  ///
  /// مفتاح مسودة مؤقت يستخدم قبل وجود المدينة نفسها.
  final String? tempKey;

  /// Local file path chosen by the admin.
  ///
  /// مسار الملف المحلي الذي اختاره المستخدم.
  final String filePath;

  /// Optional category assigned to the uploaded media.
  ///
  /// فئة اختيارية تُسند إلى الوسائط المرفوعة.
  final String? category;

  /// Optional caption or accessibility description.
  ///
  /// وصف اختياري أو نص بديل للوصولية.
  final String? alt;

  /// Marks the upload as the city cover when needed.
  ///
  /// يحدد الرفع كغلاف للمدينة عند الحاجة.
  final bool isPrimary;

  /// Desired ordering index in the gallery.
  ///
  /// رقم الترتيب المطلوب داخل المعرض.
  final int? order;

  /// Tags that should accompany the file in storage.
  ///
  /// الوسوم التي يجب أن ترافق الملف في التخزين.
  final List<String>? tags;

  /// Optional progress callback forwarded to the transport layer.
  ///
  /// استدعاء اختياري للتقدم يُمرر إلى طبقة النقل.
  final void Function(int sent, int total)? onSendProgress;

  /// Collects the upload request into one immutable parameter object.
  ///
  /// يجمع طلب الرفع في كائن معاملات ثابت واحد.
  UploadImageParams({
    this.cityId,
    this.tempKey,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
    this.onSendProgress,
  });
}
