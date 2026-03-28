import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/reference_repository.dart';

/// يربط طلب المدن في الواجهة بمستودع المراجع حتى تبقى الشاشة
/// منفصلة عن تفاصيل الجلب والتخزين.
/// Bridges the city request in the UI to the reference repository so
/// the screen stays separate from fetch and storage details.
class GetCitiesUseCase implements UseCase<List<City>, NoParams> {
  /// المرجع الذي ينفذ استعلام المدن.
  /// Reference that performs the city query.
  final ReferenceRepository repository;

  /// يربط الحالة بهذا المستودع المرجعي.
  /// Connects the use case to the reference repository.
  GetCitiesUseCase(this.repository);

  /// يعيد قائمة المدن المرجعية كما هي من المصدر.
  /// Exposes the reference city list as provided by the source.
  @override
  Future<Either<Failure, List<City>>> call(NoParams params) {
    return repository.getCities();
  }
}
