import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// يحدّث وضع الثيم المفضل داخل إعدادات التطبيق.
/// Updates the preferred theme mode within app settings.
class UpdateThemeUseCase implements UseCase<bool, UpdateThemeParams> {
  /// المستودع الذي يطبق تغيير المظهر على الإعدادات المخزنة.
  /// Repository that applies the theme change to persisted settings.
  final SettingsRepository repository;

  /// ينشئ حالة الاستخدام المسؤولة عن تغيير المظهر.
  /// Creates the use case responsible for changing the application theme.
  UpdateThemeUseCase(this.repository);

  /// يمرر قيمة الوضع الداكن أو الفاتح الجديدة إلى المستودع.
  /// Forwards the new dark or light theme preference to the repository.
  @override
  Future<Either<Failure, bool>> call(UpdateThemeParams params) async {
    return await repository.updateTheme(params.isDarkMode);
  }
}

/// يحمل القيمة الجديدة الخاصة بالوضع الداكن أو الفاتح.
/// Carries the new dark-mode preference value.
class UpdateThemeParams extends Equatable {
  /// يحدد ما إذا كان المظهر المطلوب هو الداكن.
  /// Indicates whether the requested theme should be dark.
  final bool isDarkMode;

  /// ينشئ معاملات تحديث المظهر للقيمة المطلوبة.
  /// Creates the parameters for the requested theme update.
  const UpdateThemeParams({required this.isDarkMode});

  /// يعيد الحقول المستخدمة لمقارنة معاملات تحديث المظهر.
  /// Returns the fields used to compare theme-update parameters.
  @override
  List<Object> get props => [isDarkMode];
}
