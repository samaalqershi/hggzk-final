// lib/features/admin_reviews/presentation/bloc/review_details/review_details_event.dart

part of 'review_details_bloc.dart';
abstract class ReviewDetailsEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewDetailsEvent`.
  const ReviewDetailsEvent();
  @override
  List<Object> get props => [];
}
class LoadReviewDetailsEvent extends ReviewDetailsEvent {
  /// العربية: يخزن القيمة `reviewId`.
  final String reviewId;
  const LoadReviewDetailsEvent(this.reviewId);
  @override
  List<Object> get props => [reviewId];
}
class AddResponseEvent extends ReviewDetailsEvent {
  /// العربية: يخزن القيمة `reviewId`.
  final String reviewId;
  final String responseText;
  final String respondedBy;
  const AddResponseEvent({
    required this.reviewId,
    required this.responseText,
    required this.respondedBy,
  });
  @override
  List<Object> get props => [reviewId, responseText, respondedBy];
}
class DeleteResponseEvent extends ReviewDetailsEvent {
  /// العربية: يخزن القيمة `responseId`.
  final String responseId;
  const DeleteResponseEvent(this.responseId);
  @override
  List<Object> get props => [responseId];
}
class RefreshReviewDetailsEvent extends ReviewDetailsEvent {}
