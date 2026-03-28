import 'package:equatable/equatable.dart';
import '../../domain/entities/property_detail.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/entities/property_availability.dart';

/// Sentinel used by `copyWith` to distinguish between keeping a nullable
/// value and clearing it intentionally.
/// قيمة حارسة تميّز في `copyWith` بين الإبقاء على القيمة الاختيارية الحالية
/// ومسحها عمدًا.
class _Undefined {
  /// Creates the private sentinel used only inside this file.
  /// ينشئ قيمة الحراسة الخاصة المستخدمة داخل هذا الملف فقط.
  const _Undefined();
}

/// Base state for all property-related flows in the customer app.
/// الحالة الأساسية لكل التدفقات المرتبطة بالعقار في تطبيق العميل.
abstract class PropertyState extends Equatable {
  /// Creates the shared base for property state variants.
  /// ينشئ الأساس المشترك لأنواع حالات العقار.
  const PropertyState();

  /// Property states compare by payload so the UI only rebuilds when visible
  /// data changes.
  /// تُقارن حالات العقار بالحمولة حتى تعيد الواجهة البناء فقط عندما تتغير
  /// البيانات الظاهرة.
  @override
  List<Object?> get props => [];
}

/// Idle state before the first property request is issued.
/// حالة الخمول قبل إرسال أول طلب للعقار.
class PropertyInitial extends PropertyState {}

/// Emitted while the property snapshot is being fetched.
/// تصدر أثناء جلب لقطة العقار.
class PropertyLoading extends PropertyState {}

/// Emitted while the units list is being fetched.
/// تصدر أثناء جلب قائمة الوحدات.
class PropertyUnitsLoading extends PropertyState {}

/// Emitted while the review feed is being fetched.
/// تصدر أثناء جلب موجز المراجعات.
class PropertyReviewsLoading extends PropertyState {}

/// Holds the loaded property detail snapshot plus the current UI selections.
/// تحتفظ بلقطة تفاصيل العقار المحمّلة مع اختيارات الواجهة الحالية.
class PropertyDetailsLoaded extends PropertyState {
  /// Full property snapshot shown on the detail page.
  /// لقطة العقار الكاملة المعروضة في صفحة التفاصيل.
  final PropertyDetail property;

  /// Current favorite state for the signed-in user.
  /// حالة المفضلة الحالية للمستخدم المسجّل دخوله.
  final bool isFavorite;

  /// Index of the hero or gallery image currently selected.
  /// فهرس صورة البطل أو المعرض المحددة حاليًا.
  final int selectedImageIndex;

  /// Optional unit currently selected from the property units list.
  /// الوحدة الاختيارية المحددة حاليًا من قائمة الوحدات.
  final String? selectedUnitId;

  /// True while the favorite action is still waiting for the backend.
  /// تكون صحيحة عندما ما زال إجراء المفضلة بانتظار الخادم.
  final bool isFavoritePending;

  /// Final favorite value that should be applied when the pending request
  /// finishes.
  /// القيمة النهائية للمفضلة التي يجب تطبيقها بعد انتهاء الطلب المعلّق.
  final bool? queuedFavoriteTarget;

  /// Availability snapshot for the currently selected booking context.
  /// لقطة التوفر الخاصة بسياق الحجز المحدد حاليًا.
  final PropertyAvailability? availability;

  /// Builds the detail state emitted after a successful fetch.
  /// ينشئ حالة التفاصيل التي تصدر بعد جلب ناجح.
  const PropertyDetailsLoaded({
    required this.property,
    required this.isFavorite,
    this.selectedImageIndex = 0,
    this.selectedUnitId,
    this.isFavoritePending = false,
    this.queuedFavoriteTarget,
    this.availability,
  });

  /// Returns a new snapshot with the requested overrides applied.
  /// يعيد لقطة جديدة مع تطبيق الاستبدالات المطلوبة.
  PropertyDetailsLoaded copyWith({
    PropertyDetail? property,
    bool? isFavorite,
    int? selectedImageIndex,
    Object? selectedUnitId = const _Undefined(),
    bool? isFavoritePending,
    bool? queuedFavoriteTarget,
    PropertyAvailability? availability,
  }) {
    return PropertyDetailsLoaded(
      property: property ?? this.property,
      isFavorite: isFavorite ?? this.isFavorite,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      selectedUnitId: selectedUnitId is _Undefined
          ? this.selectedUnitId
          : selectedUnitId as String?,
      isFavoritePending: isFavoritePending ?? this.isFavoritePending,
      queuedFavoriteTarget: queuedFavoriteTarget ?? this.queuedFavoriteTarget,
      availability: availability ?? this.availability,
    );
  }

