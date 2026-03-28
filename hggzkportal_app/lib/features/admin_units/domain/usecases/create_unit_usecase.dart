import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس CreateUnitUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for CreateUnitUseCase in the admin unit workflow.
class CreateUnitUseCase implements UseCase<String, CreateUnitParams> {
  /// This field keeps the repository value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من CreateUnitUseCase.
  /// This constructor creates an instance of CreateUnitUseCase.
  CreateUnitUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, String>> call(CreateUnitParams params) async {
    return await repository.createUnit(
      propertyId: params.propertyId,
      unitTypeId: params.unitTypeId,
      name: params.name,
      description: params.description,
      customFeatures: params.customFeatures,
      pricingMethod: params.pricingMethod,
      fieldValues: params.fieldValues,
      images: params.images,
      adultCapacity: params.adultCapacity,
      childrenCapacity: params.childrenCapacity,
      allowsCancellation: params.allowsCancellation,
      cancellationWindowDays: params.cancellationWindowDays,
      tempKey: params.tempKey,
    );
  }
}

/// يمثل هذا الكلاس CreateUnitParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for CreateUnitParams in the admin unit workflow.
class CreateUnitParams extends Equatable {
  /// This field keeps the propertyId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة propertyId التي يعتمد عليها مسار إدارة الوحدات.
  final String propertyId;

  /// يحتفظ هذا الحقل بقيمة unitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeId value used by the admin unit workflow.
  final String unitTypeId;

  /// يحتفظ هذا الحقل بقيمة name التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the name value used by the admin unit workflow.
  final String name;

  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the description value used by the admin unit workflow.
  final String description;

  /// يحتفظ هذا الحقل بقيمة customFeatures التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the customFeatures value used by the admin unit workflow.
  final String customFeatures;

  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  final String pricingMethod;

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

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة allowsCancellation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the allowsCancellation value used by the admin unit workflow.
  final bool? allowsCancellation;

  /// يحتفظ هذا الحقل بقيمة cancellationWindowDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the cancellationWindowDays value used by the admin unit workflow.
  final int? cancellationWindowDays;

  /// ينشئ هذا المُنشئ مثيلاً من CreateUnitParams.
  /// This constructor creates an instance of CreateUnitParams.
  const CreateUnitParams({
    required this.propertyId,
    required this.unitTypeId,
    required this.name,
    required this.description,
    required this.customFeatures,
    required this.pricingMethod,
    this.fieldValues,
    this.images,
    this.adultCapacity,
    this.childrenCapacity,
    this.tempKey,
    this.allowsCancellation,
    this.cancellationWindowDays,
  });

  /// ينفذ هذا الأسلوب عملية toJson ضمن مسار إدارة الوحدات.
  /// This method performs the toJson operation in the admin unit workflow.
  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'unitTypeId': unitTypeId,
        'name': name,
        'description': description,
        'customFeatures': customFeatures,
        'pricingMethod': pricingMethod,
        'fieldValues': fieldValues,
        'images': images,
        'adultCapacity': adultCapacity,
        'childrenCapacity': childrenCapacity,
        'tempKey': tempKey,
        'allowsCancellation': allowsCancellation,
        'cancellationWindowDays': cancellationWindowDays,
      };

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        propertyId,
        unitTypeId,
        name,
        description,
        customFeatures,
        pricingMethod,
        fieldValues,
        images,
        adultCapacity,
        childrenCapacity,
        tempKey,
      ];
}
