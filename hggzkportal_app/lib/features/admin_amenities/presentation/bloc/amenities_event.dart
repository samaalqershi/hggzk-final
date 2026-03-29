import 'package:equatable/equatable.dart';

/// Base class for every amenity-related command sent to the bloc.
/// الفئة الأساسية لكل أوامر المرافق التي تُرسل إلى البلوك.
abstract class AmenitiesEvent extends Equatable {
  /// Creates a typed event base that lets subclasses define their own payloads.
  /// ينشئ أساسًا للأحداث يتيح للأنواع الفرعية تعريف بياناتها الخاصة.
  const AmenitiesEvent();

  @override

  /// Comparison keys used by Equatable for all amenity events.
  /// مفاتيح المقارنة التي يستخدمها Equatable لكل أحداث المرافق.
  List<Object?> get props => [];
}

/// Loads a paginated amenity list using the active filters and context.
/// يحمّل قائمة مرافق مُصفّحة باستخدام الفلاتر والسياق النشط.
class LoadAmenitiesEvent extends AmenitiesEvent {
  /// The page number to request from the backend.
  /// رقم الصفحة المطلوب من الخادم.
  final int pageNumber;

  /// The number of items per page.
  /// عدد العناصر في كل صفحة.
  final int pageSize;

  /// Optional text used to narrow the list by name or description.
  /// نص اختياري لتضييق النتائج بالاسم أو الوصف.
  final String? searchTerm;

  /// Optional property identifier used when the list is scoped to one property.
  /// معرّف العقار الاختياري عندما تكون القائمة مقيدة بعقار واحد.
  final String? propertyId;

  /// Optional flag that limits results to assigned amenities.
  /// علم اختياري يقصر النتائج على المرافق المعيّنة.
  final bool? isAssigned;

  /// Optional flag that limits results to free amenities.
  /// علم اختياري يقصر النتائج على المرافق المجانية.
  final bool? isFree;

  /// Optional property type filter used for type-scoped listings.
  /// فلتر اختياري لنوع العقار عند عرض قوائم مقيّدة بالنوع.
  final String? propertyTypeId;

  /// Creates a load request with paging and filter parameters.
  /// ينشئ طلب تحميل مع معاملات التصفح والفلاتر.
  const LoadAmenitiesEvent({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchTerm,
    this.propertyId,
    this.isAssigned,
    this.isFree,
    this.propertyTypeId,
  });

  @override

  /// Comparison keys that distinguish one load request from another.
  /// مفاتيح المقارنة التي تميّز طلب تحميل عن آخر.
  List<Object?> get props => [
        pageNumber,
        pageSize,
        searchTerm,
        propertyId,
        isAssigned,
        isFree,
        propertyTypeId,
      ];
}

/// Creates a new amenity from the data entered in the admin form.
/// ينشئ مرفقًا جديدًا من البيانات المدخلة في نموذج الإدارة.
class CreateAmenityEvent extends AmenitiesEvent {
  /// The amenity display name.
  /// اسم المرفق الظاهر.
  final String name;

  /// The English amenity name stored beside the primary name.
  /// الاسم الإنجليزي الموازي للمرفق.
  final String? nameEn;

  /// The longer description shown in detail screens.
  /// الوصف الأطول المعروض في شاشات التفاصيل.
  final String description;

  /// The English description stored beside the primary text.
  /// الوصف الإنجليزي الموازي للنص الأساسي.
  final String? descriptionEn;

  /// The icon identifier or symbol used in the UI.
  /// معرّف الأيقونة أو الرمز المستخدم في الواجهة.
  final String icon;

  /// Optional property type that owns the amenity by default.
  /// نوع العقار الاختياري الذي يملك هذا المرفق افتراضيًا.
  final String? propertyTypeId;

  /// Marks the new amenity as the default for its type when true.
  /// يحدد المرفق الجديد كافتراضي لنوعه عند التفعيل.
  final bool isDefaultForType;

  /// Creates an amenity creation request from form values.
  /// ينشئ طلب إنشاء مرفق من قيم النموذج.
  const CreateAmenityEvent({
    required this.name,
    this.nameEn,
    required this.description,
    this.descriptionEn,
    required this.icon,
    this.propertyTypeId,
    this.isDefaultForType = false,
  });

