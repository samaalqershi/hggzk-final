import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس UpdateUnitUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateUnitUseCase in the admin unit workflow.
class UpdateUnitUseCase implements UseCase<bool, UpdateUnitParams> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateUnitUseCase.
  /// This constructor creates an instance of UpdateUnitUseCase.
  UpdateUnitUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, bool>> call(UpdateUnitParams params) async {
    return await repository.updateUnit(
      unitId: params.unitId,
      name: params.name,
      nameEn: params.nameEn,
      description: params.description,
      customFeatures: params.customFeatures,
      customFeaturesEn: params.customFeaturesEn,
      pricingMethod: params.pricingMethod,
      fieldValues: params.fieldValues,
      images: params.images,
      adultCapacity: params.adultCapacity,
      childrenCapacity: params.childrenCapacity,
      allowsCancellation: params.allowsCancellation,
      cancellationWindowDays: params.cancellationWindowDays,
    );
  }
}

/// يمثل هذا الكلاس UpdateUnitParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateUnitParams in the admin unit workflow.
class UpdateUnitParams extends Equatable {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// يحتفظ هذا الحقل بقيمة name التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the name value used by the admin unit workflow.
  final String? name;

  final String? nameEn;

  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the description value used by the admin unit workflow.
  final String? description;

  /// يحتفظ هذا الحقل بقيمة customFeatures التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the customFeatures value used by the admin unit workflow.
  final String? customFeatures;

  final String? customFeaturesEn;

  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  final String? pricingMethod;

  /// يحتفظ هذا الحقل بقيمة fieldValues التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldValues value used by the admin unit workflow.
  final List<Map<String, dynamic>>? fieldValues;

  /// يحتفظ هذا الحقل بقيمة images التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the images value used by the admin unit workflow.
  final List<String>? images;

  /// يحتفظ هذا الحقل بقيمة adultCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the adultCapacity value used by the admin unit workflow.
  final int? adultCapacity;

  /// يحتفظ هذا الحقل بقيمة childrenCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the childrenCapacity value used by the admin unit workflow.
  final int? childrenCapacity;

  /// يحتفظ هذا الحقل بقيمة allowsCancellation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the allowsCancellation value used by the admin unit workflow.
  final bool? allowsCancellation;

  /// يحتفظ هذا الحقل بقيمة cancellationWindowDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the cancellationWindowDays value used by the admin unit workflow.
  final int? cancellationWindowDays;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateUnitParams.
  /// This constructor creates an instance of UpdateUnitParams.
  const UpdateUnitParams({
    required this.unitId,
    this.name,
    this.nameEn,
    this.description,
    this.customFeatures,
    this.customFeaturesEn,
    this.pricingMethod,
    this.fieldValues,
    this.images,
    this.adultCapacity,
    this.childrenCapacity,
    this.allowsCancellation,
    this.cancellationWindowDays,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        unitId,
        name,
        nameEn,
        description,
        customFeatures,
        customFeaturesEn,
        pricingMethod,
        fieldValues,
        images,
        adultCapacity,
        childrenCapacity,
        allowsCancellation,
        cancellationWindowDays,
      ];
}
