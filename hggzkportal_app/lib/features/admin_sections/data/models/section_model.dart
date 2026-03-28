import '../../domain/entities/section.dart' as domain;
import '../../../../core/enums/section_type.dart';
import '../../../../core/enums/section_target.dart';
import '../../../../core/enums/section_content_type.dart';
import '../../../../core/enums/section_display_style.dart';
import '../../../../core/enums/section_class.dart';

/// Translates section payloads from the backend into the editable section
/// entity used by the portal.
///
/// يحول حمولة القسم القادمة من الخادم إلى كيان قابل للتحرير داخل البوابة.
class SectionModel {
  /// Temporary draft key used before the section is permanently created.
  ///
  /// مفتاح مسودة مؤقت قبل إنشاء القسم نهائيًا.
  final String? tempKey;

  /// Stable section identifier.
  ///
  /// معرّف القسم الثابت.
  final String id;

  /// High-level section type.
  ///
  /// نوع القسم العام.
  final SectionTypeEnum type;

  /// Content family shown inside the section.
  ///
  /// فئة المحتوى المعروضة داخل القسم.
  final SectionContentType contentType;

  /// Visual layout applied to the section.
  ///
  /// التخطيط المرئي المطبق على القسم.
  final SectionDisplayStyle displayStyle;

  /// Internal label used by editors and operators.
  ///
  /// اسم داخلي يستخدمه المحررون والمشغلون.
  final String? name;

  /// Public title displayed to visitors.
  ///
  /// العنوان العام الظاهر للزوار.
  final String? title;

  /// Optional supporting subtitle.
  ///
  /// عنوان فرعي داعم اختياري.
  final String? subtitle;

  /// Longer editorial description.
  ///
  /// وصف تحريري أطول.
  final String? description;

  /// Short summary used in compact cards.
  ///
  /// ملخص قصير يستخدم في البطاقات المختصرة.
  final String? shortDescription;

  /// Sort order in the section list.
  ///
  /// ترتيب الظهور في قائمة الأقسام.
  final int displayOrder;

  /// Target audience or placement.
  ///
  /// الجمهور أو موضع العرض المستهدف.
  final SectionTarget target;

  /// Whether the section is currently published.
  ///
  /// ما إذا كان القسم منشورًا حاليًا.
  final bool isActive;

  /// Number of columns used by grid layouts.
  ///
  /// عدد الأعمدة المستخدمة في التخطيطات الشبكية.
  final int columnsCount;

  /// Maximum number of items to render.
  ///
  /// الحد الأقصى للعناصر التي يجب عرضها.
  final int itemsToShow;

  /// Optional icon or asset reference.
  ///
  /// أيقونة أو مرجع أصل اختياري.
  final String? icon;

  /// Accent color token for the section.
  ///
  /// رمز لون التمييز للقسم.
  final String? colorTheme;

  /// Optional background artwork.
  ///
  /// صورة خلفية اختيارية.
  final String? backgroundImage;

  /// Serialized filters that shape the section contents.
  ///
  /// فلاتر مرمزة تحدد محتوى القسم.
  final String? filterCriteria;

  /// Serialized sort rules for items within the section.
  ///
  /// قواعد فرز مرمزة لعناصر القسم.
  final String? sortCriteria;

  /// Optional city filter.
  ///
  /// فلتر مدينة اختياري.
  final String? cityName;

  /// Optional property type filter.
  ///
  /// فلتر نوع عقار اختياري.
  final String? propertyTypeId;

  /// Optional unit type filter.
  ///
  /// فلتر نوع وحدة اختياري.
  final String? unitTypeId;

  /// Minimum price boundary for curated content.
  ///
  /// الحد الأدنى للسعر للمحتوى المنسق.
  final double? minPrice;

  /// Maximum price boundary for curated content.
  ///
  /// الحد الأعلى للسعر للمحتوى المنسق.
  final double? maxPrice;

  /// Minimum rating boundary for curated content.
  ///
  /// الحد الأدنى للتقييم للمحتوى المنسق.
  final double? minRating;