  /// Keeps equality aligned with the visible property payload.
  /// يحافظ على ثبات المقارنة مع الحمولة الظاهرة للعقار.
  @override
  List<Object?> get props => [
        property,
        isFavorite,
        selectedImageIndex,
        selectedUnitId,
        isFavoritePending,
        queuedFavoriteTarget,
        availability,
      ];
}

/// Holds the loaded units and the stay context used to fetch them.
/// تحتفظ بالوحدات المحمّلة وسياق الإقامة المستخدم في جلبها.
class PropertyUnitsLoaded extends PropertyState {
  /// Units returned for the current property.
  /// الوحدات المعادة للعقار الحالي.
  final List<Unit> units;

  /// Optional unit highlighted by the UI.
  /// الوحدة الاختيارية المبرزة في الواجهة.
  final String? selectedUnitId;

  /// Arrival date used when loading the unit list.
  /// تاريخ الوصول المستخدم عند تحميل قائمة الوحدات.
  final DateTime? checkInDate;

  /// Departure date used when loading the unit list.
  /// تاريخ المغادرة المستخدم عند تحميل قائمة الوحدات.
  final DateTime? checkOutDate;

  /// Guest count used to evaluate unit suitability.
  /// عدد الضيوف المستخدم لتقييم ملاءمة الوحدات.
  final int guestsCount;

  /// Builds the state emitted after the units are loaded.
  /// ينشئ الحالة الصادرة بعد تحميل الوحدات.
  const PropertyUnitsLoaded({
    required this.units,
    this.selectedUnitId,
    this.checkInDate,
    this.checkOutDate,
    required this.guestsCount,
  });

  /// Returns a new snapshot while keeping the booking context intact.
  /// يعيد لقطة جديدة مع الحفاظ على سياق الحجز كما هو.
  PropertyUnitsLoaded copyWith({
    List<Unit>? units,
    String? selectedUnitId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guestsCount,
  }) {
    return PropertyUnitsLoaded(
      units: units ?? this.units,
      selectedUnitId: selectedUnitId ?? this.selectedUnitId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guestsCount: guestsCount ?? this.guestsCount,
    );
  }

  /// Keeps equality aligned with the visible units and booking context.
  /// يحافظ على ثبات المقارنة مع الوحدات الظاهرة وسياق الحجز.
  @override
  List<Object?> get props => [
        units,
        selectedUnitId,
        checkInDate,
        checkOutDate,
        guestsCount,
      ];
}

/// Holds the loaded review summaries for the property screen.
/// تحتفظ بملخصات المراجعات المحمّلة لشاشة العقار.
class PropertyReviewsLoaded extends PropertyState {
  /// Review summaries shown in the property detail view.
  /// ملخصات المراجعات المعروضة في عرض تفاصيل العقار.
  final List<PropertyReview> reviews;

  /// True when the backend has no additional review pages.
  /// تكون صحيحة عندما لا توجد صفحات مراجعات إضافية في الخادم.
  final bool hasReachedMax;

  /// Current page loaded from the review feed.
  /// الصفحة الحالية المحمّلة من موجز المراجعات.
  final int currentPage;

