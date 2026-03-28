import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// يعيد عدد الإشعارات غير المقروءة لعرضه في الشارات والاختصارات.
/// Returns the unread-notification count for badges and quick indicators.
class GetUnreadCountUseCase implements UseCase<int, GetUnreadCountParams> {
  /// المستودع الذي يوفر عدد الإشعارات غير المقروءة.
  /// Repository that provides the unread notifications count.
  final NotificationRepository repository;
  /// ينشئ حالة الاستخدام مع مستودع الإشعارات.
  /// Creates the use case with the notifications repository.
  GetUnreadCountUseCase(this.repository);
  /// ينفذ طلب جلب العدد غير المقروء من المستودع.
  /// Executes the unread-count request through the repository.
  @override
  Future<Either<Failure, int>> call(GetUnreadCountParams params) {
    return repository.getUnreadCount();
  }
}

/// لا يحتاج هذا الطلب إلى مدخلات لكنه يحافظ على واجهة موحدة.
/// Requires no actual inputs but keeps a consistent use-case interface.
class GetUnreadCountParams extends Equatable {
  /// ينشئ معاملات فارغة لطلب العدد غير المقروء.
  /// Creates empty parameters for the unread-count request.
  const GetUnreadCountParams();
  /// يعيد الحقول المشاركة في مقارنة المعاملات الفارغة.
  /// Returns the fields participating in equality for the empty parameters.
  @override
  List<Object?> get props => [];
}
