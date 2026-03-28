import 'package:equatable/equatable.dart';

/// Base event for property detail and booking flows.
/// الحدث الأساسي لمسارات تفاصيل العقار والحجز.
abstract class PropertyEvent extends Equatable {
  /// Creates the shared contract for all property events.
  /// ينشئ العقد المشترك لكل أحداث العقار.
  const PropertyEvent();

  /// Property events are compared by their payload so repeated UI actions
  /// remain deterministic.
  /// تُقارن أحداث العقار بحسب الحمولة حتى تبقى تصرفات الواجهة متوقعة.
  @override
  List<Object?> get props => [];
}

/// Requests the property snapshot shown on the detail screen.
/// يطلب لقطة العقار المعروضة في شاشة التفاصيل.
class GetPropertyDetailsEvent extends PropertyEvent {
  /// Property identifier to load.
  /// معرّف العقار المطلوب.
  final String propertyId;

  /// Optional viewer identifier used for personalization.
  /// معرّف اختياري للمستخدم يفيد في التخصيص.
  final String? userId;

  /// Optional role hint so the backend can shape the response.
  /// تلميح اختياري للدور حتى يكيّف الخادم الاستجابة.
  final String? userRole;

  /// Optional arrival date used for availability-aware detail data.
  /// تاريخ الوصول الاختياري المستخدم في بيانات التفاصيل المعتمدة على التوفر.
  final DateTime? checkInDate;

  /// Optional departure date paired with the arrival date.
  /// تاريخ المغادرة الاختياري المرتبط بتاريخ الوصول.
  final DateTime? checkOutDate;

  /// Number of adult guests included in the current booking context.
  /// عدد الضيوف البالغين ضمن سياق الحجز الحالي.
  final int? adults;

  /// Number of child guests included in the current booking context.
  /// عدد الأطفال ضمن سياق الحجز الحالي.
  final int? children;

  /// Total guest count used by availability and pricing logic.
  /// إجمالي الضيوف المستخدم في منطق التوفر والتسعير.
  final int? guestsCount;

  /// Optional unit type selected from the detail screen.
  /// نوع الوحدة الاختياري المحدد من شاشة التفاصيل.
  final String? unitTypeId;

  /// Bundles the context needed to load the correct property view.
  /// يجمع السياق اللازم لتحميل عرض العقار الصحيح.
  const GetPropertyDetailsEvent({
    required this.propertyId,
    this.userId,
    this.userRole,
    this.checkInDate,
    this.checkOutDate,
    this.adults,
    this.children,
    this.guestsCount,
    this.unitTypeId,
  });

  /// Keeps event equality aligned with the detail request payload.
  /// يحافظ على ثبات المقارنة مع حمولة طلب التفاصيل.
  @override
  List<Object?> get props => [
        propertyId,
        userId,
        userRole,
        checkInDate,
        checkOutDate,
        adults,
        children,
        guestsCount,
        unitTypeId,
      ];
}

/// Requests the list of units attached to one property.
/// يطلب قائمة الوحدات التابعة لعقار واحد.
class GetPropertyUnitsEvent extends PropertyEvent {
  /// Property identifier used to fetch the units.
  /// معرّف العقار المستخدم لجلب الوحدات.
  final String propertyId;

  /// Optional arrival date used when filtering availability.
  /// تاريخ الوصول الاختياري المستخدم في تصفية التوفر.
  final DateTime? checkInDate;

  /// Optional departure date paired with the arrival date.
  /// تاريخ المغادرة الاختياري المرتبط بتاريخ الوصول.
  final DateTime? checkOutDate;

  /// Number of guests the units must accommodate.
  /// عدد الضيوف الذين يجب أن تستوعبهم الوحدات.
  final int guestsCount;

  /// Optional unit type filter.
  /// فلتر اختياري لنوع الوحدة.
  final String? unitTypeId;

