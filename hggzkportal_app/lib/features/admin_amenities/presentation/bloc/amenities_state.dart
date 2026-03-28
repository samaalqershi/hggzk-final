import 'package:equatable/equatable.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/amenity.dart';

/// Base state for amenity list loading and one-off amenity operations.
/// الحالة الأساسية لتحميل قائمة المرافق والعمليات الفردية عليها.
abstract class AmenitiesState extends Equatable {
  /// Creates the shared state base used by all amenity states.
  /// ينشئ أساس الحالة المشترك المستخدم لجميع حالات المرافق.
  const AmenitiesState();

  @override

  /// Comparison keys shared by all amenity states.
  /// مفاتيح المقارنة المشتركة لجميع حالات المرافق.
  List<Object?> get props => [];
}

/// Default state before any amenity data has been requested.
/// الحالة الافتراضية قبل طلب أي بيانات للمرافق.
class AmenitiesInitial extends AmenitiesState {}

/// State emitted while amenity data is being fetched.
/// الحالة الصادرة أثناء جلب بيانات المرافق.
class AmenitiesLoading extends AmenitiesState {
  /// Optional loading message for the UI.
  /// رسالة تحميل اختيارية للواجهة.
  final String? message;

  /// Creates a loading state with an optional description.
  /// ينشئ حالة تحميل مع وصف اختياري.
  const AmenitiesLoading({this.message});

  @override

  /// Comparison key for the optional loading message.
  /// مفتاح المقارنة لرسالة التحميل الاختيارية.
  List<Object?> get props => [message];
}

/// State that carries the loaded amenity list and any related UI context.
/// حالة تحمل قائمة المرافق المحمّلة وأي سياق واجهة مرتبط بها.
class AmenitiesLoaded extends AmenitiesState {
  /// The paginated amenity data currently shown on screen.
  /// بيانات المرافق المصفّحة المعروضة حاليًا على الشاشة.
  final PaginatedResult<Amenity> amenities;

  /// The currently selected amenity, if any.
  /// المرفق المحدد حاليًا إن وجد.
  final Amenity? selectedAmenity;

  /// The active search term used to fetch the list.
  /// نص البحث النشط المستخدم لجلب القائمة.
  final String? searchTerm;

  /// The active assigned-only filter.
  /// فلتر المرافق المعيّنة النشط.
  final bool? isAssigned;

  /// The active free-only filter.
  /// فلتر المرافق المجانية النشط.
  final bool? isFree;

  /// The property type scope used for the current list, if any.
  /// نطاق نوع العقار المستخدم للقائمة الحالية إن وجد.
  final String? propertyTypeId;

  /// Popular amenities fetched alongside the main list.
  /// المرافق الشائعة التي جُلبت بجانب القائمة الرئيسية.
  final List<Amenity> popularAmenities;

  /// Amenity statistics used by summary widgets and counters.
  /// إحصائيات المرافق المستخدمة في الملخصات والعدادات.
  final AmenityStats? stats;

  /// Creates a loaded state with list data and optional UI context.
  /// ينشئ حالة تحميل تتضمن بيانات القائمة وسياق واجهة اختياريًا.
  const AmenitiesLoaded({
    required this.amenities,
    this.selectedAmenity,
    this.searchTerm,
    this.isAssigned,
    this.isFree,
    this.propertyTypeId,
    this.popularAmenities = const [],
    this.stats,
  });

  /// Produces a new loaded state while preserving unchanged values.
  /// ينتج حالة تحميل جديدة مع الاحتفاظ بالقيم غير المتغيرة.
  AmenitiesLoaded copyWith({
    PaginatedResult<Amenity>? amenities,
    Amenity? selectedAmenity,
    bool clearSelectedAmenity = false,
    String? searchTerm,
    bool? isAssigned,
    bool? isFree,
    String? propertyTypeId,
    List<Amenity>? popularAmenities,
    AmenityStats? stats,
  }) {
    return AmenitiesLoaded(
      amenities: amenities ?? this.amenities,
      selectedAmenity:
          clearSelectedAmenity ? null : selectedAmenity ?? this.selectedAmenity,
      searchTerm: searchTerm ?? this.searchTerm,
      isAssigned: isAssigned ?? this.isAssigned,
      isFree: isFree ?? this.isFree,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      popularAmenities: popularAmenities ?? this.popularAmenities,
      stats: stats ?? this.stats,
    );
  }

