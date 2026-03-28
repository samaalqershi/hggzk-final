import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cities_repository.dart';

/// Removes a city image from the backend storage and gallery state.
///
/// يحذف صورة مدينة من التخزين الخلفي ومن حالة المعرض.
class DeleteCityImageUseCase implements UseCase<bool, DeleteCityImageParams> {
  /// Repository used to perform the deletion request.
  ///
  /// المستودع المستخدم لتنفيذ طلب الحذف.
  final CitiesRepository repository;

  /// Connects the use case to the repository boundary.
  ///
  /// يربط هذا الـ use case بحد المستودع.
  DeleteCityImageUseCase(this.repository);

  @override

  /// Requests the repository to remove the image identified by the request payload.
  ///
  /// يطلب من المستودع حذف الصورة المحددة في بيانات الطلب.
  Future<Either<Failure, bool>> call(DeleteCityImageParams params) async {
    return await repository.deleteCityImage(params.imageUrl);
  }
}

/// Immutable request object that identifies which city image should be removed.
///
/// كائن طلب ثابت يحدد صورة المدينة التي يجب حذفها.
class DeleteCityImageParams extends Equatable {
  /// City name included for audit trails and parent-context updates.
  ///
  /// اسم المدينة المضاف لأغراض التتبع وتحديث السياق الأب.
  final String cityName;

  /// Public reference of the image that should be removed.
  ///
  /// المرجع العام للصورة التي يجب حذفها.
  final String imageUrl;

  /// Groups the city and image reference into one immutable request object.
  ///
  /// يجمع اسم المدينة ورابط الصورة في كائن طلب ثابت واحد.
  const DeleteCityImageParams({
    required this.cityName,
    required this.imageUrl,
  });

  @override

  /// Comparison keys that identify the city-image pair being deleted.
  ///
  /// مفاتيح المقارنة التي تحدد زوج المدينة والصورة الجاري حذفه.
  List<Object?> get props => [cityName, imageUrl];
}
