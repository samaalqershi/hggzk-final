import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzk/features/home/domain/entities/unit_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/home_repository.dart';

/// يجلب أنواع الوحدات التابعة لنوع عقار محدد مع الحقول التي تعتمد عليها
/// الواجهة لبناء الفلاتر الديناميكية.
/// Loads the unit types for a given property type together with the field
/// definitions needed to build dynamic filters in the UI.
class GetUnitTypesWithFieldsUseCase
    implements UseCase<List<UnitType>, GetUnitTypesParams> {
  /// المستودع الذي يقرأ أنواع الوحدات من المصدر الأنسب.
  /// Repository that reads unit types from the most appropriate source.
  final HomeRepository repository;

  /// يربط حالة الاستخدام بالمستودع المسؤول عن تحميل أنواع الوحدات.
  /// Binds the use case to the repository responsible for loading unit types.
  GetUnitTypesWithFieldsUseCase(this.repository);
  @override
  Future<Either<Failure, List<UnitType>>> call(
      GetUnitTypesParams params) async {
    return repository.getUnitTypes(propertyTypeId: params.propertyTypeId);
  }
}

/// يحمّل معرّف نوع العقار الذي ستُشتق منه أنواع الوحدات المطلوبة.
/// Carries the property-type identifier from which the requested unit types
/// should be derived.
class GetUnitTypesParams extends Equatable {
  /// معرّف نوع العقار الأب المطلوب تحميل أنواع الوحدات التابعة له.
  /// Identifier of the parent property type whose unit types should be loaded.
  final String propertyTypeId;

  /// ينشئ معلمات طلب أنواع الوحدات.
  /// Creates the parameter object for a unit-type request.
  const GetUnitTypesParams({required this.propertyTypeId});
  @override
  List<Object?> get props => [propertyTypeId];
}
