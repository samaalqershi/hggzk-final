import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// يحدّث اللغة المفضلة داخل إعدادات التطبيق.
/// Updates the preferred application language.
class UpdateLanguageUseCase implements UseCase<bool, UpdateLanguageParams> {
  /// المستودع الذي يحفظ اختيار اللغة ويعيد نتيجة العملية.
  /// Repository that persists the language selection and returns the result.
  final SettingsRepository repository;

  /// ينشئ حالة الاستخدام المسؤولة عن تحديث لغة التطبيق.
  /// Creates the use case responsible for updating the app language.
  UpdateLanguageUseCase(this.repository);

  /// يتحقق من رمز اللغة ثم يمرر التحديث إلى المستودع.
  /// Validates the language code and then forwards the update to the
  /// repository.
  @override
  Future<Either<Failure, bool>> call(UpdateLanguageParams params) async {
    // Validate language code
    if (!['ar', 'en'].contains(params.languageCode)) {
      return const Left(ValidationFailure('Invalid language code'));
    }

    return await repository.updateLanguage(params.languageCode);
  }
}

/// يحمل رمز اللغة المطلوب تطبيقه.
/// Carries the language code that should be applied.
class UpdateLanguageParams extends Equatable {
  /// رمز اللغة المطلوب حفظه كتفضيل نشط.
  /// Language code that should be saved as the active preference.
  final String languageCode;

  /// ينشئ معاملات تحديث اللغة للطلب الحالي.
  /// Creates the parameters for the current language-update request.
  const UpdateLanguageParams({required this.languageCode});

  /// يعيد الحقول المستخدمة عند مقارنة معاملات تحديث اللغة.
  /// Returns the fields used when comparing language-update parameters.
  @override
  List<Object> get props => [languageCode];
}