  @override

  /// Comparison keys that capture every field used to create the amenity.
  /// مفاتيح المقارنة التي تغطي كل الحقول المستخدمة في إنشاء المرفق.
  List<Object?> get props => [
        name,
        nameEn,
        description,
        descriptionEn,
        icon,
        propertyTypeId,
        isDefaultForType
      ];
}

/// Updates an existing amenity with edited admin values.
/// يحدّث مرفقًا موجودًا باستخدام القيم المعدلة في لوحة الإدارة.
class UpdateAmenityEvent extends AmenitiesEvent {
  /// The identifier of the amenity being updated.
  /// معرّف المرفق الجاري تحديثه.
  final String amenityId;

  /// Optional replacement name.
  /// اسم بديل اختياري.
  final String? name;

  /// Optional replacement English name.
  /// اسم إنجليزي بديل اختياري.
  final String? nameEn;

  /// Optional replacement description.
  /// وصف بديل اختياري.
  final String? description;

  /// Optional replacement English description.
  /// وصف إنجليزي بديل اختياري.
  final String? descriptionEn;

  /// Optional replacement icon.
  /// أيقونة بديلة اختيارية.
  final String? icon;

  /// Creates an update command with partial fields.
  /// ينشئ أمر تحديث مع حقول جزئية.
  const UpdateAmenityEvent({
    required this.amenityId,
    this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    this.icon,
  });

  @override

  /// Comparison keys for the edited amenity payload.
  /// مفاتيح المقارنة لحمولة المرفق المعدلة.
  List<Object?> get props =>
      [amenityId, name, nameEn, description, descriptionEn, icon];
}

/// Deletes one amenity from the catalog.
/// يحذف مرفقًا واحدًا من الكتالوج.
class DeleteAmenityEvent extends AmenitiesEvent {
  /// The identifier of the amenity to delete.
  /// معرّف المرفق المطلوب حذفه.
  final String amenityId;

  /// Creates a delete command for the selected amenity.
  /// ينشئ أمر حذف للمرفق المحدد.
  const DeleteAmenityEvent({required this.amenityId});

  @override

  /// Comparison key for the amenity being deleted.
  /// مفتاح المقارنة للمرفق الجاري حذفه.
  List<Object> get props => [amenityId];
}

/// Toggles whether an amenity is active or inactive.
/// يبدّل ما إذا كان المرفق نشطًا أم غير نشط.
class ToggleAmenityStatusEvent extends AmenitiesEvent {
  /// The identifier of the amenity whose status should change.
  /// معرّف المرفق الذي يجب تغيير حالته.
  final String amenityId;

  /// Creates a status toggle command for the selected amenity.
  /// ينشئ أمر تبديل حالة للمرفق المحدد.
  const ToggleAmenityStatusEvent({required this.amenityId});

  @override

  /// Comparison key for the amenity whose status is changing.
  /// مفتاح المقارنة للمرفق الذي تتغير حالته.
  List<Object> get props => [amenityId];
}

/// Assigns a catalog amenity to a specific property.
/// يربط مرفقًا من الكتالوج بعقار محدد.
class AssignAmenityToPropertyEvent extends AmenitiesEvent {
  /// The amenity being assigned.
  /// المرفق الذي سيتم إسناده.
  final String amenityId;

  /// The target property identifier.
  /// معرّف العقار المستهدف.
  final String propertyId;

  /// Whether the amenity should be available for bookings.
  /// ما إذا كان المرفق سيبقى متاحًا للحجوزات.
  final bool isAvailable;

  /// Optional extra cost applied to the amenity.
  /// تكلفة إضافية اختيارية تُضاف على المرفق.
  final double? extraCost;

  /// Optional description describing how the assignment should behave.
  /// وصف اختياري يوضح طريقة الإسناد أو استخدامه.
  final String? description;

  /// Creates a property assignment request for one amenity.
  /// ينشئ طلب إسناد لعقار لمرفق واحد.
  const AssignAmenityToPropertyEvent({
    required this.amenityId,
    required this.propertyId,
    this.isAvailable = true,
    this.extraCost,
    this.description,
  });

