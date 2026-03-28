import 'package:equatable/equatable.dart';
import '../../../../../core/models/paginated_result.dart';
import '../../../domain/entities/section.dart';

abstract class SectionsListState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `SectionsListState`.
  const SectionsListState();

  @override
  List<Object?> get props => [];
}

class SectionsListInitial extends SectionsListState {}

class SectionsListLoading extends SectionsListState {}

class SectionsListLoaded extends SectionsListState {
  /// العربية: يخزن القيمة `page`.
  final PaginatedResult<Section> page;

  final int currentPage;

  final int totalPages;

  const SectionsListLoaded({
    required this.page,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [page, currentPage, totalPages];
}

class SectionsListError extends SectionsListState {
  /// العربية: يخزن القيمة `message`.
  final String message;

  const SectionsListError({required this.message});

  @override
  List<Object?> get props => [message];
}
