import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// يحدد ما إذا كان المطلوب تعليم إشعار واحد أو جميع الإشعارات كمقروءة.
/// Decides whether one notification or the whole set should be marked as
/// read.
class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  /// المستودع الذي ينفذ تغيير حالة القراءة.
  /// Repository that performs the read-state update.
  final NotificationRepository repository;

  /// ينشئ حالة الاستخدام المسؤولة عن تعليم الإشعارات كمقروءة.
  /// Creates the use case responsible for marking notifications as read.
  MarkAsReadUseCase(this.repository);

  /// يحدد ما إذا كان المطلوب تحديث إشعار واحد أو جميع الإشعارات.
  /// Decides whether the request targets one notification or the full set.
  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    if (params.notificationId == null) {
      return await repository.markAllAsRead();
    } else {
      return await repository.markAsRead(params.notificationId!);
    }
  }
}

/// يحمل معرّف الإشعار الهدف، أو يتركه فارغًا لتعليـم الجميع كمقروء.
/// Carries the target notification identifier, or leaves it empty to mark all
/// notifications as read.
class MarkAsReadParams extends Equatable {
  /// معرّف الإشعار الهدف، أو `null` عندما يكون المطلوب تحديث الجميع.
  /// Identifier of the target notification, or `null` when all items should
  /// be updated.
  final String? notificationId;

  /// ينشئ معاملات تعليم الإشعار أو جميع الإشعارات كمقروءة.
  /// Creates the parameters for marking one notification or all notifications
  /// as read.
  const MarkAsReadParams({this.notificationId});

  /// يعيد الحقول المستخدمة عند مقارنة المعاملات.
  /// Returns the fields used when comparing parameter instances.
  @override
  List<Object?> get props => [notificationId];
}
