// lib/features/admin_citys/domain/usecases/city_images/set_primary_city_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/city_images_repository.dart';

/// Marks one gallery item as the primary visual for the city.
///
/// يحدد عنصرًا واحدًا من المعرض كصورة أساسية للمدينة.
class SetPrimaryCityImageUseCase
    implements UseCase<bool, SetPrimaryImageParams> {
  /// Repository used to persist the primary-image selection.
  ///
  /// المستودع المستخدم لحفظ اختيار الصورة الأساسية.
  final CityImagesRepository repository;

  /// Connects the business rule to the repository implementation.
  ///
  /// يربط القاعدة العملية بتنفيذ المستودع.
  SetPrimaryCityImageUseCase(this.repository);
  @override

  /// يمرر معرّف المدينة أو المسودة ومعرّف الصورة إلى المستودع ثم يعيد
  /// نتيجة التعيين.
  /// Passes the city or draft key plus the image id to the repository and
  /// returns the primary-image update result.
  Future<Either<Failure, bool>> call(SetPrimaryImageParams params) async {
    return await repository.setAsPrimaryImage(
        params.cityId, params.tempKey, params.imageId);
  }
}

/// يجمع هدف التعيين مع الصورة المختارة لتصبح الصورة الأساسية للمدينة.
/// Collects the target and selected image so one image can become the city
/// primary photo.
class SetPrimaryImageParams {
  /// Saved city identifier when the gallery already belongs to a record.
  ///
  /// معرّف المدينة المحفوظ عندما يكون المعرض تابعًا لسجل موجود.
  final String? cityId;

  /// Temporary draft key used before the city record exists.
  ///
  /// مفتاح مسودة مؤقت يستخدم قبل وجود سجل المدينة.
  final String? tempKey;

  /// Identifier of the image that should become the city cover.
  ///
  /// معرّف الصورة التي يجب أن تصبح غلافًا للمدينة.
  final String imageId;

  /// Bundles the target and the selected primary image into a single request.
  ///
  /// يجمع الهدف والصورة المختارة في طلب واحد ثابت.
  SetPrimaryImageParams({
    this.cityId,
    this.tempKey,
    required this.imageId,
  });
}
