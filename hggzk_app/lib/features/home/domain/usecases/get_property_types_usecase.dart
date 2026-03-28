import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property_type.dart';
import '../repositories/home_repository.dart';

/// يجلب أنواع العقارات التي تبدأ منها رحلة التصفح والبحث داخل الصفحة
/// الرئيسية.
/// Loads the property types that act as the entry point for browsing and
/// filtering on the home screen.
class GetPropertyTypesUseCase implements UseCase<List<PropertyType>, NoParams> {
  /// المستودع الذي يوفر أنواع العقارات من الشبكة أو الكاش.
  /// Repository that provides property types from network or cache.
  final HomeRepository repository;

  /// يربط حالة الاستخدام بالمستودع الذي ينفذ القراءة الفعلية.
  /// Binds the use case to the repository that performs the actual fetch.
  GetPropertyTypesUseCase(this.repository);
  @override
  Future<Either<Failure, List<PropertyType>>> call(NoParams params) async {
    return repository.getPropertyTypes();
  }
}
