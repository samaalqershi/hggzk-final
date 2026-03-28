import 'package:equatable/equatable.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/review_image.dart';

/// Base state for review flows. The bloc uses specialized states to expose
/// loading, pagination, creation, upload progress, and any failures that the
/// review UI needs to react to.
/// الحالة الأساسية لمسارات المراجعات. يستخدم الـ bloc حالات متخصصة لعرض
/// التحميل والترقيم والإنشاء وتقدم الرفع وأي حالات فشل تحتاجها الواجهة.
abstract class ReviewState extends Equatable {
  /// Builds the shared base for every review state variant.
  /// ينشئ الأساس المشترك لكل حالات المراجعات.
  const ReviewState();

  /// Review states are compared by payload so list refreshes and mutations stay
  /// predictable.
  /// تُقارن حالات المراجعات بحسب الحمولة حتى تبقى عمليات التحديث والتعديل
  /// متوقعة.
  @override
  List<Object?> get props => [];
}

/// Idle state before the first review request has been issued.
/// حالة الخمول قبل إرسال أول طلب للمراجعات.
class ReviewInitial extends ReviewState {}

/// Emitted while review data is being fetched.
/// تصدر أثناء جلب بيانات المراجعات.
class ReviewLoading extends ReviewState {}

/// Indicates that the feed is loading the next page while preserving the
/// current list on screen.
/// تشير إلى أن الموجز يجلب الصفحة التالية مع الإبقاء على القائمة الحالية
/// مرئية.
class ReviewLoadingMore extends ReviewState {
  /// Reviews already visible while pagination is running.
  /// المراجعات الظاهرة بالفعل أثناء عمل الترقيم.
  final List<Review> currentReviews;

  /// Builds the loading-more state for pagination flows.
  /// ينشئ حالة تحميل المزيد لمسارات الترقيم.
  const ReviewLoadingMore({required this.currentReviews});

  /// Pagination states are compared by the currently visible reviews.
  /// تُقارن حالات الترقيم بالمراجعات الظاهرة حاليًا.
  @override
  List<Object?> get props => [currentReviews];
}

/// Holds the fetched review page and the pagination boundary state.
/// تحتفظ بصفحة المراجعات المحملة وحالة حد الترقيم.
class ReviewsLoaded extends ReviewState {
  /// Paginated reviews currently visible.
  /// المراجعات المرقمة الظاهرة حاليًا.
  final PaginatedResult<Review> reviews;

  /// True when the backend has no more pages to return.
  /// تكون صحيحة عندما لا يبقى لدى الخادم صفحات إضافية.
  final bool hasReachedMax;

  /// Builds the loaded review state.
  /// ينشئ حالة المراجعات المحملة.
  const ReviewsLoaded({
    required this.reviews,
    this.hasReachedMax = false,
  });

