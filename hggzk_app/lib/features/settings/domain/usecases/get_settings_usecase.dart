import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// يجلب الإعدادات الحالية كما يراها المجال.
/// Fetches the current settings as exposed to the domain layer.
class GetSettingsUseCase implements UseCase<AppSettings, NoParams> {
  /// المستودع الذي يمثل مصدر الحقيقة لإعدادات التطبيق.
  /// Repository that acts as the source of truth for application settings.
  final SettingsRepository repository;

  /// ينشئ حالة الاستخدام التي تقرأ الإعدادات من المستودع.
  /// Creates the use case that reads settings from the repository.
  GetSettingsUseCase(this.repository);

  /// ينفذ طلب جلب الإعدادات الحالية مع الحفاظ على واجهة استخدام موحدة.
  /// Executes the current-settings fetch while preserving the standard
  /// use-case interface.
  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}
