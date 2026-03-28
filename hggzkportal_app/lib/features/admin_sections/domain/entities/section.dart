import 'package:equatable/equatable.dart';
import '../../../../core/enums/section_type.dart';
import '../../../../core/enums/section_target.dart';
import '../../../../core/enums/section_content_type.dart';
import '../../../../core/enums/section_display_style.dart';
import '../../../../core/enums/section_class.dart';

/// Describes a configurable content block that controls what the portal shows
/// on the home and discovery surfaces.
///
/// يصف كتلة محتوى قابلة للتكوين تتحكم فيما تعرضه البوابة على واجهات
/// الاستكشاف والصفحة الرئيسية.
class Section extends Equatable {
  /// Stable section identifier used by editors and ordering tools.
  ///
  /// المعرّف الثابت للقسم المستخدم في المحررات وأدوات الترتيب.
  final String id;

  /// High-level section type that determines behavior and targeting.
  ///
  /// نوع القسم العام الذي يحدد السلوك والاستهداف.
  final SectionTypeEnum type;

  /// Content family rendered inside the section, such as properties or units.
  ///
  /// عائلة المحتوى المعروضة داخل القسم مثل العقارات أو الوحدات.
  final SectionContentType contentType;

  /// Visual layout used to present the section's items.
  ///
  /// التخطيط المرئي المستخدم لعرض عناصر القسم.
  final SectionDisplayStyle displayStyle;

  /// Internal-friendly label used by operators and editors.
  ///
  /// اسم داخلي مناسب للمشغلين والمحررين.
  final String? name;

  /// Public title shown to portal visitors.
  ///
  /// العنوان العام الظاهر لزوار البوابة.
  final String? title;

  /// Optional supporting line displayed under the title.
  ///
  /// سطر داعم اختياري يظهر أسفل العنوان.
  final String? subtitle;

  /// Longer explanatory copy for banners and editorial sections.
  ///
  /// نص توضيحي أطول للبنرات والأقسام التحريرية.
  final String? description;

  /// Shorter summary used in compact cards and previews.
  ///
  /// ملخص أقصر يستخدم في البطاقات والمعاينات المختصرة.
  final String? shortDescription;

  /// Order index used when sections are sorted on the page.
  ///
  /// فهرس الترتيب المستخدم عند فرز الأقسام في الصفحة.
  final int displayOrder;

  /// Audience or placement target for the section.
  ///
  /// الجمهور أو موضع العرض المستهدف للقسم.
  final SectionTarget target;

  /// Indicates whether the section should be published right now.
  ///
  /// يحدد ما إذا كان القسم يجب أن يكون منشورًا الآن.
  final bool isActive;

  /// Number of columns used by grid-style layouts.
  ///
  /// عدد الأعمدة المستخدمة في التخطيطات الشبكية.
  final int columnsCount;

  /// Maximum number of items the section should render.
  ///
  /// الحد الأقصى للعناصر التي يجب أن يعرضها القسم.
  final int itemsToShow;

  /// Optional icon name or asset reference for the header.
  ///
  /// اسم أيقونة أو مرجع أصل اختياري للرأس.
  final String? icon;

  /// Theme token that controls the section's accent colors.
  ///
  /// رمز المظهر الذي يتحكم في ألوان التمييز للقسم.
  final String? colorTheme;

  /// Background artwork used by featured or hero-style sections.
  ///
  /// صورة الخلفية المستخدمة في الأقسام البارزة أو ذات النمط البطولي.
  final String? backgroundImage;

  /// Serialized filter definition used by discovery and curation screens.
  ///
  /// تعريف الفلتر المرمّز المستخدم في شاشات الاستكشاف والاختيار.
  final String? filterCriteria;

  /// Serialized sorting rule for the section's items.
  ///
  /// قاعدة الفرز المرمزة لعناصر القسم.
  final String? sortCriteria;

  /// Optional city filter used to localize the section.
  ///
  /// فلتر مدينة اختياري لتخصيص القسم جغرافيًا.
  final String? cityName;

  /// Optional property type filter for curated property sections.
  ///
  /// فلتر نوع عقار اختياري للأقسام المنسقة.
  final String? propertyTypeId;

  /// Optional unit type filter for unit-focused sections.
  ///
  /// فلتر نوع وحدة اختياري للأقسام المخصصة للوحدات.
  final String? unitTypeId;

  /// Lower price bound used by curation filters.
  ///
  /// الحد الأدنى للسعر المستخدم في فلاتر الاختيار.
  final double? minPrice;

  /// Upper price bound used by curation filters.
  ///
  /// الحد الأعلى للسعر المستخدم في فلاتر الاختيار.
  final double? maxPrice;

