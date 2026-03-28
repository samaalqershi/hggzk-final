import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency.dart';
import '../repositories/reference_repository.dart';

/// Executes the `GetCurrenciesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `GetCurrenciesUseCase`.
class GetCurrenciesUseCase implements UseCase<List<Currency>, NoParams> {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ReferenceRepository repository;

  /// Builds a new `GetCurrenciesUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `GetCurrenciesUseCase`.
  GetCurrenciesUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<Currency>>> call(NoParams params) {
    return repository.getCurrencies();
  }
}
