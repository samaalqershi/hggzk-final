import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property_types_with_units.dart';
import '../repositories/home_repository.dart';

/// يطلب الحمولة الموحدة التي تضم أنواع العقارات مع أنواع الوحدات التابعة لها
/// لتقليل عدد الطلبات عند تهيئة الصفحة الرئيسية.
/// Requests the unified payload that contains property types together with
/// their unit types to reduce the number of calls made during home-screen
/// initialization.
class GetPropertyTypesWithUnitsUseCase
    implements UseCase<PropertyTypesWithUnits, NoParams> {
  /// المستودع الذي ينفذ الجلب الموحد للأنواع الأساسية والتابعة.
  /// Repository responsible for the combined fetch of primary and dependent
  /// types.
  final HomeRepository repository;

  /// يربط حالة الاستخدام بالمستودع الذي يوفر الحمولة الموحدة.
  /// Binds the use case to the repository that exposes the combined payload.
  GetPropertyTypesWithUnitsUseCase(this.repository);
  @override
  Future<Either<Failure, PropertyTypesWithUnits>> call(NoParams params) {
    return repository.getPropertyTypesWithUnits();
  }
}
