import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/amenities_repository.dart';

/// يحذف مرفقًا واحدًا من النظام عندما يطلب المشرف إزالته نهائيًا.
/// Deletes a single amenity from the system when the admin requests a full
/// removal.
class DeleteAmenityUseCase implements UseCase<bool, String> {
  /// المستودع الذي ينفذ عملية حذف المرفق فعليًا.
  /// The repository that performs the actual amenity deletion.
  final AmenitiesRepository repository;

  /// Creates the deletion use case with the backing amenities repository.
  DeleteAmenityUseCase(this.repository);

  @override

  /// يمرر معرّف المرفق إلى المستودع ويعيد نتيجة الحذف كما هي.
  /// Passes the amenity id to the repository and returns the delete result as
  /// received.
  Future<Either<Failure, bool>> call(String amenityId) async {
    return await repository.deleteAmenity(amenityId);
  }
}