  @override

  /// Comparison keys for the property assignment request.
  /// مفاتيح المقارنة لطلب إسناد المرفق إلى العقار.
  List<Object?> get props => [
        amenityId,
        propertyId,
        isAvailable,
        extraCost,
        description,
      ];
}

/// Assigns an amenity to a property type and optionally marks it as default.
/// يربط مرفقًا بنوع عقار ويمكن أن يضعه كخيار افتراضي أيضًا.
class AssignAmenityToPropertyTypeEvent extends AmenitiesEvent {
  /// The amenity being linked to a type.
  /// المرفق الذي سيتم ربطه بالنوع.
  final String amenityId;

  /// The property type that receives the amenity.
  /// نوع العقار الذي يستقبل المرفق.
  final String propertyTypeId;

  /// Marks this amenity as the default option for the type when true.
  /// يحدد هذا المرفق كخيار افتراضي للنـوع عند التفعيل.
  final bool isDefault;

  /// Creates a property-type assignment command.
  /// ينشئ أمر إسناد إلى نوع العقار.
  const AssignAmenityToPropertyTypeEvent({
    required this.amenityId,
    required this.propertyTypeId,
    this.isDefault = false,
  });

  @override

  /// Comparison keys for the property-type assignment request.
  /// مفاتيح المقارنة لطلب الإسناد إلى نوع العقار.
  List<Object?> get props => [amenityId, propertyTypeId, isDefault];
}

/// Requests the current amenity statistics for dashboard summaries.
/// يطلب الإحصائيات الحالية للمرافق لملخصات لوحة الإدارة.
class LoadAmenityStatsEvent extends AmenitiesEvent {
  /// Creates a stats refresh command.
  /// ينشئ أمر تحديث للإحصائيات.
  const LoadAmenityStatsEvent();

  @override

  /// No payload is needed because this command only asks for fresh stats.
  /// لا توجد حمولة لأن هذا الأمر يطلب الإحصائيات فقط.
  List<Object?> get props => [];
}

/// Searches amenities using the provided text.
/// يبحث في المرافق باستخدام النص المعطى.
class SearchAmenitiesEvent extends AmenitiesEvent {
  /// The search text entered by the user.
  /// نص البحث الذي أدخله المستخدم.
  final String searchTerm;

  /// Creates a search command for amenity filtering.
  /// ينشئ أمر بحث لتصفية المرافق.
  const SearchAmenitiesEvent({required this.searchTerm});

  @override

  /// Comparison key for the active search string.
  /// مفتاح المقارنة لنص البحث النشط.
  List<Object> get props => [searchTerm];
}

/// Marks a single amenity as selected in the current list.
/// يحدد مرفقًا واحدًا كعنصر مختار في القائمة الحالية.
class SelectAmenityEvent extends AmenitiesEvent {
  /// The selected amenity identifier.
  /// معرّف المرفق المختار.
  final String amenityId;

  /// Creates a selection command for the given amenity.
  /// ينشئ أمر اختيار للمرفق المعطى.
  const SelectAmenityEvent({required this.amenityId});

  @override

  /// Comparison key for the selected amenity id.
  /// مفتاح المقارنة لمعرّف المرفق المختار.
  List<Object> get props => [amenityId];
}

/// Clears the current amenity selection.
/// يمسح اختيار المرفق الحالي.
class DeselectAmenityEvent extends AmenitiesEvent {
  /// Creates a deselection command with no payload.
  /// ينشئ أمر إلغاء اختيار من دون بيانات إضافية.
  const DeselectAmenityEvent();

  @override

  /// No payload is needed because this command only clears the selection.
  /// لا توجد حمولة لأن هذا الأمر يمسح الاختيار فقط.
  List<Object?> get props => [];
}

/// Requests the top popular amenities for quick access or highlighting.
/// يطلب أكثر المرافق شيوعًا لإبرازها أو الوصول السريع إليها.
class LoadPopularAmenitiesEvent extends AmenitiesEvent {
  /// The maximum number of popular amenities to fetch.
  /// الحد الأقصى لعدد المرافق الشائعة المطلوب جلبها.
  final int limit;

