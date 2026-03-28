// lib/features/home/presentation/widgets/sections/models/section_display_item.dart

import 'package:equatable/equatable.dart';
import 'package:hggzk/features/home/data/models/section_item_models.dart';

/// يوفّر عقدًا موحدًا لبطاقات الأقسام في الصفحة الرئيسية حتى تستطيع واجهات
/// العرض التعامل مع العقارات والوحدات عبر شكل واحد بدل تشعب المنطق لكل نوع.
/// Provides a unified contract for home-section cards so the UI can render
/// properties and units through one shape instead of branching per type.
abstract class SectionDisplayItem extends Equatable {
  const SectionDisplayItem();
  String get id;
  String get name;
  String? get imageUrl;
  double get price;
  double? get discountedPrice;
  int? get discount;
  bool get isAvailable;

  /// معلومات الموقع التي تكون متاحة عادةً للعقار وقد تُمرر أحيانًا للوحدة
  /// عندما يوفّرها المصدر.
  /// Location data that is usually available for properties and may also be
  /// exposed for units when the source provides it.
  String? get location => null;
  String? get city => null;
  double? get latitude => null;
  double? get longitude => null;
  String? get category => null;

  /// تفاصيل خاصة بالعقار تساعد البطاقات الغنية على عرض التقييم والمساحة
  /// وتكوين السكن.
  /// Property-specific details used by richer cards to show ratings, size, and
  /// accommodation composition.
  int? get starRating => null;
  double? get averageRating => null;
  int? get reviewsCount => null;
  int? get bedrooms => null;
  int? get bathrooms => null;
  double? get area => null;

  /// حقول مرتبطة بالوحدة فقط مثل السعة ونوع الوحدة والعقار الأب، وتفيد
  /// الواجهات التي تربط الوحدة بسياقها الأصلي.
  /// Unit-only fields such as capacity, unit type, and parent property,
  /// helping the UI reconnect the unit with its original context.
  int? get maxCapacity => null;
  String? get unitTypeId => null;
  String? get propertyId => null;
  String? get propertyName => null;

  /// يحدد ما إذا كانت قيمة الخصم تستحق الإبراز كشارة مرئية داخل البطاقة.
  /// Tells the UI whether the discount is meaningful enough to highlight as a
  /// badge.
  bool get hasDiscount => discount != null && discount! > 0;

  /// يعيد السعر الأنسب للعرض، مع تفضيل السعر المخفض متى كان صالحًا.
  /// Returns the most appropriate display price, favoring the discounted price
  /// whenever it is valid.
  String get displayPrice => discountedPrice != null && discountedPrice! > 0
      ? discountedPrice!.toStringAsFixed(0)
      : price.toStringAsFixed(0);

  /// يبني عنصر عرض موحدًا من سجل عقار خام قادم من بيانات الأقسام.
  /// Builds a unified display item from a raw property record returned by a
  /// section payload.
  factory SectionDisplayItem.fromProperty(SectionPropertyItemModel property) {
    return PropertyDisplayItem(property);
  }

  /// يبني عنصر عرض موحدًا من سجل وحدة خام حتى تتعامل معه واجهات الأقسام عبر
  /// نفس العقد البصري المستخدم للعقارات.
  /// Builds a unified display item from a raw unit record so section widgets
  /// can render it through the same visual contract used for properties.
  factory SectionDisplayItem.fromUnit(SectionUnitItemModel unit) {
    return UnitDisplayItem(unit);
  }
}