  /// Bundles the unit-loading context for the property screen.
  /// يجمع سياق تحميل الوحدات لشاشة العقار.
  const GetPropertyUnitsEvent({
    required this.propertyId,
    this.checkInDate,
    this.checkOutDate,
    required this.guestsCount,
    this.unitTypeId,
  });

  /// Keeps equality aligned with the unit-loading payload.
  /// يحافظ على ثبات المقارنة مع حمولة تحميل الوحدات.
  @override
  List<Object?> get props =>
      [propertyId, checkInDate, checkOutDate, guestsCount, unitTypeId];
}

/// Requests the review feed for a property in the detail screen.
/// يطلب موجز المراجعات الخاص بعقار ما في شاشة التفاصيل.
class GetPropertyReviewsEvent extends PropertyEvent {
  /// Property identifier whose reviews should be loaded.
  /// معرّف العقار الذي يجب تحميل مراجعاته.
  final String propertyId;

  /// Page number requested from the paginated review feed.
  /// رقم الصفحة المطلوب من موجز المراجعات المقسم.
  final int pageNumber;

  /// Number of reviews requested per page.
  /// عدد المراجعات المطلوبة في كل صفحة.
  final int pageSize;

  /// Sort field requested by the UI.
  /// حقل الترتيب المطلوب من الواجهة.
  final String? sortBy;

  /// Sort direction such as asc or desc.
  /// اتجاه الترتيب مثل تصاعدي أو تنازلي.
  final String? sortDirection;

  /// Limits the feed to reviews that contain images.
  /// يقيّد الموجز بالمراجعات التي تحتوي على صور.
  final bool withImagesOnly;

  /// Optional viewer identifier used for personalized review behavior.
  /// معرّف اختياري للمشاهد يفيد في سلوك المراجعات المخصص.
  final String? userId;

  /// Bundles the review query used by the detail screen.
  /// يجمع استعلام المراجعات المستخدم في شاشة التفاصيل.
  const GetPropertyReviewsEvent({
    required this.propertyId,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortDirection,
    this.withImagesOnly = false,
    this.userId,
  });

  /// Keeps equality aligned with the review request payload.
  /// يحافظ على ثبات المقارنة مع حمولة طلب المراجعات.
  @override
  List<Object?> get props => [
        propertyId,
        pageNumber,
        pageSize,
        sortBy,
        sortDirection,
        withImagesOnly,
        userId,
      ];
}

/// Saves a property to the user's favorites list.
/// يحفظ العقار في قائمة المفضلة الخاصة بالمستخدم.
class AddToFavoritesEvent extends PropertyEvent {
  /// Property to be saved.
  /// العقار المراد حفظه.
  final String propertyId;

  /// User performing the save action.
  /// المستخدم الذي ينفذ عملية الحفظ.
  final String userId;

  /// Optional personal note that can be used later in the favorite flow.
  /// ملاحظة شخصية اختيارية يمكن الاستفادة منها لاحقًا في مسار المفضلة.
  final String? notes;

  /// Optional date when the user hopes to visit the property.
  /// تاريخ اختياري يرغب المستخدم بزيارة العقار فيه.
  final DateTime? desiredVisitDate;

  /// Optional budget hint stored with the favorite entry.
  /// تلميح ميزانية اختياري يُحفظ مع عنصر المفضلة.
  final double? expectedBudget;

  /// Currency used for the optional budget hint.
  /// العملة المستخدمة لتلميح الميزانية الاختياري.
  final String currency;

  /// Bundles the data required to store the property in favorites.
  /// يجمع البيانات المطلوبة لحفظ العقار في المفضلة.
  const AddToFavoritesEvent({
    required this.propertyId,
    required this.userId,
    this.notes,
    this.desiredVisitDate,
    this.expectedBudget,
    this.currency = 'YER',
  });

  /// Keeps equality aligned with the favorite payload.
  /// يحافظ على ثبات المقارنة مع حمولة المفضلة.
  @override
  List<Object?> get props => [
        propertyId,
        userId,
        notes,
        desiredVisitDate,
        expectedBudget,
        currency,
      ];
}

