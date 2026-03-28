import 'package:equatable/equatable.dart';

/// يصف نوع عقار يمكن أن يبدأ منه المستخدم رحلة التصفح أو التصفية من الصفحة
/// الرئيسية.
/// Describes a property type that can serve as the user's starting point for
/// browsing or filtering from the home screen.
class PropertyType extends Equatable {
  /// المعرّف الثابت الذي يربط النوع ببيانات الخادم والاختيارات المحفوظة.
  /// Stable identifier that links the type to backend data and persisted
  /// selections.
  final String id;

  /// الاسم الظاهر للمستخدم عند عرض هذا النوع في الواجهة.
  /// User-facing label shown for this type in the interface.
  final String name;

  /// وصف مختصر يساعد المستخدم على فهم ما يمثله هذا النوع.
  /// Supporting description that helps the user understand what this type
  /// represents.
  final String description;

  /// العدد الإجمالي للعقارات المصنفة حاليًا تحت هذا النوع.
  /// Total number of properties currently grouped under this type.
  final int propertiesCount;

  /// اسم الأيقونة التي تستخدمها الواجهة لتمثيل النوع بصريًا.
  /// Icon name used by the UI to represent the type visually.
  final String icon;

  /// قيمة عددية إضافية قد تستخدمها الواجهة كشارة مختصرة أو كمؤشر سريع.
  /// Additional numeric value that the UI may use as a compact badge or quick
  /// indicator.
  final int count;

  /// المرافق الافتراضية التي ترتبط بهذا النوع عند بدء الرحلة به.
  /// Default amenities associated with this type at the start of the flow.
  final List<String> defaultAmenities;

  /// معرّفات أنواع الوحدات التي يمكن أن تنتمي إلى هذا النوع من العقارات.
  /// Identifiers of the unit types that can belong to this property type.
  final List<String> unitTypeIds;

  /// ينشئ كيان نوع العقار الذي تعتمد عليه الصفحة الرئيسية والفلاتر المرتبطة
  /// بها.
  /// Creates the property-type entity consumed by the home screen and its
  /// related filters.
  const PropertyType({
    required this.id,
    required this.name,
    required this.description,
    required this.propertiesCount,
    required this.icon,
    this.count = 0,
    this.defaultAmenities = const [],
    this.unitTypeIds = const [],
  });
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        propertiesCount,
        defaultAmenities,
        icon,
        count,
        unitTypeIds,
      ];
}
