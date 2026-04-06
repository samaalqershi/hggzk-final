import 'package:equatable/equatable.dart';

/// Base event for review flows. Concrete events create reviews, fetch review
/// pages, apply filters, like/unlike reviews, and upload review images.
/// الحدث الأساسي لمسارات المراجعات. الأحداث المشتقة تنشئ المراجعات أو تجلب
/// صفحاتها أو تطبق الفلاتر أو تضيف الإعجابات أو ترفع صور المراجعة.
abstract class ReviewEvent extends Equatable {
  /// Builds the shared base for every review event.
  /// ينشئ الأساس المشترك لكل أحداث المراجعات.
  const ReviewEvent();

  /// Review events are compared by payload so pagination and mutations stay
  /// deterministic.
  /// تُقارن أحداث المراجعات بحسب الحمولة حتى تبقى الترقيمات والتعديلات
  /// حتمية.
  @override
  List<Object?> get props => [];
}

/// Submits a new property review together with its rating breakdown and
/// optional images.
/// يرسل مراجعة جديدة لعقار مع توزيع التقييم والصور الاختيارية.
class CreateReviewEvent extends ReviewEvent {
  /// Booking that anchors the review.
  /// الحجز الذي ترتكز عليه المراجعة.
  final String bookingId;

  /// Property being reviewed.
  /// العقار الذي تتم مراجعته.
  final String propertyId;

  /// Cleanliness score submitted by the guest.
  /// درجة النظافة التي يرسلها الضيف.
  final int cleanliness;

  /// Service score submitted by the guest.
  /// درجة الخدمة التي يرسلها الضيف.
  final int service;

  /// Location score submitted by the guest.
  /// درجة الموقع التي يرسلها الضيف.
  final int location;

  /// Value-for-money score submitted by the guest.
  /// درجة القيمة مقابل المال التي يرسلها الضيف.
  final int value;

  /// Free-form review text.
  /// نص المراجعة الحر.
  final String comment;

  /// Optional image payload encoded for upload.
  /// حمولة الصور الاختيارية المشفرة للرفع.
  final List<String>? imagesBase64;

  /// Optional review video encoded for upload.
  /// فيديو مراجعة اختياري مشفر للرفع.
  final String? videoBase64;

  /// Optional poster image for the attached review video.
  /// صورة مصغرة اختيارية للفيديو المرفق بالمراجعة.
  final String? videoThumbnailBase64;

  /// Builds the review-submission request.
  /// ينشئ طلب إرسال المراجعة.
  const CreateReviewEvent({
    required this.bookingId,
    required this.propertyId,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.value,
    required this.comment,
    this.imagesBase64,
    this.videoBase64,
    this.videoThumbnailBase64,
  });

  /// Review creation is compared by booking, property, ratings, text, and
  /// images.
  /// تُقارن عملية إنشاء المراجعة بالحجز والعقار والتقييمات والنص والصور.
  @override
  List<Object?> get props => [
        bookingId,
        propertyId,
        cleanliness,
        service,
        location,
        value,
        comment,
        imagesBase64,
        videoBase64,
        videoThumbnailBase64,
      ];
}

/// Loads a paginated review feed for one property with optional sorting and
/// filtering.
/// يحمل موجز مراجعات مرقمًا لعقار واحد مع إمكانية الفرز والتصفية الاختياريين.
class GetPropertyReviewsEvent extends ReviewEvent {
  /// Property whose reviews should be loaded.
  /// العقار الذي يجب تحميل مراجعاته.
  final String propertyId;

  /// Requested page number.
  /// رقم الصفحة المطلوب.
  final int pageNumber;

  /// Number of reviews requested per page.
  /// عدد المراجعات المطلوبة في كل صفحة.
  final int pageSize;

  /// Optional rating filter.
  /// فلتر تقييم اختياري.
  final int? rating;

  /// Sort field requested by the UI.
  /// حقل الترتيب المطلوب من الواجهة.
  final String? sortBy;

  /// Sort direction such as asc or desc.
  /// اتجاه الترتيب مثل تصاعدي أو تنازلي.
  final String? sortDirection;

  /// True when only reviews with attached images should be returned.
  /// تكون صحيحة عندما يجب إعادة المراجعات التي تحتوي على صور فقط.
  final bool? withImagesOnly;

  /// Optional user id used when a profile screen asks for its own reviews.
  /// معرّف مستخدم اختياري يستخدم عندما تطلب شاشة الملف الشخصي مراجعاتها.
  final String? userId;

  /// Builds the property-review fetch request.
  /// ينشئ طلب جلب مراجعات العقار.
  const GetPropertyReviewsEvent({
    required this.propertyId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.rating,
    this.sortBy,
    this.sortDirection,
    this.withImagesOnly,
    this.userId,
  });