  /// Whether guests can see the section.
  ///
  /// ما إذا كان الضيوف يمكنهم رؤية القسم.
  final bool isVisibleToGuests;

  /// Whether signed-in users can see the section.
  ///
  /// ما إذا كان المستخدمون المسجلون يمكنهم رؤية القسم.
  final bool isVisibleToRegistered;

  /// Optional permission key required to show the section.
  ///
  /// مفتاح صلاحية اختياري مطلوب لإظهار القسم.
  final String? requiresPermission;

  /// Optional activation start date.
  ///
  /// تاريخ بدء التفعيل الاختياري.
  final DateTime? startDate;

  /// Optional activation end date.
  ///
  /// تاريخ انتهاء التفعيل الاختياري.
  final DateTime? endDate;

  /// Free-form serialized metadata that does not belong in typed fields.
  ///
  /// بيانات وصفية مرمزة لا تناسب الحقول المهيكلة.
  final String? metadata;

  /// Optional higher-level section classification.
  ///
  /// تصنيف أعلى اختياري للقسم.
  final SectionClass? categoryClass;

  /// Cached count of items rendered on the home page.
  ///
  /// العدد المخزن للعناصر المعروضة في الصفحة الرئيسية.
  final int? homeItemsCount;

  /// Creates the editable section snapshot used by the admin portal.
  ///
  /// ينشئ لقطة القسم القابلة للتحرير المستخدمة في بوابة الإدارة.
  const SectionModel({
    this.tempKey,
    required this.id,
    required this.type,
    required this.contentType,
    required this.displayStyle,
    this.name,
    this.title,
    this.subtitle,
    this.description,
    this.shortDescription,
    required this.displayOrder,
    required this.target,
    required this.isActive,
    required this.columnsCount,
    required this.itemsToShow,
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
    this.isVisibleToGuests = true,
    this.isVisibleToRegistered = true,
    this.requiresPermission,
    this.startDate,
    this.endDate,
    this.metadata,
    this.categoryClass,
    this.homeItemsCount,
  });

