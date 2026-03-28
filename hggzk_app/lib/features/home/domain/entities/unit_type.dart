import 'package:equatable/equatable.dart';
import '../../../search/domain/entities/search_filter.dart' show UnitTypeField;

/// يصف نوع وحدة تابعًا لنوع عقار محدد، مع الخصائص التي تؤثر في تجربة البحث
/// والحجز وبناء الحقول الديناميكية.
/// Describes a unit type that belongs to a specific property type, including
/// the rules that affect search, booking, and dynamic-field generation.
class UnitType extends Equatable {
  /// المعرّف الثابت لنوع الوحدة داخل النظام.
  /// Stable identifier for the unit type inside the system.
  final String id;

  /// المعرّف الذي يربط هذا النوع بنوع العقار الأب.
  /// Identifier that links this unit type to its parent property type.
  final String propertyTypeId;

  /// الاسم الظاهر للمستخدم عند اختيار هذا النوع.
  /// User-facing label shown when this type is presented for selection.
  final String name;

  /// وصف يوضح متى يناسب هذا النوع من الوحدات وما الذي يميزه.
  /// Description that explains when this unit type applies and what makes it
  /// distinct.
  final String description;

  /// اسم الأيقونة المستخدمة لتمثيله بصريًا في الواجهة.
  /// Icon name used to represent the type visually in the UI.
  final String icon;

  /// الحد الأقصى النظري للسعة أو عدد الضيوف لهذا النوع.
  /// Maximum theoretical capacity or guest count supported by this type.
  final int maxCapacity;

  /// يحدد ما إذا كان هذا النوع يعتمد صراحة على عدد البالغين.
  /// Indicates whether this type explicitly depends on an adult count.
  final bool isHasAdults;

  /// يحدد ما إذا كان هذا النوع يعتمد صراحة على عدد الأطفال.
  /// Indicates whether this type explicitly depends on a child count.
  final bool isHasChildren;

  /// يحدد ما إذا كانت حجوزات هذا النوع يمكن أن تمتد عبر عدة أيام.
  /// Indicates whether bookings for this type can span multiple days.
  final bool isMultiDays;

  /// يحدد ما إذا كان اختيار الوقت شرطًا قبل متابعة الحجز أو البحث.
  /// Indicates whether choosing a time is required before the user can
  /// continue.
  final bool isRequiredToDetermineTheHour;

  /// الحقول الديناميكية التي تبنيها طبقة البحث انطلاقًا من خصائص هذا النوع.
  /// Dynamic fields that the search layer builds from this type's rules.
  final List<UnitTypeField> fields;

  /// ينشئ كيان نوع الوحدة الذي تتعامل معه طبقات البحث والحجز والعرض.
  /// Creates the unit-type entity consumed by search, booking, and
  /// presentation layers.
  const UnitType({
    required this.id,
    required this.propertyTypeId,
    required this.name,
    required this.description,
    required this.icon,
    required this.maxCapacity,
    required this.isHasAdults,
    required this.isHasChildren,
    required this.isMultiDays,
    required this.isRequiredToDetermineTheHour,
    this.fields = const [],
  });
  @override
  List<Object?> get props => [
        id,
        propertyTypeId,
        name,
        description,
        maxCapacity,
        icon,
        isHasAdults,
        isHasChildren,
        isMultiDays,
        isRequiredToDetermineTheHour,
        fields,
      ];
}
