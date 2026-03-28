import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cities_repository.dart';

/// Deletes a city entry from the administrative catalog.
///
/// يحذف مدينة من الدليل الإداري.
class DeleteCityUseCase implements UseCase<bool, String> {
  /// Repository that performs the deletion request.
  ///
  /// المستودع الذي ينفذ طلب الحذف.
  final CitiesRepository repository;

  /// Wires the repository into the use case boundary.
  ///
  /// يربط المستودع بحد use case.
  DeleteCityUseCase(this.repository);

  @override

  /// Sends the city name to the repository and returns whether deletion succeeded.
  ///
  /// يرسل اسم المدينة إلى المستودع ويعيد ما إذا نجح الحذف.
  Future<Either<Failure, bool>> call(String name) async {
    return await repository.deleteCity(name);
  }
}
