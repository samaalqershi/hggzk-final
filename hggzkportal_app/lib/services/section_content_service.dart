import 'package:hggzkportal/core/enums/section_target.dart';
import 'package:hggzkportal/core/models/paginated_result.dart' as core;
import 'package:hggzkportal/core/models/section_item_dto.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/section_items/add_items_to_section_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/section_items/get_section_items_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/section_items/remove_items_from_section_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/section_items/update_item_order_usecase.dart';

/// Bridges section-item use cases into a simpler service API for the admin
/// screens that manage section contents.
/// يربط use cases الخاصة بعناصر الأقسام بواجهة خدمة أبسط لشاشات الإدارة
/// التي تدير محتوى الأقسام.
class SectionContentService {
  /// Use case that fetches section items.
  /// use case يجلب عناصر القسم.
  final GetSectionItemsUseCase getItems;

  /// Use case that adds items to a section.
  /// use case يضيف عناصر إلى القسم.
  final AddItemsToSectionUseCase addItems;

  /// Use case that removes items from a section.
  /// use case يزيل عناصر من القسم.
  final RemoveItemsFromSectionUseCase removeItems;

  /// Use case that updates section item ordering.
  /// use case يحدّث ترتيب عناصر القسم.
  final UpdateItemOrderUseCase reorderItems;

  /// Wires the section content use cases together for the admin layer.
  /// يربط use cases الخاصة بالمحتوى من أجل طبقة الإدارة.
  const SectionContentService({
    required this.getItems,
    required this.addItems,
    required this.removeItems,
    required this.reorderItems,
  });

  Future<core.PaginatedResult<dynamic>> fetchItems({
    required String sectionId,
    required SectionTarget target,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final result = await getItems(GetSectionItemsParams(
      sectionId: sectionId,
      target: target,
      pageNumber: pageNumber,
      pageSize: pageSize,
    ));
    return result.fold(
        (l) => core.PaginatedResult.empty(
            pageNumber: pageNumber, pageSize: pageSize),
        (r) => r);
  }

  /// Adds property or unit items to a section using the domain use case.
  /// يضيف عناصر عقارات أو وحدات إلى قسم عبر use case المجال.
  Future<bool> add(
      {required String sectionId,
      List<String> propertyIds = const [],
      List<String> unitIds = const []}) async {
    final payload =
        AddItemsToSectionDto(propertyIds: propertyIds, unitIds: unitIds);
    final result = await addItems(
        AddItemsToSectionParams(sectionId: sectionId, payload: payload));
    return result.fold((l) => false, (r) => true);
  }

  /// Removes one or more items from a section.
  /// يزيل عنصرًا أو أكثر من القسم.
  Future<bool> remove(
      {required String sectionId, required List<String> itemIds}) async {
    final payload = RemoveItemsFromSectionDto(itemIds: itemIds);
    final result = await removeItems(
        RemoveItemsFromSectionParams(sectionId: sectionId, payload: payload));
    return result.fold((l) => false, (r) => true);
  }

  /// Persists the new display order for section items.
  /// يحفظ ترتيب العرض الجديد لعناصر القسم.
  Future<bool> reorder(
      {required String sectionId, required List<ItemOrderDto> orders}) async {
    final payload = UpdateItemOrderDto(orders: orders);
    final result = await reorderItems(
        UpdateItemOrderParams(sectionId: sectionId, payload: payload));
    return result.fold((l) => false, (r) => true);
  }
}
