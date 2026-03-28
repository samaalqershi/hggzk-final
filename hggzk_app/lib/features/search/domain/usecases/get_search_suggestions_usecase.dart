import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzk/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../repositories/search_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetSearchSuggestionsUseCase`.
class GetSearchSuggestionsUseCase
    implements UseCase<List<String>, SearchSuggestionsParams> {
  /// العربية: يخزن القيمة `repository`.
  final SearchRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetSearchSuggestionsUseCase`.
  GetSearchSuggestionsUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<String>>> call(
      SearchSuggestionsParams params) async {
    return await repository.getSearchSuggestions(
      query: params.query,
      limit: params.limit,
    );
  }
}

/// العربية: يمثل `SearchSuggestionsParams`.
class SearchSuggestionsParams extends Equatable {
  /// العربية: يخزن القيمة `query`.
  final String query;

  /// العربية: يخزن القيمة `limit`.
  final int limit;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchSuggestionsParams`.
  const SearchSuggestionsParams({
    required this.query,
    this.limit = 10,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [query, limit];
}
