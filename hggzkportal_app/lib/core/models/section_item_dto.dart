// lib/core/models/section_item_dto.dart

/// كائنات نقل بيانات تستخدمها واجهات الأقسام لإسناد العناصر وترتيبها.
/// Data transfer objects used by section endpoints to assign and reorder items.
library;

/// يجمع معرّفات العقارات والوحدات التي يجب ربطها بقسم واحد في طلب واحد حتى
/// تبقى عملية الإسناد متسقة ومختصرة.
/// Groups property and unit identifiers for a single section-assignment
/// request so the attachment step stays consistent and compact.
class AssignSectionItemsDto {
  /// معرفات العقارات المطلوب إسنادها للقسم.
  /// Property ids to attach to the section.
  final List<String> propertyIds;

  /// معرفات الوحدات المطلوب إسنادها للقسم.
  /// Unit ids to attach to the section.
  final List<String> unitIds;

  /// Creates an assignment payload for properties and units in the same section.
  const AssignSectionItemsDto({
    this.propertyIds = const [],
    this.unitIds = const [],
  });

  /// يحول الحمولة إلى JSON مع حذف المفاتيح الفارغة حتى لا نرسل حقولًا لا
  /// حاجة لها.
  /// Serializes the payload to JSON while omitting empty keys so unnecessary
  /// fields are not sent.
  Map<String, dynamic> toJson() {
    return {
      if (propertyIds.isNotEmpty) 'propertyIds': propertyIds,
      if (unitIds.isNotEmpty) 'unitIds': unitIds,
    };
  }
}

/// يمثل طلب إضافة عناصر جديدة إلى قسم موجود من دون المساس بالعناصر السابقة.
/// Represents a request that adds new items to an existing section without
/// touching what is already attached.
class AddItemsToSectionDto {
  /// معرفات العقارات المراد إضافتها.
  /// Property ids to add.
  final List<String> propertyIds;

  /// معرفات الوحدات المراد إضافتها.
  /// Unit ids to add.
  final List<String> unitIds;

  /// Creates an additive payload that preserves the existing section members.
  const AddItemsToSectionDto({
    this.propertyIds = const [],
    this.unitIds = const [],
  });

  /// يحول طلب الإضافة إلى JSON مع إبقاء الحقول غير الفارغة فقط.
  /// Serializes the add request to JSON while keeping only non-empty fields.
  Map<String, dynamic> toJson() {
    return {
      if (propertyIds.isNotEmpty) 'propertyIds': propertyIds,
      if (unitIds.isNotEmpty) 'unitIds': unitIds,
    };
  }
}

/// يمثل طلب إزالة العناصر المحددة من القسم الهدف.
/// Represents a request that removes the specified items from the target
/// section.
class RemoveItemsFromSectionDto {
  /// المعرفات المطلوب إزالتها من القسم.
  /// Item ids to remove from the section.
  final List<String> itemIds;

  /// Creates a removal payload for the given item identifiers.
  const RemoveItemsFromSectionDto({this.itemIds = const []});

  /// يصدّر معرّفات الإزالة كما هي لأن هذا الطلب يعتمد على قائمة واحدة.
  /// Serializes the removal ids as-is because the request depends on one
  /// identifier list only.
  Map<String, dynamic> toJson() {
    return {
      'itemIds': itemIds,
    };
  }
}

/// يصف ترتيب العناصر النهائي بعد إعادة الفرز حتى يمكن إرسال التسلسل الجديد
/// للخادم دفعة واحدة.
/// Describes the final item order after a reorder action so the new sequence
/// can be sent to the server in one payload.
class UpdateItemOrderDto {
  /// قائمة الأوامر التي تمثل الترتيب الجديد.
  /// Ordering instructions that represent the new sequence.
  final List<ItemOrderDto> orders;

  /// Creates a reorder payload containing the final ordered list.
  const UpdateItemOrderDto({this.orders = const []});

  /// يحول الترتيب النهائي إلى JSON مناسب لعمليات الحفظ الخلفية.
  /// Serializes the final ordering into JSON suitable for backend saves.
  Map<String, dynamic> toJson() => {
        'orders': orders.map((e) => e.toJson()).toList(),
      };
}

/// يمثل عنصرًا واحدًا مع ترتيب عرضه النهائي داخل القسم.
/// Represents a single item together with its final display order inside the
/// section.
class ItemOrderDto {
  /// المعرف الفريد للعنصر المرتب.
  /// Unique identifier of the ordered item.
  final String itemId;

  /// ترتيب العرض الجديد للعنصر.
  /// New display order for the item.
  final int sortOrder;

  /// Creates one ordered-item entry for the reorder request.
  const ItemOrderDto({required this.itemId, required this.sortOrder});

  /// يحول عنصر الترتيب إلى JSON بسيط يحمل المعرف والموضع فقط.
  /// Serializes the ordered item into a simple JSON object with id and
  /// position only.
  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'sortOrder': sortOrder,
      };
}
