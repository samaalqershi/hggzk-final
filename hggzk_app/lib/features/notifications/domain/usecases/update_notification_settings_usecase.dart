import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// يحدّث تفضيلات الإشعارات كما يختارها المستخدم من شاشة الإعدادات.
/// Updates notification preferences as chosen by the user from settings UI.
class UpdateNotificationSettingsUseCase
    implements UseCase<void, UpdateNotificationSettingsParams> {
  /// المستودع الذي يطبق تفضيلات الإشعارات محليًا أو على الخادم.
  /// Repository that applies notification preferences locally or remotely.
  final NotificationRepository repository;

  /// ينشئ حالة الاستخدام المسؤولة عن حفظ تفضيلات الإشعارات الجديدة.
  /// Creates the use case responsible for persisting updated notification
  /// preferences.
  UpdateNotificationSettingsUseCase(this.repository);

  /// يمرر خريطة التفضيلات الجديدة إلى المستودع لتطبيقها.
  /// Forwards the new preferences map to the repository for application.
  @override
  Future<Either<Failure, void>> call(
      UpdateNotificationSettingsParams params) async {
    return await repository.updateNotificationSettings(params.settings);
  }
}

/// يحمل خريطة التفضيلات المطلوب حفظها لميزة الإشعارات.
/// Holds the settings map that should be persisted for notifications.
class UpdateNotificationSettingsParams extends Equatable {
  /// خريطة التفضيلات النهائية المطلوب اعتمادها.
  /// Final preferences map that should become the active configuration.
  final Map<String, bool> settings;

  /// ينشئ معاملات تحديث تفضيلات الإشعارات.
  /// Creates the parameters for updating notification preferences.
  const UpdateNotificationSettingsParams({required this.settings});

  /// يعيد الحقول المستخدمة في مقارنة معاملات التحديث.
  /// Returns the fields used to compare update parameters.
  @override
  List<Object> get props => [settings];
}