  @override

  /// Comparison keys that represent the current amenity list view.
  /// مفاتيح المقارنة التي تمثل عرض قائمة المرافق الحالي.
  List<Object?> get props => [
        amenities,
        selectedAmenity,
        searchTerm,
        isAssigned,
        isFree,
        propertyTypeId,
        popularAmenities,
        stats,
      ];
}

/// State emitted when amenity loading or processing fails.
/// الحالة الصادرة عندما يفشل تحميل المرافق أو معالجتها.
class AmenitiesError extends AmenitiesState {
  /// The error message that should be shown to the user.
  /// رسالة الخطأ التي ينبغي عرضها للمستخدم.
  final String message;

  /// Creates an error state with a readable message.
  /// ينشئ حالة خطأ مع رسالة قابلة للقراءة.
  const AmenitiesError({required this.message});

  @override

  /// Comparison key for the visible error message.
  /// مفتاح المقارنة لرسالة الخطأ الظاهرة.
  List<Object> get props => [message];
}

/// State used while a single amenity operation is running.
/// حالة تُستخدم أثناء تنفيذ عملية واحدة على مرفق.
class AmenityOperationInProgress extends AmenitiesState {
  /// The symbolic operation name such as create, update, delete, or assign.
  /// الاسم الرمزي للعملية مثل create أو update أو delete أو assign.
  final String operation;

  /// The amenity identifier affected by the operation, when available.
  /// معرّف المرفق المتأثر بالعملية عند توفره.
  final String? amenityId;

  /// Creates a progress state for a specific amenity operation.
  /// ينشئ حالة تقدم لعملية محددة على مرفق.
  const AmenityOperationInProgress({
    required this.operation,
    this.amenityId,
  });

  @override

  /// Comparison keys for the running operation and optional amenity target.
  /// مفاتيح المقارنة للعملية الجارية ومعرّف المرفق الاختياري.
  List<Object?> get props => [operation, amenityId];
}

/// State emitted when a single amenity operation finishes successfully.
/// الحالة الصادرة عند انتهاء عملية على مرفق بنجاح.
class AmenityOperationSuccess extends AmenitiesState {
  /// The success message to show in the UI.
  /// رسالة النجاح التي تعرض في الواجهة.
  final String message;

  /// The amenity identifier affected by the completed operation, if any.
  /// معرّف المرفق المتأثر بالعملية المنجزة إن وجد.
  final String? amenityId;

  /// Creates a success state for a completed amenity operation.
  /// ينشئ حالة نجاح لعملية مرافق منجزة.
  const AmenityOperationSuccess({
    required this.message,
    this.amenityId,
  });

  @override

  /// Comparison keys for the success message and optional amenity target.
  /// مفاتيح المقارنة لرسالة النجاح ومعرّف المرفق الاختياري.
  List<Object?> get props => [message, amenityId];
}

/// State emitted when a single amenity operation fails.
/// الحالة الصادرة عند فشل عملية على مرفق.
class AmenityOperationFailure extends AmenitiesState {
  /// The failure message that explains what went wrong.
  /// رسالة الفشل التي تشرح ما الذي حدث خطأً.
  final String message;

  /// The amenity identifier affected by the failed operation, if any.
  /// معرّف المرفق المتأثر بالعملية الفاشلة إن وجد.
  final String? amenityId;

  /// Creates a failure state for an amenity operation.
  /// ينشئ حالة فشل لعملية على المرافق.
  const AmenityOperationFailure({
    required this.message,
    this.amenityId,
  });

  @override

  /// Comparison keys for the failure message and optional amenity target.
  /// مفاتيح المقارنة لرسالة الفشل ومعرّف المرفق الاختياري.
  List<Object?> get props => [message, amenityId];
}
