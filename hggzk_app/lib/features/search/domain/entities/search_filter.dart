import 'package:equatable/equatable.dart';

/// Defines one filter group that the search screen can render and persist.
/// يعرّف مجموعة فلترة واحدة يمكن لشاشة البحث عرضها وحفظها.
class SearchFilter extends Equatable {
  /// Stable backend identifier for this filter group.
  /// المعرّف الثابت القادم من الخادم لمجموعة الفلترة هذه.
  final String filterId;

  /// Identifier of the dynamic field or rule the filter belongs to.
  /// معرّف الحقل الديناميكي أو القاعدة المرتبطة بهذه الفلترة.
  final String fieldId;

  /// Describes how the search UI should present the filter.
  /// يحدد كيف يجب أن تعرض واجهة البحث هذه الفلترة.
  final String filterType;

  /// Human-friendly label shown to the user.
  /// الاسم المقروء الذي يظهر للمستخدم.
  final String displayName;

  /// Extra configuration used to render choices, ranges, or backend hints.
  /// إعدادات إضافية تُستخدم لعرض الخيارات أو النطاقات أو تعليمات الخادم.
  final Map<String, dynamic> filterOptions;

  /// Marks filters that should still be exposed in the current search flow.
  /// يحدد ما إذا كانت الفلترة ما زالت ظاهرة في مسار البحث الحالي.
  final bool isActive;

  /// Relative order used when the search UI groups multiple filters together.
  /// ترتيب العرض عند تجميع أكثر من فلترة في الواجهة.
  final int sortOrder;

  /// Optional field metadata that describes the form control behind the filter.
  /// بيانات الحقل الاختيارية التي تشرح عنصر الإدخال المرتبط بهذه الفلترة.
  final UnitTypeField? field;

  /// Creates an immutable search filter definition ready for the UI layer.
  /// ينشئ تعريفًا ثابتًا للفلترة جاهزًا لطبقة الواجهة.
  const SearchFilter({
    required this.filterId,
    required this.fieldId,
    required this.filterType,
    required this.displayName,
    required this.filterOptions,
    required this.isActive,
    required this.sortOrder,
    this.field,
  });

  /// Keeps equality aligned with the visible filter configuration.
  /// يحافظ على ثبات المقارنة مع إعدادات الفلترة الظاهرة.
  @override
  List<Object?> get props => [
        filterId,
        fieldId,
        filterType,
        displayName,
        filterOptions,
        isActive,
        sortOrder,
        field,
      ];
}

/// Describes a dynamic field that can appear inside a search filter group.
/// يصف الحقل الديناميكي الذي قد يظهر داخل مجموعة فلترة البحث.
class UnitTypeField extends Equatable {
  /// Backend identifier for the field definition.
  /// المعرّف الخلفي لتعريف الحقل.
  final String fieldId;

  /// Links the field to the unit type that owns it.
  /// يربط الحقل بنوع الوحدة الذي يملكه.
  final String unitTypeId;

  /// Identifies the rendering or validation type used by the UI.
  /// يحدد نوع العرض أو التحقق الذي ستستخدمه الواجهة.
  final String fieldTypeId;

  /// Internal field name used in payloads and mappings.
  /// الاسم الداخلي للحقل المستخدم في الحمولة والربط.
  final String fieldName;

  /// Label shown to users when the field is rendered.
  /// التسمية الظاهرة للمستخدم عند عرض الحقل.
  final String displayName;

  /// Optional explanation that can help the user understand the field.
  /// شرح اختياري يساعد المستخدم على فهم الحقل.
  final String? description;

  /// Visual or behavioral options for the field widget.
  /// خيارات العرض أو السلوك الخاصة بعنصر الواجهة.
  final Map<String, dynamic> fieldOptions;

  /// Validation rules consumed by forms before submission.
  /// قواعد التحقق التي تعتمد عليها النماذج قبل الإرسال.
  final Map<String, dynamic> validationRules;

  /// Marks fields that must be filled before the search can be applied.
  /// يحدد الحقول التي يجب تعبئتها قبل تطبيق البحث.
  final bool isRequired;

  /// Marks fields that should be searchable in advanced filter UIs.
  /// يحدد الحقول القابلة للبحث داخل واجهات الفلاتر المتقدمة.
  final bool isSearchable;

  /// Controls whether the field can be exposed to end users.
  /// يتحكم في ما إذا كان الحقل يمكن إظهاره للمستخدم النهائي.
  final bool isPublic;

  /// Relative order when multiple fields belong to the same group.
  /// ترتيب العرض عندما تنتمي عدة حقول إلى المجموعة نفسها.
  final int sortOrder;

  /// Optional category name used to cluster related filters.
  /// اسم فئة اختياري لتجميع الفلاتر المتقاربة.
  final String? category;

  /// Optional backend group identifier for nested filter structures.
  /// معرّف مجموعة اختياري يدعم البنى المتداخلة للفلاتر.
  final String? groupId;

  /// Indicates whether the field applies to units rather than the whole property.
  /// يوضح ما إذا كان الحقل يخص الوحدات بدلًا من العقار ككل.
  final bool isForUnits;

  /// Controls whether the field should appear in compact result cards.
  /// يتحكم في ظهور الحقل داخل البطاقات المختصرة للنتائج.
  final bool showInCards;

  /// Marks the field as a primary filter the UI can emphasize first.
  /// يميز الحقل كفلترة أساسية تستحق الإبراز أولًا.
  final bool isPrimaryFilter;

  /// Higher priority fields can be surfaced before less important ones.
  /// الحقول الأعلى أولوية يمكن عرضها قبل الحقول الأقل أهمية.
  final int priority;

  /// Creates an immutable field definition for the search experience.
  /// ينشئ تعريفًا ثابتًا لحقل يُستخدم في تجربة البحث.
  const UnitTypeField({
    required this.fieldId,
    required this.unitTypeId,
    required this.fieldTypeId,
    required this.fieldName,
    required this.displayName,
    this.description,
    required this.fieldOptions,
    required this.validationRules,
    required this.isRequired,
    required this.isSearchable,
    required this.isPublic,
    required this.sortOrder,
    this.category,
    this.groupId,
    required this.isForUnits,
    required this.showInCards,
    required this.isPrimaryFilter,
    required this.priority,
  });

  /// Keeps equality aligned with the field configuration.
  /// يحافظ على ثبات المقارنة مع إعدادات الحقل.
  @override
  List<Object?> get props => [
        fieldId,
        unitTypeId,
        fieldTypeId,
        fieldName,
        displayName,
        description,
        fieldOptions,
        validationRules,
        isRequired,
        isSearchable,
        isPublic,
        sortOrder,
        category,
        groupId,
        isForUnits,
        showInCards,
        isPrimaryFilter,
        priority,
      ];
}