/// يغلّف بيانات العقار داخل تنفيذ يطابق `SectionDisplayItem` من دون نسخ
/// الحقول، ليبقى الربط بين الواجهة وبيانات المصدر مباشرًا.
/// Wraps a property record in a `SectionDisplayItem` implementation without
/// duplicating fields, keeping the UI mapped directly to source data.
class PropertyDisplayItem extends SectionDisplayItem {
  /// السجل الخام للعقار كما وصل من قسم الصفحة الرئيسية.
  /// Raw property record as returned by the home section payload.
  final SectionPropertyItemModel property;
  const PropertyDisplayItem(this.property) : super();
  @override
  String get id => property.id;
  @override
  String get name => property.name;
  @override
  String? get imageUrl => property.imageUrl;
  @override
  double get price => property.price ?? property.minPrice;
  @override
  double? get discountedPrice =>
      property.discountedPrice > 0 ? property.discountedPrice : null;
  @override
  int? get discount => property.discount;
  @override
  bool get isAvailable => property.isAvailable;
  @override
  String? get location => property.location;
  @override
  String? get city => property.city;
  @override
  double? get latitude => property.latitude;
  @override
  double? get longitude => property.longitude;
  @override
  String? get category =>
      property.propertyType.isNotEmpty ? property.propertyType : null;
  @override
  int? get starRating => property.starRating;
  @override
  double? get averageRating => property.averageRating;
  @override
  int? get reviewsCount => property.reviewsCount;
  @override
  int? get bedrooms => property.bedrooms;
  @override
  int? get bathrooms => property.bathrooms;
  @override
  double? get area => property.area;
  @override
  List<Object?> get props => [property];
}

/// يقدّم بيانات الوحدة من خلال الواجهة الموحدة نفسها المستخدمة للعقارات،
/// مع الاحتفاظ بالخصائص المتخصصة التي تحتاجها بعض البطاقات.
/// Exposes unit data through the same unified interface used for properties
/// while preserving the specialized attributes some cards still need.
class UnitDisplayItem extends SectionDisplayItem {
  /// السجل الخام للوحدة كما وصل من قسم الصفحة الرئيسية.
  /// Raw unit record as returned by the home section payload.
  final SectionUnitItemModel unit;
  const UnitDisplayItem(this.unit) : super();
  @override
  String get id => unit.id;
  @override
  String get name => unit.name;
  @override
  String? get imageUrl => unit.imageUrl;
  @override
  double get price => unit.price ?? unit.minPrice;
  @override
  double? get discountedPrice =>
      unit.discountedPrice > 0 ? unit.discountedPrice : null;
  @override
  int? get discount => unit.discount;
  @override
  bool get isAvailable => unit.isAvailable;
  @override
  int? get maxCapacity => unit.maxCapacity;
  @override
  String? get unitTypeId => unit.unitTypeId;
  @override
  String? get propertyId => unit.propertyId;
  @override
  String? get location => unit.location;
  @override
  double? get averageRating => unit.rating;
  @override
  String? get category =>
      unit.unitTypeName?.isNotEmpty == true ? unit.unitTypeName : null;
  @override
  List<Object?> get props => [unit];
}

/// يضيف أداة تحويل للقوائم المختلطة حتى يمكن تمرير أي مزيج من العقارات
/// والوحدات إلى واجهات الأقسام بصيغة موحدة قابلة للعرض.
/// Adds a conversion helper for mixed lists so any blend of properties and
/// units can be handed to section widgets in one renderable format.
extension SectionDisplayItemListExt on List<dynamic> {
  /// يحول العناصر الديناميكية القادمة من مصادر الأقسام إلى عناصر عرض موحدة،
  /// ويرفض الأشكال غير المعروفة مبكرًا قبل وصولها إلى طبقة الواجهة.
  /// Converts dynamic section payload items into unified display items and
  /// rejects unknown shapes early before they leak into the UI layer.
  List<SectionDisplayItem> toDisplayItems() {
    return map((item) {
      if (item is SectionPropertyItemModel) {
        return SectionDisplayItem.fromProperty(item);
      } else if (item is SectionUnitItemModel) {
        return SectionDisplayItem.fromUnit(item);
      }
      throw ArgumentError('Unknown item type: ${item.runtimeType}');
    }).toList();
  }
}
