import 'package:dartz/dartz.dart';
import 'package:hggzk/core/usecases/usecase.dart';
import 'package:hggzk/features/search/domain/entities/search_result.dart';
import '../../../../core/error/failures.dart';
import '../repositories/search_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetSearchFiltersUseCase`.
class GetSearchFiltersUseCase implements UseCase<SearchFilters, NoParams> {
  /// العربية: يخزن القيمة `repository`.
  final SearchRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetSearchFiltersUseCase`.
  GetSearchFiltersUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, SearchFilters>> call(NoParams params) async {
    return await repository.getSearchFilters();
  }
}
