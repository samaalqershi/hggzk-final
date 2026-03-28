import '../../domain/entities/property_type.dart' as domain;

/// يمثل نوع العقار كما يصل من الشبكة قبل تحويله إلى كيان المجال الذي تعمل به
/// طبقات التطبيق.
/// Represents a property type exactly as it arrives from the network before it
/// is converted into the domain entity used by the application layers.
class PropertyTypeModel {
  /// المعرّف الخام القادم من الخادم لهذا النوع.
  /// Raw backend identifier for this property type.
  final String id;

  /// الاسم الذي سيعرض للمستخدم في الواجهة.
  /// Name that will be shown to the user in the interface.
  final String name;

  /// الوصف النصي المرافق لنوع العقار.
  /// Textual description associated with this property type.
  final String description;

  /// عدد العقارات التي يربطها الخادم بهذا النوع.
  /// Number of properties that the backend associates with this type.
  final int propertiesCount;

  /// اسم الأيقونة المقترحة لتمثيل هذا النوع بصريًا.
  /// Suggested icon name used to represent this type visually.
  final String icon;

  /// قيمة عددية إضافية قد تستخدمها الواجهة كشارة أو مؤشر مختصر.
  /// Additional numeric value the UI may use as a badge or compact indicator.
  final int count;

  /// المرافق الافتراضية التي قد تقترن بهذا النوع عند بدء التصفح.
  /// Default amenities that may be associated with this type at discovery time.
  final List<String> defaultAmenities;

  /// معرّفات أنواع الوحدات التابعة التي يمكن أن تندرج تحت هذا النوع.
  /// Identifiers of dependent unit types that can belong to this property
  /// type.
  final List<String> unitTypeIds;

  /// ينشئ النموذج الخام الذي يمثل استجابة الشبكة لنوع العقار.
  /// Creates the raw model that mirrors the network payload for a property
  /// type.
  const PropertyTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.propertiesCount,
    required this.icon,
    required this.count,
    this.defaultAmenities = const [],
    this.unitTypeIds = const [],
  });

  /// يبني النموذج من JSON ويطبّع القيم إلى الأنواع التي تتوقعها طبقات
  /// التطبيق.
  /// Builds the model from JSON and normalizes values into the types expected
  /// by the application layers.
  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      propertiesCount: json['propertiesCount'] ?? 0,
      icon: json['icon'] ?? '',
      count: json['count'] ?? json['propertiesCount'] ?? 0,
      defaultAmenities: (json['defaultAmenities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      unitTypeIds:
          (json['unitTypeIds'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
    );
  }

  /// يحول النموذج إلى JSON صالح للتخزين أو لإعادة الإرسال عند الحاجة.
  /// Converts the model into JSON suitable for storage or retransmission.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'propertiesCount': propertiesCount,
      'icon': icon,
      'count': count,
      'defaultAmenities': defaultAmenities,
      'unitTypeIds': unitTypeIds,
    };
  }

  /// يحول النموذج الشبكي إلى كيان المجال الذي تعتمد عليه طبقات الأعمال
  /// والعرض.
  /// Converts the network model into the domain entity consumed by business and
  /// presentation layers.
  domain.PropertyType toEntity() => domain.PropertyType(
        id: id,
        name: name,
        description: description,
        propertiesCount: propertiesCount,
        defaultAmenities: defaultAmenities,
        icon: icon,
        count: count,
        unitTypeIds: unitTypeIds,
      );
}