/// Removes a property from the user's favorites list.
/// يزيل العقار من قائمة المفضلة الخاصة بالمستخدم.
class RemoveFromFavoritesEvent extends PropertyEvent {
  /// Property to be removed from favorites.
  /// العقار المراد إزالته من المفضلة.
  final String propertyId;

  /// User performing the removal action.
  /// المستخدم الذي ينفذ عملية الإزالة.
  final String userId;

  /// Bundles the data required to remove the property from favorites.
  /// يجمع البيانات المطلوبة لإزالة العقار من المفضلة.
  const RemoveFromFavoritesEvent({
    required this.propertyId,
    required this.userId,
  });

  /// Keeps equality aligned with the removal payload.
  /// يحافظ على ثبات المقارنة مع حمولة الإزالة.
  @override
  List<Object?> get props => [propertyId, userId];
}

/// حدث تحديث عدد المشاهدات
/// Describes the event definition for `UpdateViewCountEvent`.
/// العربية: يمثل تعريف الحدث `UpdateViewCountEvent`.
class UpdateViewCountEvent extends PropertyEvent {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Constructs the UpdateViewCountEvent value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UpdateViewCountEvent`.
  const UpdateViewCountEvent({required this.propertyId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [propertyId];
}

/// حدث تحديث المفضلة
/// Describes the event definition for `ToggleFavoriteEvent`.
/// العربية: يمثل تعريف الحدث `ToggleFavoriteEvent`.
class ToggleFavoriteEvent extends PropertyEvent {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the userId value available to this object.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Indicates whether `isFavorite` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isFavorite` مفعلة.
  final bool isFavorite;

  /// Constructs the ToggleFavoriteEvent value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `ToggleFavoriteEvent`.
  const ToggleFavoriteEvent({
    required this.propertyId,
    required this.userId,
    required this.isFavorite,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [propertyId, userId, isFavorite];
}

/// حدث تحديد وحدة
/// Describes the event definition for `SelectUnitEvent`.
/// العربية: يمثل تعريف الحدث `SelectUnitEvent`.
class SelectUnitEvent extends PropertyEvent {
  /// Keeps the unitId value available to this object.
  /// العربية: يخزن القيمة `unitId`.
  final String unitId;

  /// Constructs the SelectUnitEvent value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `SelectUnitEvent`.
  const SelectUnitEvent({required this.unitId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [unitId];
}

/// حدث تحديد صورة
/// Describes the event definition for `SelectImageEvent`.
/// العربية: يمثل تعريف الحدث `SelectImageEvent`.
class SelectImageEvent extends PropertyEvent {
  /// Keeps the imageIndex value available to this object.
  /// العربية: يخزن القيمة `imageIndex`.
  final int imageIndex;

  /// Constructs the SelectImageEvent value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `SelectImageEvent`.
  const SelectImageEvent({required this.imageIndex});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [imageIndex];
}

/// حدث التحقق من توفر العقار والتسعير
/// Describes the event definition for `CheckPropertyAvailabilityEvent`.
/// العربية: يمثل تعريف الحدث `CheckPropertyAvailabilityEvent`.
class CheckPropertyAvailabilityEvent extends PropertyEvent {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the checkInDate value available to this object.
  /// العربية: يخزن القيمة `checkInDate`.
  final DateTime checkInDate;

  /// Keeps the checkOutDate value available to this object.
  /// العربية: يخزن القيمة `checkOutDate`.
  final DateTime checkOutDate;

  /// Keeps the guestsCount value available to this object.
  /// العربية: يخزن القيمة `guestsCount`.
  final int guestsCount;

  /// Constructs the CheckPropertyAvailabilityEvent value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `CheckPropertyAvailabilityEvent`.
  const CheckPropertyAvailabilityEvent({
    required this.propertyId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestsCount,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props =>
      [propertyId, checkInDate, checkOutDate, guestsCount];
}
