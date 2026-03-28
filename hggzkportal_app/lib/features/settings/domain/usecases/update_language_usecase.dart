import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class UpdateLanguageUseCase implements UseCase<bool, UpdateLanguageParams> {
  /// العربية: يخزن القيمة `repository`.
  final SettingsRepository repository;
  UpdateLanguageUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(UpdateLanguageParams params) async {
    // Validate language code
    if (!['ar', 'en'].contains(params.languageCode)) {
      return const Left(ValidationFailure('Invalid language code'));
    }

    return await repository.updateLanguage(params.languageCode);
  }
}

class UpdateLanguageParams extends Equatable {
  /// العربية: يخزن القيمة `languageCode`.
  final String languageCode;
  const UpdateLanguageParams({required this.languageCode});
  @override
  List<Object> get props => [languageCode];
}
