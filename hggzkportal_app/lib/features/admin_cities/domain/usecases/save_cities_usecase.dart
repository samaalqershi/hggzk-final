import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/cities_repository.dart';

/// Persists a batch of cities after bulk editing in the admin console.
///
/// يحفظ دفعة من المدن بعد التعديل الجماعي في لوحة الإدارة.
class SaveCitiesUseCase implements UseCase<bool, List<City>> {
  /// Repository responsible for saving the full collection.
  ///
  /// المستودع المسؤول عن حفظ المجموعة كاملة.
  final CitiesRepository repository;

  /// Links the batch-saving use case to the repository implementation.
  ///
  /// يربط هذا الـ use case بتنفيذ المستودع.
  SaveCitiesUseCase(this.repository);

  @override

  /// Persists the provided list of cities and returns whether the batch succeeded.
  ///
  /// يحفظ قائمة المدن المعطاة ويعيد ما إذا كانت الدفعة قد نجحت.
  Future<Either<Failure, bool>> call(List<City> cities) async {
    return await repository.saveCities(cities);
  }
}