  /// Fetch requests are compared by property and the full filter payload.
  /// تُقارن طلبات الجلب بالعقار وبحمولة الفلاتر كاملة.
  @override
  List<Object?> get props => [
        propertyId,
        pageNumber,
        pageSize,
        rating,
        sortBy,
        sortDirection,
        withImagesOnly,
        userId,
      ];
}

/// Loads the next page of reviews while keeping the current list visible.
/// يحمل الصفحة التالية من المراجعات مع إبقاء القائمة الحالية مرئية.
class LoadMoreReviewsEvent extends ReviewEvent {
  /// Builds the pagination request for more reviews.
  /// ينشئ طلب الترقيم لمزيد من المراجعات.
  const LoadMoreReviewsEvent();
}

/// Loads the aggregated review summary for one property.
/// يحمل الملخص التجميعي لمراجعات عقار واحد.
class GetPropertyReviewsSummaryEvent extends ReviewEvent {
  /// Property whose summary should be loaded.
  /// العقار الذي يجب تحميل ملخصه.
  final String propertyId;

  /// Builds the summary-fetch request.
  /// ينشئ طلب جلب الملخص.
  const GetPropertyReviewsSummaryEvent({required this.propertyId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [propertyId];
}

/// Uploads the images attached to a review and returns their server-side
/// references.
/// يرفع الصور المرفقة بالمراجعة ويعيد مراجعها على الخادم.
class UploadReviewImagesEvent extends ReviewEvent {
  /// Review whose images should be uploaded.
  /// المراجعة التي يجب رفع صورها.
  final String reviewId;

  /// Image payload already encoded for upload.
  /// حمولة الصور المشفرة مسبقًا للرفع.
  final List<String> imagesBase64;

  /// Builds the image-upload request for one review.
  /// ينشئ طلب رفع الصور لمراجعة واحدة.
  const UploadReviewImagesEvent({
    required this.reviewId,
    required this.imagesBase64,
  });

  /// Upload requests are compared by review and image payload.
  /// تُقارن طلبات الرفع بالمراجعة وبحمولة الصور.
  @override
  List<Object?> get props => [reviewId, imagesBase64];
}

/// Applies a local filter to the review feed without refetching the whole
/// summary block.
/// يطبق فلترًا محليًا على موجز المراجعات دون إعادة جلب الملخص بالكامل.
class FilterReviewsEvent extends ReviewEvent {
  /// Filter by exact rating when provided.
  /// التصفية بحسب تقييم محدد عند توفره.
  final int? rating;

  /// Limits the feed to reviews that include photos.
  /// يقتصر على المراجعات التي تتضمن صورًا.
  final bool? withImagesOnly;

  /// Sort field requested by the UI.
  /// حقل الترتيب المطلوب من الواجهة.
  final String? sortBy;

  /// Direction for the selected sort field.
  /// اتجاه حقل الترتيب المختار.
  final String? sortDirection;

  /// Builds the review-filter request.
  /// ينشئ طلب فلترة المراجعات.
  const FilterReviewsEvent({
    this.rating,
    this.withImagesOnly,
    this.sortBy,
    this.sortDirection,
  });

  /// Filters are compared by the exact criteria applied to the feed.
  /// تُقارن الفلاتر بحسب المعايير الدقيقة المطبقة على الموجز.
  @override
  List<Object?> get props => [rating, withImagesOnly, sortBy, sortDirection];
}

/// Reloads the review feed after a mutation or a manual refresh gesture.
/// يعيد تحميل موجز المراجعات بعد تعديل أو بعد إيماءة تحديث يدوية.
class RefreshReviewsEvent extends ReviewEvent {
  /// Property whose review feed should be refreshed.
  /// العقار الذي يجب تحديث موجز مراجعاته.
  final String propertyId;

  /// Builds the refresh request.
  /// ينشئ طلب التحديث.
  const RefreshReviewsEvent({required this.propertyId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [propertyId];
}

/// Adds a like reaction to one review.
/// يضيف إشارة إعجاب إلى مراجعة واحدة.
class LikeReviewEvent extends ReviewEvent {
  /// Review receiving the like.
  /// المراجعة التي تستقبل الإعجاب.
  final String reviewId;

  /// Builds the like request.
  /// ينشئ طلب الإعجاب.
  const LikeReviewEvent({required this.reviewId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [reviewId];
}

/// Removes a like reaction from one review.
/// يزيل إشارة الإعجاب من مراجعة واحدة.
class UnlikeReviewEvent extends ReviewEvent {
  /// Review whose like should be removed.
  /// المراجعة التي يجب إلغاء الإعجاب عنها.
  final String reviewId;

  /// Builds the unlike request.
  /// ينشئ طلب إلغاء الإعجاب.
  const UnlikeReviewEvent({required this.reviewId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [reviewId];
}
