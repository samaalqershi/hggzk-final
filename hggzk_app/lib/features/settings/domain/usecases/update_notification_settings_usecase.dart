import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// يحدّث تفضيلات الإشعارات المضمنة داخل إعدادات التطبيق.
/// Updates the notification-preferences subset of the app settings.
class UpdateNotificationSettingsUseCase
    implements UseCase<bool, UpdateNotificationSettingsParams> {
  /// المستودع الذي يحفظ تفضيلات الإشعارات ضمن إعدادات التطبيق.
  /// Repository that persists notification preferences within app settings.
  final SettingsRepository repository;

  /// ينشئ حالة الاستخدام الخاصة بتحديث تفضيلات الإشعارات.
  /// Creates the use case responsible for updating notification preferences.
  UpdateNotificationSettingsUseCase(this.repository);

  /// يرسل تفضيلات الإشعارات الجديدة إلى المستودع لحفظها.
  /// Sends the new notification preferences to the repository for
  /// persistence.
  @override
  Future<Either<Failure, bool>> call(
      UpdateNotificationSettingsParams params) async {
    return await repository.updateNotificationSettings(params.settings);
  }
}

/// يحمل مجموعة تفضيلات الإشعارات الجديدة المطلوب حفظها.
/// Carries the new notification preferences that should be saved.
class UpdateNotificationSettingsParams extends Equatable {
  /// مجموعة التفضيلات التي ستصبح الحالة الجديدة للإشعارات.
  /// Preference group that should become the new notification state.
  final NotificationSettings settings;

  /// ينشئ معاملات تحديث تفضيلات الإشعارات.
  /// Creates the parameters for updating notification preferences.
  const UpdateNotificationSettingsParams({required this.settings});

  /// يعيد الحقول المستخدمة عند مقارنة معاملات التحديث.
  /// Returns the fields used when comparing update parameters.
  @override
  List<Object> get props => [settings];
}