  /// Exposes a new review snapshot while preserving unchanged values.
  /// يعيد لقطة جديدة للمراجعات مع الإبقاء على القيم غير المتغيرة.
  ReviewsLoaded copyWith({
    PaginatedResult<Review>? reviews,
    bool? hasReachedMax,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  /// Loaded states are compared by the current page and boundary flag.
  /// تُقارن الحالات المحملة بالصفحة الحالية وعلم الحدود.
  @override
  List<Object?> get props => [reviews, hasReachedMax];
}

/// Holds the aggregated rating summary for one property.
/// تحتفظ بالملخص التجميعي للتقييمات الخاصة بعقار واحد.
class ReviewsSummaryLoaded extends ReviewState {
  /// Aggregated review summary returned by the repository.
  /// ملخص المراجعات التجميعي المعاد من المستودع.
  final ReviewsSummary summary;

  /// Builds the summary state.
  /// ينشئ حالة الملخص.
  const ReviewsSummaryLoaded({required this.summary});

  /// Summary states are compared by the aggregate payload.
  /// تُقارن حالات الملخص بالحمولة التجميعية.
  @override
  List<Object?> get props => [summary];
}

/// Emitted when a new review has been created successfully.
/// تصدر عندما تُنشأ مراجعة جديدة بنجاح.
class ReviewCreated extends ReviewState {
  /// Review returned by the backend after creation.
  /// المراجعة التي يعيدها الخادم بعد الإنشاء.
  final Review review;

  /// Builds the success state for a new review.
  /// ينشئ حالة النجاح لمراجعة جديدة.
  const ReviewCreated({required this.review});

  /// Creation states are compared by the resulting review.
  /// تُقارن حالات الإنشاء بالمراجعة الناتجة.
  @override
  List<Object?> get props => [review];
}

/// Indicates that the create-review request is still in flight.
/// تشير إلى أن طلب إنشاء المراجعة ما زال قيد التنفيذ.
class ReviewCreating extends ReviewState {}

/// Holds the server-side image references after a successful upload.
/// تحتفظ بمراجع الصور على الخادم بعد نجاح الرفع.
class ReviewImagesUploaded extends ReviewState {
  /// Uploaded review images with their metadata.
  /// صور المراجعة المرفوعة مع بياناتها الوصفية.
  final List<ReviewImage> images;

  /// Builds the image-upload success state.
  /// ينشئ حالة نجاح رفع الصور.
  const ReviewImagesUploaded({required this.images});

  /// Upload results are compared by the returned image list.
  /// تُقارن نتائج الرفع بقائمة الصور المعادة.
  @override
  List<Object?> get props => [images];
}

/// Indicates that review images are currently being uploaded.
/// تشير إلى أن صور المراجعة تُرفع الآن.
class ReviewImagesUploading extends ReviewState {
  /// Upload progress between `0.0` and `1.0`.
  /// تقدم الرفع بين `0.0` و `1.0`.
  final double progress;

  /// Builds the in-flight upload state.
  /// ينشئ حالة الرفع الجارية.
  const ReviewImagesUploading({this.progress = 0.0});

  /// Upload progress states are compared by the numeric progress value.
  /// تُقارن حالات تقدم الرفع بالقيمة الرقمية للتقدم.
  @override
  List<Object?> get props => [progress];
}

/// Indicates that review fetching or mutation failed.
/// تشير إلى فشل جلب المراجعات أو تعديلها.
class ReviewError extends ReviewState {
  /// User-facing error message for the review flow.
  /// رسالة خطأ موجهة للمستخدم في مسار المراجعات.
  final String message;

  /// Builds the generic review failure state.
  /// ينشئ حالة الفشل العامة للمراجعات.
  const ReviewError({required this.message});

  /// Error states are compared by message so identical failures remain stable.
  /// تُقارن حالات الخطأ بالرسالة حتى تبقى الأخطاء المتطابقة مستقرة.
  @override
  List<Object?> get props => [message];
}

/// Indicates that creating the review failed because of validation or backend
/// rejection.
/// تشير إلى أن إنشاء المراجعة فشل بسبب التحقق أو رفض الخادم.
class ReviewCreateError extends ReviewState {
  /// User-facing explanation for the create failure.
  /// شرح موجّه للمستخدم لسبب فشل الإنشاء.
  final String message;

  /// Field-level validation errors returned by the backend.
  /// أخطاء التحقق على مستوى الحقول المعادة من الخادم.
  final Map<String, List<String>>? errors;

  /// Builds the create-review failure state.
  /// ينشئ حالة فشل إنشاء المراجعة.
  const ReviewCreateError({
    required this.message,
    this.errors,
  });

  /// Create errors are compared by the message and validation map.
  /// تُقارن أخطاء الإنشاء بالرسالة وخريطة التحقق.
  @override
  List<Object?> get props => [message, errors];
}

/// Indicates that an existing review is being edited.
/// تشير إلى أن مراجعة موجودة قيد التعديل.
class ReviewUpdating extends ReviewState {
  /// Review currently being edited.
  /// المراجعة التي يتم تعديلها الآن.
  final String reviewId;

  /// Builds the update-in-progress state.
  /// ينشئ حالة التحديث الجاري.
  const ReviewUpdating({required this.reviewId});

  /// Update states are compared by the review being edited.
  /// تُقارن حالات التحديث بالمراجعة التي تُعدّل.
  @override
  List<Object?> get props => [reviewId];
}

/// Emitted when an existing review has been updated successfully.
/// تصدر عندما تُحدّث مراجعة موجودة بنجاح.
class ReviewUpdated extends ReviewState {
  /// Updated review returned by the backend.
  /// المراجعة المحدّثة المعادة من الخادم.
  final Review review;

  /// Builds the review-update success state.
  /// ينشئ حالة نجاح تحديث المراجعة.
  const ReviewUpdated({required this.review});

  /// Updated states are compared by the resulting review.
  /// تُقارن حالات التحديث بالمراجعة الناتجة.
  @override
  List<Object?> get props => [review];
}
