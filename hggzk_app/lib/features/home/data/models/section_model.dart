// lib/features/home/data/models/section_model.dart

import '../../domain/entities/section.dart' as domain;
import '../../../../core/enums/section_type_enum.dart';
import '../../../../core/enums/section_target_enum.dart';
import 'dart:convert';

/// يمثل القسم كما يصل من الخادم قبل أن يُحوَّل إلى كيان مجال مناسب
/// للاستخدام داخل الـ bloc والواجهة.
/// Represents a section exactly as it arrives from the backend before being
/// converted into the domain entity used by blocs and the UI.
class SectionModel {
  final String id;

  /// النوع الأصلي القادم من الخادم والذي نحتفظ به قبل إسقاطه على نوع العرض.
  /// Original backend type retained before mapping it into a UI-facing type.
  final SectionType type;
  final int displayOrder;
  final SectionTarget target;
  final bool isActive;

  /// القيمة النصية الخام القادمة من الخادم قبل تطبيق أي تحويلات.
  /// Raw textual type received from the backend before applying presentation
  /// mapping.
  final String backendType;

  /// فئة المحتوى التي يقدمها القسم مثل العقارات أو الوحدات.
  /// Content family hosted by the section, such as properties or units.
  final String? contentType;

  /// أسلوب العرض المقترح لهذا القسم مثل الشبكة أو القائمة.
  /// Suggested rendering style for the section, such as grid or list.
  final String? displayStyle;
  final String? name;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? shortDescription;
  final int? columnsCount;
  final int? itemsToShow;
  final int? homeItemsCount;

  /// تصنيف داخلي يستخدم لتجميع الأقسام المتشابهة ومعالجتها كفئة واحدة.
  /// Internal grouping label used to cluster similar sections into one family.
  final String? categoryClass;
  final String? icon;
  final String? colorTheme;
  final String? backgroundImage;
  final String? filterCriteria;
  final String? sortCriteria;
  final String? cityName;
  final String? propertyTypeId;
  final String? unitTypeId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? isVisibleToGuests;
  final bool? isVisibleToRegistered;
  final String? requiresPermission;
  final DateTime? startDate;
  final DateTime? endDate;

  /// بيانات JSON إضافية قد تحمل إعدادات عرض أو قواعد خاصة بالقسم.
  /// Extra JSON metadata that may carry presentation settings or special rules
  /// for the section.
  final String? metadata;
  const SectionModel({
    required this.id,
    required this.type,
    required this.displayOrder,
    required this.target,
    required this.isActive,
    required this.backendType,
    this.contentType,
    this.displayStyle,
    this.name,
    this.title,
    this.subtitle,
    this.description,
    this.shortDescription,
    this.columnsCount,
    this.itemsToShow,
    this.homeItemsCount,
    this.categoryClass,
    this.icon,
    this.colorTheme,
    this.backgroundImage,
    this.filterCriteria,
    this.sortCriteria,
    this.cityName,
    this.propertyTypeId,
    this.unitTypeId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.isVisibleToGuests,
    this.isVisibleToRegistered,
    this.requiresPermission,
    this.startDate,
    this.endDate,
    this.metadata,
  });

  /// يبني النموذج من JSON مع التسامح مع اختلافات الخادم في أسماء الحقول
  /// وأنواع القيم.
  /// Builds the model from JSON while tolerating backend variations in field
  /// names and value types.
  factory SectionModel.fromJson(Map<String, dynamic> json) {
    String asString(dynamic v) => v?.toString() ?? '';
    int parseInt(dynamic v, int def) =>
        v is int ? v : int.tryParse(asString(v)) ?? def;
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(asString(v));
    }

    DateTime? parseDate(dynamic v) {
      if (v == null || asString(v).isEmpty) return null;
      return DateTime.tryParse(asString(v));
    }

    final rawType = asString(json['type'] ?? json['sectionType']);
    final targetStr = asString(json['target']);
    final dynamic rawIsActive = json['isActive'];
    final bool parsedIsActive = () {
      if (rawIsActive == null) return true;
      if (rawIsActive is bool) return rawIsActive;
      if (rawIsActive is num) return rawIsActive != 0;
      final String s = rawIsActive.toString().trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'y' || s == 'on';
    }();

