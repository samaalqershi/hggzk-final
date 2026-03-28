import 'package:equatable/equatable.dart';
import 'review_image.dart';

/// Represents the review payload attached to a property booking experience.
/// يمثل حمولة المراجعة المرتبطة بتجربة حجز العقار.
class Review extends Equatable {
  /// Backend identifier used to edit, like, or moderate this review later.
  /// المعرّف الخلفي المستخدم عند تعديل المراجعة أو الإعجاب بها أو إدارتها.
  final String id;

  /// Identifies the guest who wrote the review.
  /// يحدد الضيف الذي كتب المراجعة.
  final String userId;

  /// Display name shown beside the review content.
  /// اسم العرض الذي يظهر بجانب محتوى المراجعة.
  final String userName;

  /// Optional profile image shown in review lists and cards.
  /// صورة اختيارية للملف الشخصي تظهر في القوائم والبطاقات.
  final String? userAvatar;

  /// Links the review back to the booking that produced it.
  /// يربط المراجعة بالحجز الذي أنشأها.
  final String bookingId;

  /// Identifies the property the guest stayed in.
  /// يحدد العقار الذي أقام فيه الضيف.
  final String propertyId;

  /// Cleanliness score submitted by the reviewer on a 1-5 scale.
  /// درجة النظافة التي أدخلها المراجع على مقياس من 1 إلى 5.
  final int cleanliness;

  /// Service score submitted by the reviewer on a 1-5 scale.
  /// درجة الخدمة التي أدخلها المراجع على مقياس من 1 إلى 5.
  final int service;

  /// Location score submitted by the reviewer on a 1-5 scale.
  /// درجة الموقع التي أدخلها المراجع على مقياس من 1 إلى 5.
  final int location;

  /// Value-for-money score submitted by the reviewer on a 1-5 scale.
  /// درجة القيمة مقابل المال التي أدخلها المراجع على مقياس من 1 إلى 5.
  final int value;

  /// Combined rating used by summary cards and ranking logic.
  /// التقييم المجمّع المستخدم في البطاقات المختصرة ومنطق الترتيب.
  final double rating;

  /// Short headline that captures the main opinion of the review.
  /// عنوان قصير يلخص رأي المراجعة الأساسي.
  final String title;

  /// Main review body written by the guest.
  /// النص الأساسي الذي كتبه الضيف.
  final String comment;

  /// Time when the review was originally submitted.
  /// وقت إرسال المراجعة لأول مرة.
  final DateTime createdAt;

  /// Optional timestamp used when the review was edited after publication.
  /// طابع زمني اختياري يُستخدم عندما تُعدّل المراجعة بعد نشرها.
  final DateTime? updatedAt;

  /// Attached media that supports the written review.
  /// الوسائط المرفقة التي تدعم المراجعة المكتوبة.
  final List<ReviewImage> images;

  /// True when this review belongs to the signed-in user.
  /// تكون صحيحة عندما تعود المراجعة للمستخدم الحالي.
  final bool isUserReview;

  /// Number of users who liked this review.
  /// عدد المستخدمين الذين أعجبوا بهذه المراجعة.
  final int likesCount;

  /// True when the signed-in user already liked this review.
  /// تكون صحيحة عندما يكون المستخدم الحالي قد أعجب بالمراجعة.
  final bool isLikedByUser;

  /// Optional response written by the property team after moderation.
  /// رد اختياري يكتبه فريق العقار بعد المراجعة أو المراقبة.
  final ReviewReply? managementReply;

  /// Optional booking category that helps the UI show the trip context.
  /// نوع الحجز الاختياري الذي يساعد الواجهة على إظهار سياق الرحلة.
  final String? bookingType;

  /// Marks reviews that the backend wants to highlight.
  /// يحدد المراجعات التي يريد الخادم إبرازها.
  final bool isRecommended;

  /// Builds an immutable review record for the property review experience.
  /// ينشئ سجل مراجعة ثابتًا لتجربة مراجعات العقار.
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.bookingId,
    required this.propertyId,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.value,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    required this.images,
    required this.isUserReview,
    required this.likesCount,
    required this.isLikedByUser,
    this.managementReply,
    this.bookingType,
    required this.isRecommended,
  });

  /// Recomputes the aggregate score from the four visible category ratings.
  /// يعيد حساب الدرجة المجمعة من فئات التقييم الأربع الظاهرة.
  double get calculatedRating {
    return (cleanliness + service + location + value) / 4.0;
  }

  /// Indicates whether the review includes at least one attached image.
  /// يحدد ما إذا كانت المراجعة تحتوي على صورة مرفقة واحدة على الأقل.
  bool get hasImages => images.isNotEmpty;

  /// Indicates whether the property team has replied to the review.
  /// يحدد ما إذا كان فريق العقار قد رد على المراجعة.
  bool get hasManagementReply => managementReply != null;

  /// Keeps equality stable for the full review payload.
  /// يحافظ على ثبات المقارنة مع حمولة المراجعة كاملة.
  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        bookingId,
        propertyId,
        cleanliness,
        service,
        location,
        value,
        rating,
        title,
        comment,
        createdAt,
        updatedAt,
        images,
        isUserReview,
        likesCount,
        isLikedByUser,
        managementReply,
        bookingType,
        isRecommended,
      ];
}

