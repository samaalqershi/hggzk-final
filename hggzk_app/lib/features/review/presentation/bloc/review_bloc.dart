import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/error/failure_localizer.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/get_property_reviews_usecase.dart';
import '../../domain/usecases/get_property_reviews_summary_usecase.dart';
import '../../domain/usecases/upload_review_images_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

/// Coordinates the state and events for `ReviewBloc`.
/// العربية: ينسق الحالة والأحداث الخاصة بـ `ReviewBloc`.
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  /// Keeps the `createReviewUseCase` value.
  /// العربية: يخزن القيمة `createReviewUseCase`.
  final CreateReviewUseCase createReviewUseCase;

  /// Keeps the `getPropertyReviewsUseCase` value.
  /// العربية: يخزن القيمة `getPropertyReviewsUseCase`.
  final GetPropertyReviewsUseCase getPropertyReviewsUseCase;

  /// Keeps the `getPropertyReviewsSummaryUseCase` value.
  /// العربية: يخزن القيمة `getPropertyReviewsSummaryUseCase`.
  final GetPropertyReviewsSummaryUseCase getPropertyReviewsSummaryUseCase;

  /// Keeps the `uploadReviewImagesUseCase` value.
  /// العربية: يخزن القيمة `uploadReviewImagesUseCase`.
  final UploadReviewImagesUseCase uploadReviewImagesUseCase;

  // Pagination variables
  /// Keeps the `currentPropertyId` value.
  /// العربية: يخزن القيمة `currentPropertyId`.
  String? _currentPropertyId;

  /// Keeps the `currentPage` value.
  /// العربية: يخزن القيمة `currentPage`.
  int _currentPage = 1;

  /// Indicates whether `hasReachedMax` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `hasReachedMax` مفعلة.
  bool _hasReachedMax = false;

  /// Keeps the `allReviews` value.
  /// العربية: يخزن القيمة `allReviews`.
  List<Review> _allReviews = [];

  /// Builds a new `ReviewBloc` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewBloc`.
  ReviewBloc({
    required this.createReviewUseCase,
    required this.getPropertyReviewsUseCase,
    required this.getPropertyReviewsSummaryUseCase,
    required this.uploadReviewImagesUseCase,
  }) : super(ReviewInitial()) {
    on<CreateReviewEvent>(_onCreateReview);
    on<GetPropertyReviewsEvent>(_onGetPropertyReviews);
    on<LoadMoreReviewsEvent>(_onLoadMoreReviews);
    on<GetPropertyReviewsSummaryEvent>(_onGetPropertyReviewsSummary);
    on<UploadReviewImagesEvent>(_onUploadReviewImages);
    on<FilterReviewsEvent>(_onFilterReviews);
    on<RefreshReviewsEvent>(_onRefreshReviews);
    on<LikeReviewEvent>(_onLikeReview);
    on<UnlikeReviewEvent>(_onUnlikeReview);
  }

  /// Processes `onCreateReview`.
  /// العربية: يعالج `onCreateReview`.
  Future<void> _onCreateReview(
    CreateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewCreating());

    final result = await createReviewUseCase(
      CreateReviewParams(
        bookingId: event.bookingId,
        propertyId: event.propertyId,
        cleanliness: event.cleanliness,
        service: event.service,
        location: event.location,
        value: event.value,
        comment: event.comment,
        imagesBase64: event.imagesBase64,
      ),
    );

    result.fold(
      (failure) =>
          emit(ReviewCreateError(message: FailureLocalizer.localize(failure))),
      (review) => emit(ReviewCreated(review: review)),
    );
  }

  /// Processes `onGetPropertyReviews`.
  /// العربية: يعالج `onGetPropertyReviews`.
  Future<void> _onGetPropertyReviews(
    GetPropertyReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    _currentPropertyId = event.propertyId;
    _currentPage = event.pageNumber;
    _hasReachedMax = false;
    _allReviews = [];

    final result = await getPropertyReviewsUseCase(
      GetPropertyReviewsParams(
        propertyId: event.propertyId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
        rating: event.rating,
        sortBy: event.sortBy,
        sortDirection: event.sortDirection,
        withImagesOnly: event.withImagesOnly,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) =>
          emit(ReviewError(message: FailureLocalizer.localize(failure))),
      (paginatedResult) {
        _allReviews = paginatedResult.items;
        _hasReachedMax = !paginatedResult.hasNextPage;
        emit(ReviewsLoaded(
          reviews: paginatedResult,
          hasReachedMax: _hasReachedMax,
        ));
      },
    );
  }

  /// Processes `onLoadMoreReviews`.
  /// العربية: يعالج `onLoadMoreReviews`.
  Future<void> _onLoadMoreReviews(
    LoadMoreReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    if (_hasReachedMax || _currentPropertyId == null) return;

    final currentState = state;
    if (currentState is ReviewsLoaded) {
      emit(ReviewLoadingMore(currentReviews: currentState.reviews.items));

      _currentPage++;
      final result = await getPropertyReviewsUseCase(
        GetPropertyReviewsParams(
          propertyId: _currentPropertyId!,
          pageNumber: _currentPage,
          pageSize: 10,
        ),
      );

      result.fold(
        (failure) => emit(currentState),
        (paginatedResult) {
          _allReviews.addAll(paginatedResult.items);
          _hasReachedMax = !paginatedResult.hasNextPage;

          emit(ReviewsLoaded(
            reviews: PaginatedResult<Review>(
              items: _allReviews,
              pageNumber: paginatedResult.pageNumber,
              pageSize: paginatedResult.pageSize,
              totalCount: paginatedResult.totalCount,
              metadata: paginatedResult.metadata,
            ),
            hasReachedMax: _hasReachedMax,
          ));
        },
      );
    }
  }

  /// Processes `onGetPropertyReviewsSummary`.
  /// العربية: يعالج `onGetPropertyReviewsSummary`.
  Future<void> _onGetPropertyReviewsSummary(
    GetPropertyReviewsSummaryEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await getPropertyReviewsSummaryUseCase(
      GetPropertyReviewsSummaryParams(propertyId: event.propertyId),
    );

    result.fold(
      (failure) =>
          emit(ReviewError(message: FailureLocalizer.localize(failure))),
      (summary) => emit(ReviewsSummaryLoaded(summary: summary)),
    );
  }

  /// Processes `onUploadReviewImages`.
  /// العربية: يعالج `onUploadReviewImages`.
  Future<void> _onUploadReviewImages(
    UploadReviewImagesEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewImagesUploading(progress: 0.0));

    final result = await uploadReviewImagesUseCase(
      UploadReviewImagesParams(
        reviewId: event.reviewId,
        imagesBase64: event.imagesBase64,
      ),
    );

    result.fold(
      (failure) =>
          emit(ReviewError(message: FailureLocalizer.localize(failure))),
      (images) => emit(ReviewImagesUploaded(images: images)),
    );
  }

  /// Processes `onFilterReviews`.
  /// العربية: يعالج `onFilterReviews`.
  Future<void> _onFilterReviews(
    FilterReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    if (_currentPropertyId == null) return;

    add(GetPropertyReviewsEvent(
      propertyId: _currentPropertyId!,
      rating: event.rating,
      withImagesOnly: event.withImagesOnly,
      sortBy: event.sortBy,
      sortDirection: event.sortDirection,
    ));
  }

  /// Processes `onRefreshReviews`.
  /// العربية: يعالج `onRefreshReviews`.
  Future<void> _onRefreshReviews(
    RefreshReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    add(GetPropertyReviewsEvent(
      propertyId: event.propertyId,
      pageNumber: 1,
      pageSize: 10,
    ));
  }

  /// Processes `onLikeReview`.
  /// العربية: يعالج `onLikeReview`.
  Future<void> _onLikeReview(
    LikeReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    // TODO: Implement like review functionality
    // This would require an additional use case for liking reviews
  }

  /// Processes `onUnlikeReview`.
  /// العربية: يعالج `onUnlikeReview`.
  Future<void> _onUnlikeReview(
    UnlikeReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    // TODO: Implement unlike review functionality
    // This would require an additional use case for unliking reviews
  }
}
