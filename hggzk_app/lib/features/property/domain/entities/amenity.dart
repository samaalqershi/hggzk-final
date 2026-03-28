import 'package:equatable/equatable.dart';

/// Represents one amenity that can appear on a property or unit.
/// يمثل ميزة واحدة قد تظهر في العقار أو الوحدة.
class Amenity extends Equatable {
  /// Backend identifier of the amenity.
  /// المعرّف الخلفي للميزة.
  final String id;

  /// Display name shown to users.
  /// اسم العرض الذي يراه المستخدم.
  final String name;

  /// Short explanation of what the amenity provides.
  /// شرح قصير لما توفره الميزة.
  final String description;

  /// Image URL used by icon widgets or badges.
  /// رابط الصورة المستخدم في عناصر الأيقونات أو الشارات.
  final String iconUrl;

  /// Category used to group amenities in the UI.
  /// التصنيف المستخدم لتجميع المزايا في الواجهة.
  final String category;

  /// Icon name or glyph reference.
  /// اسم الأيقونة أو مرجعها.
  final String icon;

  /// Marks amenities that should still be shown.
  /// يحدد المزايا التي يجب أن تظل ظاهرة.
  final bool isActive;

  /// Optional surcharge associated with the amenity.
  /// تكلفة إضافية اختيارية مرتبطة بالميزة.
  final double? extraCost;

  /// Order used when the UI sorts amenity chips or cards.
  /// الترتيب المستخدم عند فرز شرائح أو بطاقات المزايا.
  final int displayOrder;

  /// Timestamp when the amenity record was created.
  /// وقت إنشاء سجل الميزة.
  final DateTime createdAt;

  /// Builds an immutable amenity definition for property screens.
  /// ينشئ تعريفًا ثابتًا للميزة تستخدمه شاشات العقار.
  const Amenity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.icon,
    required this.isActive,
    this.extraCost,
    required this.displayOrder,
    required this.createdAt,
  });

  /// Keeps equality aligned with the amenity payload.
  /// يحافظ على ثبات المقارنة مع حمولة الميزة.
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        category,
        icon,
        isActive,
        extraCost,
        displayOrder,
        createdAt,
      ];
}