/// Represents a moderation or support reply attached to a review.
/// يمثل رد المراجعة الصادر عن فريق العقار أو الدعم.
class ReviewReply extends Equatable {
  /// Unique identifier of the reply record.
  /// المعرّف الفريد لسجل الرد.
  final String id;

  /// Reply body shown to the guest.
  /// نص الرد المعروض للضيف.
  final String content;

  /// Time when the reply was posted.
  /// وقت نشر الرد.
  final DateTime createdAt;

  /// Display name of the person who wrote the reply.
  /// اسم العرض للشخص الذي كتب الرد.
  final String replierName;

  /// Job title or role of the replier within the property team.
  /// المسمى الوظيفي أو دور الشخص داخل فريق العقار.
  final String replierPosition;

  /// Builds an immutable reply model associated with a review.
  /// ينشئ نموذجًا ثابتًا لرد مرتبط بمراجعة.
  const ReviewReply({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.replierName,
    required this.replierPosition,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [
        id,
        content,
        createdAt,
        replierName,
        replierPosition,
      ];
}

/// <summary>
/// كيان ملخص المراجعات
/// Reviews summary entity
/// </summary>
class ReviewsSummary extends Equatable {
  /// <summary>
  /// إجمالي عدد المراجعات
  /// Total reviews count
  /// </summary>
  final int totalReviews;

  /// <summary>
  /// متوسط التقييم
  /// Average rating
  /// </summary>
  final double averageRating;

  /// <summary>
  /// توزيع التقييمات (1-5 نجوم)
  /// Rating distribution (1-5 stars)
  /// </summary>
  final Map<int, int> ratingDistribution;

  /// <summary>
  /// نسبة التقييمات حسب النجوم
  /// Rating percentages by stars
  /// </summary>
  final Map<int, double> ratingPercentages;

  /// <summary>
  /// عدد المراجعات مع الصور
  /// Reviews with images count
  /// </summary>
  final int reviewsWithImagesCount;

  /// <summary>
  /// عدد المراجعات الموصى بها
  /// Recommended reviews count
  /// </summary>
  final int recommendedCount;

  /// <summary>
  /// أحدث 3 مراجعات
  /// Latest 3 reviews
  /// </summary>
  final List<Review> latestReviews;

  /// <summary>
  /// أفضل 3 مراجعات (الأعلى تقييماً)
  /// Top 3 reviews (highest rated)
  /// </summary>
  final List<Review> topReviews;

  /// <summary>
  /// الكلمات المفتاحية الشائعة في المراجعات
  /// Common keywords in reviews
  /// </summary>
  final List<ReviewKeyword> commonKeywords;

  /// <summary>
  /// معدل الاستجابة من الإدارة
  /// Management response rate
  /// </summary>
  final double managementResponseRate;

  /// Builds a new `ReviewsSummary` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewsSummary`.
  const ReviewsSummary({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.ratingPercentages,
    required this.reviewsWithImagesCount,
    required this.recommendedCount,
    required this.latestReviews,
    required this.topReviews,
    required this.commonKeywords,
    required this.managementResponseRate,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [
        totalReviews,
        averageRating,
        ratingDistribution,
        ratingPercentages,
        reviewsWithImagesCount,
        recommendedCount,
        latestReviews,
        topReviews,
        commonKeywords,
        managementResponseRate,
      ];
}

/// <summary>
/// كيان الكلمات المفتاحية في المراجعات
/// Review keywords entity
/// </summary>
class ReviewKeyword extends Equatable {
  /// <summary>
  /// الكلمة المفتاحية
  /// Keyword
  /// </summary>
  final String keyword;

  /// <summary>
  /// عدد مرات التكرار
  /// Frequency count
  /// </summary>
  final int count;

  /// <summary>
  /// النسبة المئوية
  /// Percentage
  /// </summary>
  final double percentage;

  /// <summary>
  /// نوع المشاعر (إيجابي، سلبي، محايد)
  /// Sentiment type (positive, negative, neutral)
  /// </summary>
  final String sentiment;

  /// Builds a new `ReviewKeyword` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewKeyword`.
  const ReviewKeyword({
    required this.keyword,
    required this.count,
    required this.percentage,
    required this.sentiment,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [keyword, count, percentage, sentiment];
}