  /// Creates a request for popular amenities with an optional limit.
  /// ينشئ طلبًا لجلب المرافق الشائعة مع حد اختياري.
  const LoadPopularAmenitiesEvent({this.limit = 10});

  @override

  /// Comparison key for the requested popularity limit.
  /// مفتاح المقارنة لحدّ المرافق الشائعة المطلوب.
  List<Object> get props => [limit];
}

/// Replays the current list query using the last known filters and pagination.
/// يعيد تنفيذ استعلام القائمة الحالي باستخدام آخر فلاتر وتصفح معروفين.
class RefreshAmenitiesEvent extends AmenitiesEvent {
  /// Creates a refresh command with no extra payload.
  /// ينشئ أمر تحديث من دون بيانات إضافية.
  const RefreshAmenitiesEvent();

  @override

  /// No payload is needed because refresh reuses the current cache values.
  /// لا توجد حمولة لأن التحديث يعيد استخدام القيم المخزنة حاليًا.
  List<Object?> get props => [];
}

/// Moves the amenity list to a specific page.
/// ينقل قائمة المرافق إلى صفحة محددة.
class ChangePageEvent extends AmenitiesEvent {
  /// The target page number.
  /// رقم الصفحة المطلوب.
  final int pageNumber;

  /// Creates a paging command for the requested page number.
  /// ينشئ أمر تنقل بالصفحات للرقم المطلوب.
  const ChangePageEvent({required this.pageNumber});

  @override

  /// Comparison key for the target page number.
  /// مفتاح المقارنة لرقم الصفحة المستهدفة.
  List<Object> get props => [pageNumber];
}

/// Changes how many amenities are requested per page.
/// يغيّر عدد المرافق المطلوبة في كل صفحة.
class ChangePageSizeEvent extends AmenitiesEvent {
  /// The new number of items per page.
  /// العدد الجديد للعناصر في كل صفحة.
  final int pageSize;

  /// Creates a page-size command for the requested value.
  /// ينشئ أمر تغيير حجم صفحة للقيمة المطلوبة.
  const ChangePageSizeEvent({required this.pageSize});

  @override

  /// Comparison key for the new page size.
  /// مفتاح المقارنة لحجم الصفحة الجديد.
  List<Object> get props => [pageSize];
}

/// Applies a new filter combination to the amenity list.
/// يطبّق مجموعة فلاتر جديدة على قائمة المرافق.
class ApplyFiltersEvent extends AmenitiesEvent {
  /// Optional search term to combine with the filters.
  /// نص بحث اختياري يدمج مع الفلاتر.
  final String? searchTerm;

  /// Optional assigned-only filter.
  /// فلتر اختياري للمرافق المعيّنة فقط.
  final bool? isAssigned;

  /// Optional free-only filter.
  /// فلتر اختياري للمرافق المجانية فقط.
  final bool? isFree;

  /// Optional property type filter to narrow the dataset further.
  /// فلتر اختياري لنوع العقار لتضييق مجموعة النتائج.
  final String? propertyTypeId;

  /// Creates a filter application command from the selected criteria.
  /// ينشئ أمر تطبيق فلاتر من المعايير المختارة.
  const ApplyFiltersEvent({
    this.searchTerm,
    this.isAssigned,
    this.isFree,
    this.propertyTypeId,
  });

  @override

  /// Comparison keys for the active filter combination.
  /// مفاتيح المقارنة لمجموعة الفلاتر النشطة.
  List<Object?> get props => [searchTerm, isAssigned, isFree, propertyTypeId];
}

/// Clears all active filters and restores the default list state.
/// يمسح جميع الفلاتر النشطة ويعيد حالة القائمة الافتراضية.
class ClearFiltersEvent extends AmenitiesEvent {
  /// Creates a filter reset command with no payload.
  /// ينشئ أمر إعادة ضبط للفلاتر من دون بيانات إضافية.
  const ClearFiltersEvent();

  @override

  /// No payload is needed because clearing filters always means the same action.
  /// لا توجد حمولة لأن مسح الفلاتر يعني دائمًا نفس العملية.
  List<Object?> get props => [];
}
