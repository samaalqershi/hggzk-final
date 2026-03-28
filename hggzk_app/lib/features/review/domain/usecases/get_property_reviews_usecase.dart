import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Loads a paginated review feed for a property.
/// يحمل موجز مراجعات مقسمًا إلى صفحات لعقار معين.
class GetPropertyReviewsUseCase {
  /// Repository bridge that fetches review data from the backend.
  /// جسر المستودع الذي يجلب بيانات المراجعات من الخادم.
  final ReviewRepository repository;

  /// Creates the use case around the review repository contract.
  /// ينشئ حالة الاستخدام اعتمادًا على عقد مستودع المراجعات.
  GetPropertyReviewsUseCase(this.repository);

  /// Requests one page of property reviews using the supplied filters.
  /// يطلب صفحة واحدة من مراجعات العقار باستخدام الفلاتر الممررة.
  Future<Either<Failure, PaginatedResult<Review>>> call(
      GetPropertyReviewsParams params) async {
    return await repository.getPropertyReviews(
      propertyId: params.propertyId,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      rating: params.rating,
      sortBy: params.sortBy,
      sortDirection: params.sortDirection,
      withImagesOnly: params.withImagesOnly,
      userId: params.userId,
    );
  }
}

/// Parameters needed to request a review page for one property.
/// المعطيات اللازمة لطلب صفحة مراجعات لعقار واحد.
class GetPropertyReviewsParams extends Equatable {
  /// Backend identifier of the property being queried.
  /// المعرّف الخلفي للعقار المطلوب.
  final String propertyId;

  /// Page number to fetch from the paginated feed.
  /// رقم الصفحة المطلوب من الموجز المقسم.
  final int pageNumber;

  /// Number of review items requested per page.
  /// عدد عناصر المراجعة المطلوبة في كل صفحة.
  final int pageSize;

  /// Optional rating filter used to narrow the feed.
  /// فلتر اختياري للتقييم يستخدم لتضييق النتائج.
  final int? rating;

  /// Sort field sent to the backend.
  /// حقل الترتيب المرسل إلى الخادم.
  final String? sortBy;

  /// Sort direction paired with `sortBy`.
  /// اتجاه الترتيب المرتبط بحقل `sortBy`.
  final String? sortDirection;

  /// Limits the feed to reviews that include images.
  /// يقيّد الموجز بالمراجعات التي تحتوي على صور.
  final bool? withImagesOnly;

  /// Optional viewer identifier for user-specific review behavior.
  /// معرّف اختياري للمشاهد يفيد في سلوك المراجعات الخاص بالمستخدم.
  final String? userId;

  /// Bundles the filters used to load a page of property reviews.
  /// يجمع الفلاتر المستخدمة لتحميل صفحة مراجعات للعقار.
  const GetPropertyReviewsParams({
    required this.propertyId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.rating,
    this.sortBy = 'CreatedAt',
    this.sortDirection = 'Desc',
    this.withImagesOnly = false,
    this.userId,
  });

  /// Keeps equality aligned with the active review query.
  /// يحافظ على ثبات المقارنة مع استعلام المراجعات الحالي.
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
