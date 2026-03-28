// lib/features/admin_citys/domain/usecases/city_images/delete_city_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/city_images_repository.dart';

/// Removes one city media item from the repository.
///
/// يحذف عنصر وسائط واحدًا من المستودع.
class DeleteCityImageUseCase implements UseCase<bool, String> {
  /// Repository used to execute the delete request.
  ///
  /// المستودع المستخدم لتنفيذ طلب الحذف.
  final CityImagesRepository repository;

  /// Connects the delete action to the repository layer.
  ///
  /// يربط فعل الحذف بطبقة المستودع.
  DeleteCityImageUseCase(this.repository);
  @override

  /// يمرر معرّف الصورة إلى المستودع ثم يعيد نتيجة الحذف كما هي.
  /// Passes the image id to the repository and returns the delete result as
  /// received.
  Future<Either<Failure, bool>> call(String imageId) async {
    return await repository.deleteImage(imageId);
  }
}