  /// Minimum rating threshold used by the section query.
  ///
  /// الحد الأدنى للتقييم المستخدم في استعلام القسم.
  final double? minRating;

  /// Controls whether anonymous visitors can see the section.
  ///
  /// يتحكم بما إذا كان الزوار غير المسجلين يمكنهم رؤية القسم.
  final bool isVisibleToGuests;

  /// Controls whether signed-in users can see the section.
  ///
  /// يتحكم بما إذا كان المستخدمون المسجلون يمكنهم رؤية القسم.
  final bool isVisibleToRegistered;

  /// Optional permission key required before the section can be shown.
  ///
  /// مفتاح صلاحية اختياري يجب توفره قبل إظهار القسم.
  final String? requiresPermission;

  /// Optional start date for scheduled sections.
  ///
  /// تاريخ بدء اختياري للأقسام المجدولة.
  final DateTime? startDate;

  /// Optional end date for scheduled sections.
  ///
  /// تاريخ انتهاء اختياري للأقسام المجدولة.
  final DateTime? endDate;

  /// Serialized extra configuration that does not fit the typed fields.
  ///
  /// إعدادات إضافية مرمزة لا تناسب الحقول المهيكلة.
  final String? metadata;

  /// Optional higher-level classification used by the section editor.
  ///
  /// تصنيف أعلى اختياري يستخدمه محرر الأقسام.
  final SectionClass? categoryClass;

  /// Cached number of items currently shown on the home page.
  ///
  /// عدد العناصر المخزّن حاليًا والمستخدم في الصفحة الرئيسية.
  final int? homeItemsCount;

  /// Creates a configurable portal section with targeting and display rules.
  ///
  /// ينشئ قسمًا قابلاً للتكوين مع قواعد الاستهداف والعرض.
  const Section({
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

  /// Returns a new section instance with only the supplied fields changed.
  ///
  /// يعيد نسخة جديدة من القسم مع تغيير الحقول الممررة فقط.
  Section copyWith({
    String? id,
    SectionTypeEnum? type,
    SectionContentType? contentType,
    SectionDisplayStyle? displayStyle,
    String? name,
    String? title,
    String? subtitle,
    String? description,
    String? shortDescription,
    int? displayOrder,
    SectionTarget? target,
    bool? isActive,
    int? columnsCount,
    int? itemsToShow,
    String? icon,
    String? colorTheme,
    String? backgroundImage,
    String? filterCriteria,
    String? sortCriteria,
    String? cityName,
    String? propertyTypeId,
    String? unitTypeId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isVisibleToGuests,
    bool? isVisibleToRegistered,
    String? requiresPermission,
    DateTime? startDate,
    DateTime? endDate,
    String? metadata,
    SectionClass? categoryClass,
    int? homeItemsCount,
  }) {
    return Section(
      id: id ?? this.id,
      type: type ?? this.type,
      contentType: contentType ?? this.contentType,
      displayStyle: displayStyle ?? this.displayStyle,
      name: name ?? this.name,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      displayOrder: displayOrder ?? this.displayOrder,
      target: target ?? this.target,
      isActive: isActive ?? this.isActive,
      columnsCount: columnsCount ?? this.columnsCount,
      itemsToShow: itemsToShow ?? this.itemsToShow,
      icon: icon ?? this.icon,
      colorTheme: colorTheme ?? this.colorTheme,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      filterCriteria: filterCriteria ?? this.filterCriteria,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      cityName: cityName ?? this.cityName,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      unitTypeId: unitTypeId ?? this.unitTypeId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      isVisibleToGuests: isVisibleToGuests ?? this.isVisibleToGuests,
      isVisibleToRegistered:
          isVisibleToRegistered ?? this.isVisibleToRegistered,
      requiresPermission: requiresPermission ?? this.requiresPermission,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      metadata: metadata ?? this.metadata,
      categoryClass: categoryClass ?? this.categoryClass,
      homeItemsCount: homeItemsCount ?? this.homeItemsCount,
    );
  }

  /// Keeps equality aligned with the full section configuration.
  ///
  /// يربط المقارنة بإعدادات القسم كاملة.
  @override
  List<Object?> get props => [
        id,
        type,
        contentType,
        displayStyle,
        name,
        title,
        subtitle,
        description,
        shortDescription,
        displayOrder,
        target,
        isActive,
        columnsCount,
        itemsToShow,
        icon,
        colorTheme,
        backgroundImage,
        filterCriteria,
        sortCriteria,
        cityName,
        propertyTypeId,
        unitTypeId,
        minPrice,
        maxPrice,
        minRating,
        isVisibleToGuests,
        isVisibleToRegistered,
        requiresPermission,
        startDate,
        endDate,
        metadata,
        categoryClass,
        homeItemsCount,
      ];
}
