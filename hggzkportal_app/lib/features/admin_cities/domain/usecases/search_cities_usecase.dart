import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/cities_repository.dart';

/// Executes a catalog search against the city repository.
///
/// ينفذ بحثًا داخل دليل المدن عبر المستودع.
class SearchCitiesUseCase implements UseCase<List<City>, String> {
  /// Repository used to resolve the free-text search.
  ///
  /// المستودع المستخدم لحل البحث النصي الحر.
  final CitiesRepository repository;

  /// Creates the search operation boundary for the admin feature.
  ///
  /// ينشئ حد العملية الخاص بالبحث داخل الميزة الإدارية.
  SearchCitiesUseCase(this.repository);

  @override

  /// Sends the raw query string to the repository and returns the matching cities.
  ///
  /// يرسل نص البحث الخام إلى المستودع ويعيد المدن المطابقة.
  Future<Either<Failure, List<City>>> call(String query) async {
    return await repository.searchCities(query);
  }
}
