import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/currency.dart';
import '../repositories/reference_repository.dart';

/// يمرر طلب العملات من الواجهة إلى مستودع المراجع بطريقة واضحة
/// ومباشرة.
/// Passes the currency request from the UI to the reference
/// repository in a clear and direct way.
class GetCurrenciesUseCase implements UseCase<List<Currency>, NoParams> {
  /// المرجع الذي يزوّد التطبيق بالعملات المعتمدة.
  /// Reference that supplies the approved currencies.
  final ReferenceRepository repository;

  /// يربط هذا الاستخدام بالمصدر المرجعي للعملات.
  /// Connects this use case to the currency reference source.
  GetCurrenciesUseCase(this.repository);

  /// يعيد العملات المرجعية كي تستخدمها الواجهة في الاختيارات
  /// والقوائم.
  /// Exposes the reference currencies for use in selectors and
  /// lists.
  @override
  Future<Either<Failure, List<Currency>>> call(NoParams params) {
    return repository.getCurrencies();
  }
}