    return SectionModel(
      id: asString(json['id']),
      type: SectionTypeExtension.tryFromString(rawType) ?? SectionType.grid,
      displayOrder: parseInt(json['displayOrder'] ?? json['order'], 0),
      target:
          SectionTargetBackend.tryParse(targetStr) ?? SectionTarget.properties,
      isActive: parsedIsActive,
      backendType: rawType,
      contentType: asString(json['contentType']).isEmpty
          ? null
          : asString(json['contentType']),
      displayStyle: asString(json['displayStyle']).isEmpty
          ? null
          : asString(json['displayStyle']),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      shortDescription: json['shortDescription']?.toString(),
      columnsCount: json['columnsCount'] == null
          ? null
          : parseInt(json['columnsCount'], 2),
      itemsToShow: json['itemsToShow'] == null
          ? null
          : parseInt(json['itemsToShow'], 10),
      homeItemsCount: json['homeItemsCount'] == null
          ? null
          : parseInt(json['homeItemsCount'], 0),
      categoryClass: asString(json['categoryClass']).isEmpty
          ? null
          : asString(json['categoryClass']),
      icon: json['icon']?.toString(),
      colorTheme: json['colorTheme']?.toString(),
      backgroundImage: json['backgroundImage']?.toString(),
      filterCriteria: json['filterCriteria']?.toString(),
      sortCriteria: json['sortCriteria']?.toString(),
      cityName: json['cityName']?.toString(),
      propertyTypeId: json['propertyTypeId']?.toString(),
      unitTypeId: json['unitTypeId']?.toString(),
      minPrice: parseDouble(json['minPrice']),
      maxPrice: parseDouble(json['maxPrice']),
      minRating: parseDouble(json['minRating']),
      isVisibleToGuests: json['isVisibleToGuests'] is bool
          ? json['isVisibleToGuests'] as bool
          : null,
      isVisibleToRegistered: json['isVisibleToRegistered'] is bool
          ? json['isVisibleToRegistered'] as bool
          : null,
      requiresPermission: json['requiresPermission']?.toString(),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      metadata: json['metadata']?.toString(),
    );
  }

  /// يحول النموذج إلى JSON مختصر يحتوي الحقول الأساسية اللازمة لإعادة الإرسال
  /// أو التخزين.
  /// Converts the model into a compact JSON payload that keeps the essential
  /// fields needed for storage or retransmission.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'displayOrder': displayOrder,
      'target': target.backendName,
      'isActive': isActive,
      'contentType': contentType,
      'displayStyle': displayStyle,
      'name': name,
      'title': title,
      'subtitle': subtitle,
      'columnsCount': columnsCount,
      'itemsToShow': itemsToShow,
      'homeItemsCount': homeItemsCount,
      'categoryClass': categoryClass,
      'metadata': metadata,
    };
  }

  /// يفك `metadata` إلى خريطة قابلة للاستخدام عندما تكون السلسلة JSON صحيحة.
  /// Decodes `metadata` into a usable map when the stored string contains
  /// valid JSON.
  Map<String, dynamic>? get metadataJson {
    if (metadata == null || metadata!.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(metadata!);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// يشتق نوع العرض النهائي الذي يجب أن تعتمد عليه طبقة العرض بعد الجمع بين
  /// بيانات الـ metadata والقواعد الافتراضية.
  /// Derives the final UI type the presentation layer should use after
  /// combining metadata hints with fallback rules.
  SectionType _computeUiType() {
    // 1) Explicit UI type in metadata (grid / bigCards / list)
    final uiTypeStr = metadataJson?['uiType']?.toString();
    final byMeta = uiTypeStr == null
        ? null
        : SectionTypeExtension.tryFromString(uiTypeStr);
    if (byMeta != null) return byMeta;

    // 2) Simple heuristics based on displayStyle.
    final ds = (displayStyle ?? '').toLowerCase();

    if (ds == 'grid') {
      return SectionType.grid;
    }

    if (ds == 'carousel') {
      // Circular carousels are usually rendered as big cards.
      return SectionType.bigCards;
    }

    if (ds == 'list') {
      return SectionType.list;
    }

    // 3) Safe fallback.
    return SectionType.grid;
  }

  /// يحول النموذج الخام إلى كيان المجال الذي تتعامل معه طبقات الأعمال والعرض.
  /// Converts the raw model into the domain entity consumed by business and
  /// presentation layers.
  domain.Section toEntity() => domain.Section(
        id: id,
        type: type,
        uiType: _computeUiType(),
        displayOrder: displayOrder,
        target: target,
        isActive: isActive,
        // Optional rich fields.
        name: name,
        title: title,
        subtitle: subtitle,
        contentType: contentType,
        displayStyle: displayStyle,
        columnsCount: columnsCount ?? 2,
        itemsToShow: itemsToShow ?? 10,
        homeItemsCount: homeItemsCount,
        categoryClass: categoryClass,
        metadata: metadata,
      );
}

/// يمثل عنصر الربط بين القسم ومحتواه الفعلي حتى نعرف أي عقار أو وحدة يجب
/// عرضه وبأي ترتيب داخل القسم.
/// Represents the linkage between a section and its actual content so we know
/// which property or unit should be shown and in what order.
class SectionItemModel {
  /// المعرّف الثابت لعنصر القسم.
  /// Stable identifier for the section item.
  final String id;

  /// معرّف القسم الأب الذي ينتمي إليه هذا العنصر.
  /// Identifier of the parent section this item belongs to.
  final String sectionId;

  /// معرّف العقار عندما يشير هذا العنصر إلى عقار.
  /// Property identifier when this item points to a property.
  final String? propertyId;

  /// معرّف الوحدة عندما يشير هذا العنصر إلى وحدة.
  /// Unit identifier when this item points to a unit.
  final String? unitId;

  /// ترتيب العرض داخل القسم نفسه.
  /// Display order within the section.
  final int sortOrder;
  const SectionItemModel({
    required this.id,
    required this.sectionId,
    this.propertyId,
    this.unitId,
    required this.sortOrder,
  });

  /// ينشئ العنصر من JSON ويطبّع القيم إلى الشكل الذي تتوقعه طبقة المجال.
  /// Builds the item from JSON and normalizes values into the shape expected
  /// by the domain layer.
  factory SectionItemModel.fromJson(Map<String, dynamic> json) {
    return SectionItemModel(
      id: json['id']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
      propertyId: json['propertyId']?.toString(),
      unitId: json['unitId']?.toString(),
      sortOrder: json['sortOrder'] is int
          ? (json['sortOrder'] as int)
          : int.tryParse((json['sortOrder'] ?? '0').toString()) ?? 0,
    );
  }

  /// يحول العنصر إلى JSON جاهز للنقل أو التخزين.
  /// Converts the item into JSON ready for transport or storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionId': sectionId,
      'propertyId': propertyId,
      'unitId': unitId,
      'sortOrder': sortOrder,
    };
  }

  /// يحول العنصر إلى كيان المجال الذي تتعامل معه الطبقات العليا.
  /// Converts the item into the domain entity used by upper layers.
  domain.SectionItem toEntity() => domain.SectionItem(
        id: id,
        sectionId: sectionId,
        propertyId: propertyId,
        unitId: unitId,
        sortOrder: sortOrder,
      );
}
