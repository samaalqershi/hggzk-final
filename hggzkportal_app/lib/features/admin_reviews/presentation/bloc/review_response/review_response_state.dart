// lib/features/admin_reviews/presentation/bloc/review_response/review_response_state.dart

part of 'review_response_bloc.dart';
abstract class ReviewResponseState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewResponseState`.
  const ReviewResponseState();
  @override
  List<Object> get props => [];
}
class ReviewResponseInitial extends ReviewResponseState {}
class ReviewResponseSubmitting extends ReviewResponseState {}
class ReviewResponseSuccess extends ReviewResponseState {
  /// العربية: يخزن القيمة `response`.
  final ReviewResponse response;
  const ReviewResponseSuccess(this.response);
  @override
  List<Object> get props => [response];
}
class ReviewResponseError extends ReviewResponseState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const ReviewResponseError(this.message);
  @override
  List<Object> get props => [message];
}
