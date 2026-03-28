// lib/features/admin_citys/domain/usecases/city_images/update_city_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/city_images_repository.dart';

/// Applies metadata changes to a single city image.
///
/// يطبّق تعديلات البيانات الوصفية على صورة مدينة واحدة.
class UpdateCityImageUseCase implements UseCase<bool, UpdateImageParams> {
  /// Repository used to persist the image update.
  ///
  /// المستودع المستخدم لحفظ تعديل الصورة.
  final CityImagesRepository repository;

  /// Links the update operation to the repository layer.
  ///
  /// يربط عملية التحديث بطبقة المستودع.
  UpdateCityImageUseCase(this.repository);
  @override

  /// يمرر معرّف الصورة والحقول الجزئية إلى المستودع ثم يعيد نتيجة التحديث.
  /// Passes the image id and partial data to the repository and returns the
  /// update result.
  Future<Either<Failure, bool>> call(UpdateImageParams params) async {
    return await repository.updateImage(params.imageId, params.data);
  }
}

/// يجمع معرّف الصورة والبيانات الجزئية المراد تطبيقها في طلب تعديل واحد.
/// Collects the image id and the partial patch data into one update request.
class UpdateImageParams {
  /// Identifier of the image that should be updated.
  ///
  /// معرّف الصورة التي يجب تحديثها.
  final String imageId;

  /// Partial payload containing the fields that should be changed.
  ///
  /// حمولة جزئية تتضمن الحقول المطلوب تعديلها.
  final Map<String, dynamic> data;

  /// Wraps the target image and its patch data into one request object.
  ///
  /// يجمع الصورة المستهدفة وبيانات التعديل في كائن طلب واحد.
  UpdateImageParams({
    required this.imageId,
    required this.data,
  });
}
