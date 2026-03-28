import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/property_detail.dart';
import '../entities/unit.dart' as entity;
import '../entities/property_availability.dart';

/// Defines the contract that powers the property detail, booking, and review
/// flows for the customer app.
/// يعرّف العقد الذي يربط مسارات تفاصيل العقار والحجز والمراجعات داخل تطبيق
/// العميل.
abstract class PropertyRepository {
  /// Fetches the complete property payload used by the detail screen.
  /// يجلب الحمولة الكاملة للعقار التي تعتمد عليها شاشة التفاصيل.
  Future<Either<Failure, PropertyDetail>> getPropertyDetails({
    required String propertyId,
    String? userId,
    String? userRole,
  });

  /// Returns the units that match the property and current booking context.
  /// يعيد الوحدات المطابقة للعقار ولسياق الحجز الحالي.
  Future<Either<Failure, List<entity.Unit>>> getPropertyUnits({
    required String propertyId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    required int guestsCount,
  });

  /// Evaluates whether the property can be booked for the supplied stay window.
  /// يقيّم ما إذا كان يمكن حجز العقار ضمن نافذة الإقامة المحددة.
  Future<Either<Failure, PropertyAvailability>> checkPropertyAvailability({
    required String propertyId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestsCount,
  });

  /// Loads the reviews that should appear on the property detail screen.
  /// يحمل المراجعات التي يجب أن تظهر في شاشة تفاصيل العقار.
  Future<Either<Failure, List<PropertyReview>>> getPropertyReviews({
    required String propertyId,
    int pageNumber = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
    bool withImagesOnly = false,
    String? userId,
  });

  /// Saves the property for the signed-in user and keeps optional context
  /// that can help later personalization.
  /// يحفظ العقار لدى المستخدم الحالي مع الاحتفاظ بسياق اختياري يفيد
  /// التخصيص لاحقًا.
  Future<Either<Failure, bool>> addToFavorites({
    required String propertyId,
    required String userId,
    String? notes,
    DateTime? desiredVisitDate,
    double? expectedBudget,
    String currency = 'YER',
  });

  /// Removes a previously saved property from the user's favorites list.
  /// يزيل عقارًا محفوظًا سابقًا من قائمة المفضلة لدى المستخدم.
  Future<Either<Failure, bool>> removeFromFavorites({
    required String propertyId,
    required String userId,
  });

  /// Increments or refreshes the backend view counter for the property.
  /// يحدّث أو يزيد عداد المشاهدات الخاص بالعقار في الخادم.
  Future<Either<Failure, bool>> updateViewCount({
    required String propertyId,
  });
}

/// Review summary used by the property detail feature to show guest feedback.
/// ملخص مراجعة يستخدمه قسم تفاصيل العقار لعرض آراء الضيوف.
class PropertyReview extends Equatable {
  /// Backend identifier for the review entry.
  /// المعرّف الخلفي لعنصر المراجعة.
  final String id;

  /// Booking that produced the review.
  /// الحجز الذي أنتج هذه المراجعة.
  final String bookingId;

  /// Property name shown alongside the review.
  /// اسم العقار المعروض بجانب المراجعة.
  final String propertyName;

  /// Guest display name.
  /// اسم عرض الضيف.
  final String userName;

  /// Cleanliness score used in the combined rating.
  /// درجة النظافة المستخدمة ضمن التقييم المجمّع.
  final int cleanliness;

  /// Service score used in the combined rating.
  /// درجة الخدمة المستخدمة ضمن التقييم المجمّع.
  final int service;

  /// Location score used in the combined rating.
  /// درجة الموقع المستخدمة ضمن التقييم المجمّع.
  final int location;

  /// Value-for-money score used in the combined rating.
  /// درجة القيمة مقابل المال المستخدمة ضمن التقييم المجمّع.
  final int value;

  /// Aggregate rating that is safe to render without recalculation.
  /// التقييم المجمّع الجاهز للعرض دون إعادة حساب.
  final double averageRating;

