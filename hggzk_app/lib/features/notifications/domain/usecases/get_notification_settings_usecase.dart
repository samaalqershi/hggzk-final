import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// يجلب إعدادات الإشعارات الحالية كما يراها المجال.
/// Fetches the current notification settings for the domain layer.
class GetNotificationSettingsUseCase
    implements UseCase<Map<String, bool>, GetNotificationSettingsParams> {
  /// المستودع الذي يوفر إعدادات الإشعارات.
  /// Repository that provides notification settings.
  final NotificationRepository repository;

  /// ينشئ حالة الاستخدام التي تقرأ إعدادات الإشعارات من المستودع.
  /// Creates the use case that reads notification settings from the
  /// repository.
  GetNotificationSettingsUseCase(this.repository);

  /// ينفذ طلب جلب إعدادات الإشعارات الحالية.
  /// Executes the request that fetches current notification settings.
  @override
  Future<Either<Failure, Map<String, bool>>> call(
    GetNotificationSettingsParams params,
  ) async {
    return await repository.getNotificationSettings();
  }
}

/// لا يحمل مدخلات فعلية لكنه يحافظ على شكل موحد لحالة الاستخدام.
/// Carries no effective data but preserves a consistent use-case signature.
class GetNotificationSettingsParams extends Equatable {
  /// ينشئ معاملات فارغة لطلب إعدادات الإشعارات.
  /// Creates empty parameters for the notification-settings request.
  const GetNotificationSettingsParams();

  /// يعيد الحقول المستخدمة في مقارنة هذه المعاملات الفارغة.
  /// Returns the fields used to compare these empty parameters.
  @override
  List<Object?> get props => [];
}
