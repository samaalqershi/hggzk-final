import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// يغلّف عملية إخفاء إشعار واحد من منظور المجال.
/// Encapsulates dismissing a single notification at the domain level.
class DismissNotificationUseCase
    implements UseCase<void, DismissNotificationParams> {
  /// المستودع الذي ينفذ الإخفاء الفعلي.
  /// Repository that performs the actual dismissal.
  final NotificationRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع الإشعارات.
  /// Creates the use case with the notifications repository.
  DismissNotificationUseCase(this.repository);

  /// ينفذ إخفاء الإشعار المحدد من خلال المستودع.
  /// Executes dismissal of the targeted notification through the repository.
  @override
  Future<Either<Failure, void>> call(DismissNotificationParams params) async {
    return await repository.dismissNotification(params.notificationId);
  }
}

/// يحمل معرّف الإشعار المراد إخفاؤه.
/// Carries the identifier of the notification to dismiss.
class DismissNotificationParams extends Equatable {
  /// معرّف الإشعار الذي يجب إخفاؤه من القائمة.
  /// Identifier of the notification that should be dismissed.
  final String notificationId;

  /// ينشئ معاملات إخفاء إشعار واحد.
  /// Creates the parameters for dismissing a single notification.
  const DismissNotificationParams({required this.notificationId});

  /// يعيد الحقول المستخدمة عند مقارنة معاملات الإخفاء.
  /// Returns the fields used when comparing dismissal parameters.
  @override
  List<Object> get props => [notificationId];
}