  /// Review comment shown in the detail sheet or cards.
  /// نص المراجعة الظاهر في صفحة التفاصيل أو البطاقات.
  final String comment;

  /// Optional response from the property team.
  /// رد اختياري من فريق العقار.
  final String? responseText;

  /// Time when the response was published.
  /// وقت نشر الرد.
  final DateTime? responseDate;

  /// Time when the review was submitted.
  /// وقت إرسال المراجعة.
  final DateTime createdAt;

  /// Supporting images attached to the review.
  /// الصور الداعمة المرفقة بالمراجعة.
  final List<ReviewImage> images;

  /// Marks reviews written by the currently signed-in user.
  /// يميز المراجعات المكتوبة من المستخدم الحالي.
  final bool isUserReview;

  /// Shows reviews that are still waiting for moderation.
  /// يوضح المراجعات التي ما زالت بانتظار المراجعة.
  final bool isPendingApproval;

  /// Hides reviews that the backend has deactivated.
  /// يحدد المراجعات التي عطّلها الخادم.
  final bool isDisabled;

  /// Builds an immutable review summary for the property feature.
  /// ينشئ ملخص مراجعة ثابتًا لميزة العقار.
  const PropertyReview({
    required this.id,
    required this.bookingId,
    required this.propertyName,
    required this.userName,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.value,
    required this.averageRating,
    required this.comment,
    this.responseText,
    this.responseDate,
    required this.createdAt,
    required this.images,
    this.isUserReview = false,
    this.isPendingApproval = false,
    this.isDisabled = false,
  });

  /// Keeps equality aligned with the review content and moderation flags.
  /// يحافظ على ثبات المقارنة مع محتوى المراجعة وحالاتها الإدارية.
  @override
  List<Object?> get props => [
        id,
        bookingId,
        propertyName,
        userName,
        cleanliness,
        service,
        location,
        value,
        averageRating,
        comment,
        responseText,
        responseDate,
        createdAt,
        images,
        isUserReview,
        isPendingApproval,
        isDisabled,
      ];
}

/// Represents an image attached to a property review.
/// يمثل صورة مرفقة بمراجعة العقار.
class ReviewImage extends Equatable {
  /// Backend identifier of the review image.
  /// المعرّف الخلفي لصورة المراجعة.
  final String id;

  /// Links the image to the review that owns it.
  /// يربط الصورة بالمراجعة التي تنتمي إليها.
  final String reviewId;

  /// Original file name reported by the backend.
  /// اسم الملف الأصلي الذي يعيده الخادم.
  final String name;

  /// Public image URL consumed by the UI.
  /// رابط الصورة العام الذي تستهلكه الواجهة.
  final String url;

  /// File size used for diagnostics and upload checks.
  /// حجم الملف المستخدم في التشخيص وفحوص الرفع.
  final int sizeBytes;

  /// Media type reported by storage or upload APIs.
  /// نوع الوسيط الذي يعيده التخزين أو واجهات الرفع.
  final String type;

  /// Category label that helps the UI group review media.
  /// تصنيف يساعد الواجهة على تجميع وسائط المراجعة.
  final String category;

  /// Optional caption displayed with the image.
  /// وصف اختياري يظهر مع الصورة.
  final String caption;

  /// Accessibility text used when the image cannot be rendered.
  /// نص بديل لسهولة الوصول عند تعذر عرض الصورة.
  final String altText;

  /// Time when the image was uploaded.
  /// وقت رفع الصورة.
  final DateTime uploadedAt;

  /// Builds an immutable review-image record.
  /// ينشئ سجلًا ثابتًا لصورة المراجعة.
  const ReviewImage({
    required this.id,
    required this.reviewId,
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.type,
    required this.category,
    required this.caption,
    required this.altText,
    required this.uploadedAt,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        reviewId,
        name,
        url,
        sizeBytes,
        type,
        category,
        caption,
        altText,
        uploadedAt,
      ];
}
