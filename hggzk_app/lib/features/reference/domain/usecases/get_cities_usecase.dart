import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/reference_repository.dart';

/// Executes the `GetCitiesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `GetCitiesUseCase`.
class GetCitiesUseCase implements UseCase<List<City>, NoParams> {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ReferenceRepository repository;

  /// Builds a new `GetCitiesUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `GetCitiesUseCase`.
  GetCitiesUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<City>>> call(NoParams params) {
    return repository.getCities();
  }
}
