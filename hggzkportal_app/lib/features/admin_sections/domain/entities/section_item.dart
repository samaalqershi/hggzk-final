import 'package:equatable/equatable.dart';

/// Represents one item placed inside a section and ordered relative to its
/// peers.
///
/// يمثل عنصرًا واحدًا داخل القسم مع ترتيبه مقارنةً ببقية العناصر.
class SectionItem extends Equatable {
  /// Stable identifier of the section item.
  ///
  /// المعرّف الثابت لعنصر القسم.
  final String id;

  /// Parent section that owns this item.
  ///
  /// القسم الأب الذي يملك هذا العنصر.
  final String sectionId;

  /// Optional property linked to the item.
  ///
  /// العقار المرتبط بالعنصر إن وُجد.
  final String? propertyId;

  /// Optional unit linked to the item.
  ///
  /// الوحدة المرتبطة بالعنصر إن وُجدت.
  final String? unitId;

  /// Position of the item inside the section.
  ///
  /// موضع العنصر داخل القسم.
  final int sortOrder;

  /// Creates the ordered section item snapshot.
  ///
  /// ينشئ لقطة العنصر المرتب داخل القسم.
  const SectionItem({
    required this.id,
    required this.sectionId,
    this.propertyId,
    this.unitId,
    required this.sortOrder,
  });

  /// Keeps equality aligned with the placement record.
  ///
  /// يربط المقارنة بسجل الترتيب.
  @override
  List<Object?> get props => [id, sectionId, propertyId, unitId, sortOrder];
}
