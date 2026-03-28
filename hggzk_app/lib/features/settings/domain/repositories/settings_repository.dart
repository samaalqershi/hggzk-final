import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';

/// يحدد العقد الذي تعتمد عليه طبقة المجال لقراءة الإعدادات وتحديثها.
/// Defines the contract used by the domain layer to read and update settings.
abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, bool>> updateLanguage(String languageCode);
  Future<Either<Failure, bool>> updateTheme(bool isDarkMode);
  Future<Either<Failure, bool>> updateBiometric(bool enabled);
  Future<Either<Failure, bool>> updateNotificationSettings(
      NotificationSettings settings);
  Future<Either<Failure, bool>> updateCurrency(String currencyCode);
  Future<Either<Failure, bool>> updateTimeZone(String timeZone);
  Future<Either<Failure, bool>> saveSettings(AppSettings settings);
  Future<Either<Failure, bool>> resetSettings();
  Future<Either<Failure, bool>> syncSettingsWithServer();
}
