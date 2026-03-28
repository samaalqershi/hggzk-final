import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/cities_repository.dart';

/// Creates a new city through the repository boundary used by the admin flow.
///
/// ينشئ مدينة جديدة عبر حد المستودع الذي تعتمد عليه رحلة الإدارة.
class CreateCityUseCase implements UseCase<City, City> {
  /// Repository implementation used to persist the new city.
  ///
  /// تنفيذ المستودع المستخدم لحفظ المدينة الجديدة.
  final CitiesRepository repository;

  /// Binds the use case to the repository that performs the actual write.
  ///
  /// يربط هذا use case بالمستودع الذي ينفذ عملية الكتابة فعليًا.
  CreateCityUseCase(this.repository);

  @override

  /// Forwards the city payload to the repository and returns the created record.
  ///
  /// يمرر بيانات المدينة إلى المستودع ويعيد السجل الذي تم إنشاؤه.
  Future<Either<Failure, City>> call(City city) async {
    return await repository.createCity(city);
  }
}