  /// Parses a backend section payload and tolerates loose string, bool, and
  /// date representations.
  ///
  /// يحلل حمولة القسم القادمة من الخادم ويتعامل مع التمثيلات النصية
  /// والبوليانية والتاريخية غير الصارمة.
  factory SectionModel.fromJson(Map<String, dynamic> json) {
    SectionTypeEnum parseType(dynamic v) {
      final s = (v ?? '').toString();
      return SectionUITypeExtension.tryFromString(s) ?? SectionTypeEnum.grid;
    }

    SectionContentType parseContentType(dynamic v) {
      final s = (v ?? 'Properties').toString();
      return SectionContentTypeApi.tryParse(s) ?? SectionContentType.properties;
    }

    SectionDisplayStyle parseDisplayStyle(dynamic v) {
      final s = (v ?? 'Grid').toString();
      return SectionDisplayStyleApi.tryParse(s) ?? SectionDisplayStyle.grid;
    }

    SectionTarget parseTarget(dynamic v) {
      final s = (v ?? 'Properties').toString();
      return SectionTargetApi.tryParse(s) ?? SectionTarget.properties;
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? toDate(dynamic v) {
      if (v == null || v.toString().isEmpty) return null;
      return DateTime.tryParse(v.toString());
    }

    return SectionModel(
      tempKey: json['tempKey']?.toString(),
      id: json['id']?.toString() ?? '',
      type: parseType(json['type']),
      contentType: parseContentType(json['contentType']),
      displayStyle: parseDisplayStyle(json['displayStyle']),
      name: json['name'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      shortDescription: json['shortDescription'],
      displayOrder: (json['displayOrder'] is int)
          ? json['displayOrder']
          : int.tryParse('${json['displayOrder'] ?? 0}') ?? 0,
      target: parseTarget(json['target']),
      isActive: json['isActive'] == null
          ? true
          : (json['isActive'] is bool
              ? (json['isActive'] as bool)
              : ['true', '1', 'yes', 'on']
                  .contains(json['isActive'].toString().toLowerCase())),
      columnsCount: (json['columnsCount'] is int)
          ? json['columnsCount']
          : int.tryParse('${json['columnsCount'] ?? 2}') ?? 2,
      itemsToShow: (json['itemsToShow'] is int)
          ? json['itemsToShow']
          : int.tryParse('${json['itemsToShow'] ?? 10}') ?? 10,
      icon: json['icon'],
      colorTheme: json['colorTheme'],
      backgroundImage: json['backgroundImage'],
      filterCriteria: json['filterCriteria'],
      sortCriteria: json['sortCriteria'],
      cityName: json['cityName'],
      propertyTypeId: json['propertyTypeId']?.toString(),
      unitTypeId: json['unitTypeId']?.toString(),
      minPrice: toDouble(json['minPrice']),
      maxPrice: toDouble(json['maxPrice']),
      minRating: toDouble(json['minRating']),
      isVisibleToGuests:
          json['isVisibleToGuests'] is bool ? json['isVisibleToGuests'] : true,
      isVisibleToRegistered: json['isVisibleToRegistered'] is bool
          ? json['isVisibleToRegistered']
          : true,
      requiresPermission: json['requiresPermission']?.toString(),
      startDate: toDate(json['startDate']),
      endDate: toDate(json['endDate']),
      metadata: json['metadata']?.toString(),
      categoryClass:
          SectionClassApi.tryParse(json['categoryClass']?.toString()),
      homeItemsCount: (json['homeItemsCount'] is int)
          ? json['homeItemsCount']
          : int.tryParse('${json['homeItemsCount'] ?? ''}'),
    );
  }

  /// Serializes the model into the API shape used for create and update calls.
  ///
  /// يعيد النموذج إلى الصيغة التي تستخدمها طلبات الإنشاء والتحديث.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type.apiValue, // ✅ إصلاح: إرسال القيمة الرقمية للـ Backend
      'contentType': contentType.apiValue,
      'displayStyle': displayStyle.apiValue,
      'name': name,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'shortDescription': shortDescription,
      'displayOrder': displayOrder,
      'target': target.apiValue,
      'isActive': isActive,
      'columnsCount': columnsCount,
      'itemsToShow': itemsToShow,
      'icon': icon,
      'colorTheme': colorTheme,
      'backgroundImage': backgroundImage,
      'filterCriteria': filterCriteria,
      'sortCriteria': sortCriteria,
      'cityName': cityName,
      'propertyTypeId': propertyTypeId,
      'unitTypeId': unitTypeId,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'isVisibleToGuests': isVisibleToGuests,
      'isVisibleToRegistered': isVisibleToRegistered,
      'requiresPermission': requiresPermission,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'metadata': metadata,
      if (categoryClass != null) 'categoryClass': categoryClass!.apiValue,
      if (homeItemsCount != null) 'homeItemsCount': homeItemsCount,
    };
    if (tempKey != null && tempKey!.isNotEmpty) {
      map['tempKey'] = tempKey;
    }
    // Only include id when it's non-empty to avoid backend validation issues on create
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  /// Converts the data-layer model back into the domain entity.
  ///
  /// يحول نموذج طبقة البيانات مرة أخرى إلى كيان المجال.
  domain.Section toEntity() {
    return domain.Section(
      id: id,
      type: type,
      contentType: contentType,
      displayStyle: displayStyle,
      name: name,
      title: title,
      subtitle: subtitle,
      description: description,
      shortDescription: shortDescription,
      displayOrder: displayOrder,
      target: target,
      isActive: isActive,
      columnsCount: columnsCount,
      itemsToShow: itemsToShow,
      categoryClass: categoryClass,
      homeItemsCount: homeItemsCount,
      icon: icon,
      colorTheme: colorTheme,
      backgroundImage: backgroundImage,
      filterCriteria: filterCriteria,
      sortCriteria: sortCriteria,
      cityName: cityName,
      propertyTypeId: propertyTypeId,
      unitTypeId: unitTypeId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      isVisibleToGuests: isVisibleToGuests,
      isVisibleToRegistered: isVisibleToRegistered,
      requiresPermission: requiresPermission,
      startDate: startDate,
      endDate: endDate,
      metadata: metadata,
    );
  }
}
