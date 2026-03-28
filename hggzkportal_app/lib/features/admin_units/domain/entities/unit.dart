import 'package:equatable/equatable.dart';
import 'pricing_method.dart';
import 'unit_field_value.dart';

/// يمثل هذا الكلاس Unit البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for Unit in the admin unit workflow.
class Unit extends Equatable {
  /// This field keeps the id value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة id التي يعتمد عليها مسار إدارة الوحدات.
  final String id;

  /// يحتفظ هذا الحقل بقيمة propertyId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the propertyId value used by the admin unit workflow.
  final String propertyId;

  /// يحتفظ هذا الحقل بقيمة unitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeId value used by the admin unit workflow.
  final String unitTypeId;

  /// يحتفظ هذا الحقل بقيمة name التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the name value used by the admin unit workflow.
  final String name;

  /// يحتفظ هذا الحقل بقيمة maxCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the maxCapacity value used by the admin unit workflow.
  final int maxCapacity;

  /// يحتفظ هذا الحقل بقيمة discountPercentage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the discountPercentage value used by the admin unit workflow.
  final double discountPercentage;

  /// يحتفظ هذا الحقل بقيمة customFeatures التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the customFeatures value used by the admin unit workflow.
  final String customFeatures;

  /// يحتفظ هذا الحقل بقيمة viewCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the viewCount value used by the admin unit workflow.
  final int viewCount;

  /// يحتفظ هذا الحقل بقيمة bookingCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the bookingCount value used by the admin unit workflow.
  final int bookingCount;

  /// يحتفظ هذا الحقل بقيمة adultsCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the adultsCapacity value used by the admin unit workflow.
  final int? adultsCapacity;

  /// يحتفظ هذا الحقل بقيمة childrenCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the childrenCapacity value used by the admin unit workflow.
  final int? childrenCapacity;

  /// يحتفظ هذا الحقل بقيمة propertyName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the propertyName value used by the admin unit workflow.
  final String propertyName;

  /// يحتفظ هذا الحقل بقيمة unitTypeName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeName value used by the admin unit workflow.
  final String unitTypeName;

  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  final PricingMethod pricingMethod;

  /// يحتفظ هذا الحقل بقيمة fieldValues التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldValues value used by the admin unit workflow.
  final List<UnitFieldValue> fieldValues;

  /// يحتفظ هذا الحقل بقيمة dynamicFields التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the dynamicFields value used by the admin unit workflow.
  final List<FieldGroupWithValues> dynamicFields;

  /// يحتفظ هذا الحقل بقيمة distanceKm التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the distanceKm value used by the admin unit workflow.
  final double? distanceKm;

  /// يحتفظ هذا الحقل بقيمة images التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the images value used by the admin unit workflow.
  final List<String>? images;

  /// يحتفظ هذا الحقل بقيمة allowsCancellation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the allowsCancellation value used by the admin unit workflow.
  final bool allowsCancellation;

  /// يحتفظ هذا الحقل بقيمة cancellationWindowDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the cancellationWindowDays value used by the admin unit workflow.
  final int? cancellationWindowDays;

  /// ينشئ هذا المُنشئ مثيلاً من Unit.
  /// This constructor creates an instance of Unit.
  const Unit({
    required this.id,
    required this.propertyId,
    required this.unitTypeId,
    required this.name,
    this.maxCapacity = 2,
    this.discountPercentage = 0.0,
    required this.customFeatures,
    this.viewCount = 0,
    this.bookingCount = 0,
    this.adultsCapacity,
    this.childrenCapacity,
    required this.propertyName,
    required this.unitTypeName,
    required this.pricingMethod,
    this.fieldValues = const [],
    this.dynamicFields = const [],
    this.distanceKm,
    this.images,
    this.allowsCancellation = true,
    this.cancellationWindowDays,
  });

  /// يعيد هذا getter قيمة featuresList المشتقة من الحالة الحالية.
  /// This getter derives the featuresList value from the current state.
  List<String> get featuresList {
    if (customFeatures.isEmpty) return [];
    return customFeatures.split(',').map((e) => e.trim()).toList();
  }

  /// يعيد هذا getter قيمة capacityDisplay المشتقة من الحالة الحالية.
  /// This getter derives the capacityDisplay value from the current state.
  String get capacityDisplay {
    final capacities = <String>[];
    if (adultsCapacity != null) capacities.add('👨 $adultsCapacity');
    if (childrenCapacity != null) capacities.add('👶 $childrenCapacity');
    return capacities.join(' • ');
  }

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        id,
        propertyId,
        unitTypeId,
        name,
        maxCapacity,
        discountPercentage,
        customFeatures,
        viewCount,
        bookingCount,
        adultsCapacity,
        childrenCapacity,
        propertyName,
        unitTypeName,
        pricingMethod,
        fieldValues,
        dynamicFields,
        distanceKm,
        images,
        allowsCancellation,
        cancellationWindowDays,
      ];
}
