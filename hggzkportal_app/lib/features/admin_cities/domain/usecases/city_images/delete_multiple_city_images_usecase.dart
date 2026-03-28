// lib/features/admin_citys/domain/usecases/city_images/delete_multiple_city_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/city_images_repository.dart';

/// Deletes several gallery items in one repository call.
///
/// يحذف عدة عناصر من المعرض عبر استدعاء واحد للمستودع.
class DeleteMultipleCityImagesUseCase implements UseCase<bool, List<String>> {
  /// Repository responsible for executing the bulk deletion.
  ///
  /// المستودع المسؤول عن تنفيذ الحذف الجماعي.
  final CityImagesRepository repository;

  /// Connects the bulk delete operation to the repository layer.
  ///
  /// يربط عملية الحذف الجماعي بطبقة المستودع.
  DeleteMultipleCityImagesUseCase(this.repository);
  @override

  /// يمرر قائمة المعرفات إلى المستودع ثم يعيد نتيجة الحذف الجماعي.
  /// Passes the id list to the repository and returns the bulk-delete
  /// result.
  Future<Either<Failure, bool>> call(List<String> imageIds) async {
    return await repository.deleteMultipleImages(imageIds);
  }
}
