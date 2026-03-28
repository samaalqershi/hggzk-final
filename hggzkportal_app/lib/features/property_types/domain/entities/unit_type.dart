import 'package:equatable/equatable.dart';
import 'unit_type_field.dart';

/// العربية: يمثل نوع الوحدة الذي يحكم السعة والحقول والقيود التشغيلية في
/// بوابة الإدارة.
/// operational rules in the admin portal.
class UnitType extends Equatable {
  /// العربية: المعرّف الثابت لنوع الوحدة.
  final String id;

  /// العربية: يربط نوع الوحدة بنوع العقار الأعلى منه.
  final String propertyTypeId;

  /// العربية: الاسم المعروض في واجهات الإدارة والاختيار.
  final String name;

  /// العربية: وصف يوضح طبيعة النوع وما يميزه.
  final String description;

  /// العربية: الرمز المستخدم لتمييز النوع بصريًا.
  final String icon;

  /// العربية: الحد الأقصى للضيوف المسموح به.
  final int maxCapacity;

  /// العربية: نسبة العمولة النظامية إن كانت معرفة لهذا النوع.
  final double? systemCommissionRate;

  /// العربية: يحدد ما إذا كان النموذج يتعامل مع البالغين.
  final bool isHasAdults;

  /// العربية: يحدد ما إذا كان النموذج يتعامل مع الأطفال.
  final bool isHasChildren;

  /// العربية: يوضح إن كان الحجز لهذا النوع يمتد عبر عدة أيام.
  final bool isMultiDays;

  /// العربية: يحدد ما إذا كان اختيار الساعة إلزاميًا قبل الإكمال.
  /// completion.
  final bool isRequiredToDetermineTheHour;

  /// العربية: الحقول المرتبطة بالنوع لتخصيص النموذج الناتج.
  final List<UnitTypeField> fields;

  /// العربية: وقت إنشاء السجل.
  final DateTime? createdAt;

  /// العربية: آخر تحديث للسجل.
  final DateTime? updatedAt;

  /// العربية: يبني نوع الوحدة مع قواعده وحقوله الإضافية.
  const UnitType({
    required this.id,
    required this.propertyTypeId,
    required this.name,
    required this.description,
    required this.icon,
    this.systemCommissionRate,
    required this.maxCapacity,
    required this.isHasAdults,
    required this.isHasChildren,
    required this.isMultiDays,
    required this.isRequiredToDetermineTheHour,
    this.fields = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// العربية: يسمح بتعديل خصائص محددة مع الحفاظ على بقية البيانات كما هي.
  UnitType copyWith({
    String? id,
    String? propertyTypeId,
    String? name,
    String? description,
    String? icon,
    double? systemCommissionRate,
    int? maxCapacity,
    bool? isHasAdults,
    bool? isHasChildren,
    bool? isMultiDays,
    bool? isRequiredToDetermineTheHour,
    List<UnitTypeField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitType(
      id: id ?? this.id,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      systemCommissionRate: systemCommissionRate ?? this.systemCommissionRate,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      isHasAdults: isHasAdults ?? this.isHasAdults,
      isHasChildren: isHasChildren ?? this.isHasChildren,
      isMultiDays: isMultiDays ?? this.isMultiDays,
      isRequiredToDetermineTheHour:
          isRequiredToDetermineTheHour ?? this.isRequiredToDetermineTheHour,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// العربية: يحدد المساواة على أساس المحتوى الفعلي للكيان.
  @override
  List<Object?> get props => [
        id,
        propertyTypeId,
        name,
        description,
        icon,
        systemCommissionRate,
        maxCapacity,
        isHasAdults,
        isHasChildren,
        isMultiDays,
        isRequiredToDetermineTheHour,
        fields,
        createdAt,
        updatedAt,
      ];
}
