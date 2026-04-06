import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/review.dart';
import '../entities/review_image.dart';

/// Defines the review persistence and retrieval contract used by the review
/// feature.
/// يعرّف عقد تخزين واسترجاع المراجعات الذي تعتمد عليه ميزة المراجعات.
abstract class ReviewRepository {
  /// Stores a new review for a completed booking and returns the created
  /// record so the UI can refresh immediately.
  /// يحفظ مراجعة جديدة لحجز مكتمل ويعيد السجل الناتج حتى تتمكن الواجهة من
  /// التحديث فورًا.
  Future<Either<Failure, Review>> createReview({
    required String bookingId,
    required String propertyId,
    required int cleanliness,
    required int service,
    required int location,
    required int value,
    required String comment,
    List<String>? imagesBase64,
    String? videoBase64,
    String? videoThumbnailBase64,
    void Function(double progress)? onSendProgress,
  });

  /// Loads a paginated review feed for one property.
  /// يحمل موجز مراجعات مقسمًا إلى صفحات لعقار واحد.
  Future<Either<Failure, PaginatedResult<Review>>> getPropertyReviews({
    required String propertyId,
    required int pageNumber,
    required int pageSize,
    int? rating,
    String? sortBy,
    String? sortDirection,
    bool? withImagesOnly,
    String? userId,
  });

  /// Returns aggregate rating data used by the summary cards.
  /// يعيد بيانات التقييم المجمّع المستخدمة في بطاقات الملخص.
  Future<Either<Failure, ReviewsSummary>> getPropertyReviewsSummary({
    required String propertyId,
  });

  /// Uploads review images before or after the review is saved, depending on
  /// the backend flow.
  /// يرفع صور المراجعة قبل الحفظ أو بعده بحسب مسار الخادم.
  Future<Either<Failure, List<ReviewImage>>> uploadReviewImages({
    required String reviewId,
    required List<String> imagesBase64,
  });
}