  /// Builds the review state emitted after a successful fetch.
  /// ينشئ حالة المراجعات التي تصدر بعد جلب ناجح.
  const PropertyReviewsLoaded({
    required this.reviews,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  /// Returns a new review snapshot with the requested overrides.
  /// يعيد لقطة مراجعات جديدة مع تطبيق الاستبدالات المطلوبة.
  PropertyReviewsLoaded copyWith({
    List<PropertyReview>? reviews,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return PropertyReviewsLoaded(
      reviews: reviews ?? this.reviews,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  /// Keeps equality aligned with the current review feed.
  /// يحافظ على ثبات المقارنة مع موجز المراجعات الحالي.
  @override
  List<Object?> get props => [reviews, hasReachedMax, currentPage];
}

/// Holds the outcome of a favorite add or remove action.
/// تحتفظ بنتيجة عملية إضافة أو إزالة المفضلة.
class PropertyFavoriteUpdated extends PropertyState {
  /// Final favorite value after the backend response.
  /// القيمة النهائية للمفضلة بعد رد الخادم.
  final bool isFavorite;

  /// User-facing message explaining the result.
  /// رسالة موجهة للمستخدم تشرح النتيجة.
  final String message;

  /// Builds the favorite result state emitted after success.
  /// ينشئ حالة نتيجة المفضلة التي تصدر بعد النجاح.
  const PropertyFavoriteUpdated({
    required this.isFavorite,
    required this.message,
  });

  /// Keeps equality aligned with the favorite result payload.
  /// يحافظ على ثبات المقارنة مع حمولة نتيجة المفضلة.
  @override
  List<Object?> get props => [isFavorite, message];
}

/// Holds a failure message for property-related flows.
/// تحتفظ برسالة فشل خاصة بتدفقات العقار.
class PropertyError extends PropertyState {
  /// User-facing explanation of the error.
  /// شرح موجّه للمستخدم لسبب الخطأ.
  final String message;

  /// Builds the generic failure state for property flows.
  /// ينشئ حالة الفشل العامة لتدفقات العقار.
  const PropertyError({required this.message});

  /// Keeps equality aligned with the error message.
  /// يحافظ على ثبات المقارنة مع رسالة الخطأ.
  @override
  List<Object?> get props => [message];
}

/// Combines the property snapshot with related units, reviews, and UI
/// selection state.
/// يجمع لقطة العقار مع الوحدات والمراجعات وحالة الاختيارات في الواجهة.
class PropertyWithDetails extends PropertyState {
  /// Full property snapshot shown in the screen.
  /// لقطة العقار الكاملة المعروضة في الشاشة.
  final PropertyDetail property;

  /// Units displayed with the property details.
  /// الوحدات المعروضة مع تفاصيل العقار.
  final List<Unit> units;

  /// Review summaries displayed alongside the property.
  /// ملخصات المراجعات المعروضة بجانب العقار.
  final List<PropertyReview> reviews;

  /// Current favorite state for the signed-in user.
  /// حالة المفضلة الحالية للمستخدم المسجّل دخوله.
  final bool isFavorite;

  /// Currently selected gallery image.
  /// صورة المعرض المحددة حاليًا.
  final int selectedImageIndex;

  /// Optional unit currently highlighted by the UI.
  /// الوحدة الاختيارية المبرزة حاليًا في الواجهة.
  final String? selectedUnitId;

  /// True while the favorite mutation is still pending.
  /// تكون صحيحة عندما يكون تعديل المفضلة ما زال قيد التنفيذ.
  final bool isFavoritePending;

  /// Final favorite target that should be applied after the pending action.
  /// القيمة النهائية للمفضلة التي يجب تطبيقها بعد انتهاء الإجراء المعلّق.
  final bool? queuedFavoriteTarget;

  /// Availability snapshot for the selected booking context.
  /// لقطة التوفر الخاصة بسياق الحجز المحدد.
  final PropertyAvailability? availability;

  /// Builds the combined state used by property detail screens.
  /// ينشئ الحالة المجمعة المستخدمة في شاشات تفاصيل العقار.
  const PropertyWithDetails({
    required this.property,
    required this.units,
    required this.reviews,
    required this.isFavorite,
    this.selectedImageIndex = 0,
    this.selectedUnitId,
    this.isFavoritePending = false,
    this.queuedFavoriteTarget,
    this.availability,
  });

  /// Returns a new combined snapshot with the requested overrides applied.
  /// يعيد لقطة مجمعة جديدة مع تطبيق الاستبدالات المطلوبة.
  PropertyWithDetails copyWith({
    PropertyDetail? property,
    List<Unit>? units,
    List<PropertyReview>? reviews,
    bool? isFavorite,
    int? selectedImageIndex,
    Object? selectedUnitId = const _Undefined(),
    bool? isFavoritePending,
    bool? queuedFavoriteTarget,
    PropertyAvailability? availability,
  }) {
    return PropertyWithDetails(
      property: property ?? this.property,
      units: units ?? this.units,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      selectedUnitId: selectedUnitId is _Undefined
          ? this.selectedUnitId
          : selectedUnitId as String?,
      isFavoritePending: isFavoritePending ?? this.isFavoritePending,
      queuedFavoriteTarget: queuedFavoriteTarget ?? this.queuedFavoriteTarget,
      availability: availability ?? this.availability,
    );
  }

  /// Keeps equality aligned with the full combined payload.
  /// يحافظ على ثبات المقارنة مع الحمولة المجمعة الكاملة.
  @override
  List<Object?> get props => [
        property,
        units,
        reviews,
        isFavorite,
        selectedImageIndex,
        selectedUnitId,
        isFavoritePending,
        queuedFavoriteTarget,
        availability,
      ];
}
