import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// يجلب قائمة الإشعارات المرقمة من المستودع مع دعم التصفية.
/// Fetches a paginated notification list from the repository with optional
/// filtering.
class GetNotificationsUseCase
    implements
        UseCase<PaginatedResult<NotificationEntity>, GetNotificationsParams> {
  /// المستودع الذي يوفر صفحات الإشعارات.
  /// Repository that returns notification pages.
  final NotificationRepository repository;

  /// ينشئ حالة الاستخدام التي تجلب صفحات الإشعارات من المستودع.
  /// Creates the use case that fetches notification pages from the
  /// repository.
  GetNotificationsUseCase(this.repository);

  /// ينفذ طلب جلب الإشعارات مع تمرير معايير الصفحة والتصفية.
  /// Executes the notification fetch request using the supplied paging and
  /// filter criteria.
  @override
  Future<Either<Failure, PaginatedResult<NotificationEntity>>> call(
      GetNotificationsParams params) async {
    return await repository.getNotifications(
      page: params.page,
      limit: params.limit,
      type: params.type,
    );
  }
}

/// يحمل معايير الصفحة الحالية وفلاترها عند طلب الإشعارات.
/// Holds the paging parameters and optional filters for a notifications
/// request.
class GetNotificationsParams extends Equatable {
  /// رقم الصفحة المطلوب تحميلها.
  /// Page number that should be fetched.
  final int page;

  /// عدد العناصر المطلوب في كل صفحة.
  /// Number of items requested in each page.
  final int limit;

  /// نوع الإشعارات المراد قصر النتائج عليه إن وجد.
  /// Notification type used to narrow the results when provided.
  final String? type;

  /// ينشئ معاملات جلب الإشعارات مع قيم افتراضية مناسبة للقائمة الأولى.
  /// Creates notification-fetch parameters with defaults suitable for the
  /// initial list load.
  const GetNotificationsParams({
    this.page = 1,
    this.limit = 20,
    this.type,
  });

  /// يعيد الحقول التي تعتمد عليها مقارنة المعاملات.
  /// Returns the fields used to compare parameter objects.
  @override
  List<Object?> get props => [page, limit, type];
}
