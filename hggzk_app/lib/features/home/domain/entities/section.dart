// lib/features/home/domain/entities/section.dart

import 'package:equatable/equatable.dart';
import '../../../../core/enums/section_type_enum.dart';
import '../../../../core/enums/section_target_enum.dart';

/// يصف مقطعًا من الصفحة الرئيسية، مع ترتيبه ووجهته ومنطق العرض الذي يحدد
/// كيف يجب أن ترسمه الواجهة.
/// Describes one home-screen section, including its order, target, and the
/// rendering rules that tell the UI how to display it.
class Section extends Equatable {
  /// المعرّف الثابت الذي يميز القسم عبر الخادم والكاش والواجهة.
  /// Stable identifier that distinguishes the section across backend, cache,
  /// and UI layers.
  final String id;

  /// النوع الأصلي القادم من الخادم والذي نحتفظ به للتوافق مع البيانات القديمة
  /// أو القواعد الخلفية.
  /// Original backend type kept for backward compatibility and backend-facing
  /// rules.
  final SectionType type;

  /// النوع الذي تعتمد عليه طبقة العرض فعليًا لتحديد ما إذا كان القسم شبكة أو
  /// قائمة أو بطاقات كبيرة.
  /// UI-facing type used to decide whether the section should render as a grid,
  /// list, or big-card experience.
  final SectionType uiType;

  /// ترتيب ظهور القسم داخل الصفحة الرئيسية.
  /// Order in which the section should appear on the home screen.
  final int displayOrder;

  /// الجمهور أو المسار الذي يستهدفه القسم داخل التطبيق.
  /// Audience or navigation target that this section is meant for.
  final SectionTarget target;

  /// يحدد ما إذا كان القسم نشطًا وقابلًا للعرض للمستخدم.
  /// Indicates whether the section is active and eligible for display.
  final bool isActive;

  /// اسم داخلي اختياري يصل من الخادم للمطابقة أو الإدارة.
  /// Optional internal name supplied by the backend for identification or
  /// admin-side matching.
  final String? name;

  /// العنوان الرئيسي الظاهر للمستخدم داخل الواجهة.
  /// Primary title shown to the user in the interface.
  final String? title;

  /// نص مساعد يقدّم القسم أو يشرح غرضه بسرعة.
  /// Supporting copy that introduces the section or explains its purpose.
  final String? subtitle;

  /// عائلة المحتوى التي يقدمها القسم مثل العقارات أو الوحدات.
  /// Content family hosted by the section, such as properties or units.
  final String? contentType;

  /// أسلوب العرض المقترح لهذا القسم مثل الشبكة أو القائمة أو السلايدر.
  /// Suggested rendering style for this section, such as grid, list, or
  /// carousel.
  final String? displayStyle;

  /// عدد الأعمدة المفضل عندما يُعرض القسم بصيغة شبكية.
  /// Preferred column count when the section is rendered as a grid.
  final int columnsCount;

  /// عدد العناصر الافتراضي المعروض قبل الانتقال إلى عرض موسع أو تحميل إضافي.
  /// Default number of items shown before switching to expanded or paginated
  /// views.
  final int itemsToShow;

  /// عدد خاص بالصفحة الرئيسية عندما يرسله الخادم كقيد مختلف عن الإعداد العام.
  /// Home-specific item count when the backend sends a value different from the
  /// general default.
  final int? homeItemsCount;

  /// تصنيف داخلي يستخدم لتجميع الأقسام المتشابهة أو معالجتها معًا.
  /// Internal grouping label used to cluster related section families.
  final String? categoryClass;

  /// بيانات إضافية بصيغة JSON قد تحمل إعدادات خاصة بالقسم أو منطق عرض إضافي.
  /// Extra JSON metadata that may carry section-specific settings or rendering
  /// rules.
  final String? metadata;

  /// ينشئ تمثيل القسم الذي تعتمد عليه طبقة الأعمال والواجهة معًا.
  /// Creates the section entity shared by business logic and presentation.
  const Section({
    required this.id,
    required this.type,
    required this.uiType,
    required this.displayOrder,
    required this.target,
    required this.isActive,
    this.name,
    this.title,
    this.subtitle,
    this.contentType,
    this.displayStyle,
    this.columnsCount = 2,
    this.itemsToShow = 10,
    this.homeItemsCount,
    this.categoryClass,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        uiType,
        displayOrder,
        target,
        isActive,
        name,
        title,
        subtitle,
        contentType,
        displayStyle,
        columnsCount,
        itemsToShow,
        homeItemsCount,
        categoryClass,
        metadata,
      ];
}

/// يصف رابطًا خفيفًا بين القسم وعنصره الفعلي، بحيث نعرف أي عقار أو وحدة يجب
/// عرضه وبأي ترتيب داخل ذلك القسم.
/// Describes the lightweight link between a section and its actual content
/// item, including which property or unit should appear and in what order.
class SectionItem extends Equatable {
  /// المعرّف الثابت لهذا الربط داخل القسم.
  /// Stable identifier for this item linkage inside the section.
  final String id;

  /// معرّف القسم الأب الذي يحتوي هذا العنصر.
  /// Identifier of the parent section that contains this item.
  final String sectionId;

  /// معرّف العقار إذا كان هذا الربط يشير إلى عقار.
  /// Property identifier when this linkage points to a property.
  final String? propertyId;

  /// معرّف الوحدة إذا كان هذا الربط يشير إلى وحدة.
  /// Unit identifier when this linkage points to a unit.
  final String? unitId;

  /// ترتيب ظهور العنصر داخل القسم نفسه.
  /// Display order of the item within its section.
  final int sortOrder;

  /// ينشئ رابط العنصر داخل القسم مع المعرفات اللازمة لبنائه في الواجهة.
  /// Creates the section item link with the identifiers needed to render it in
  /// the UI.
  const SectionItem({
    required this.id,
    required this.sectionId,
    this.propertyId,
    this.unitId,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, sectionId, propertyId, unitId, sortOrder];
}
