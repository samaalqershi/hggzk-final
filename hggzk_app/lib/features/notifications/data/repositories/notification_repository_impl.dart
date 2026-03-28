import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';

/// ينسق بين المصدرين المحلي والبعيد في ميزة الإشعارات، مع استخدام الكاش
/// عند انقطاع الشبكة وإرجاع نتائج موحدة للطبقات الأعلى.
/// Coordinates local and remote notification sources, falling back to cache
/// when offline and returning unified results to higher layers.
class NotificationRepositoryImpl implements NotificationRepository {
  /// المصدر البعيد المسؤول عن جلب الإشعارات من الخادم.
  /// Remote data source responsible for fetching notifications from the
  /// backend.
  final NotificationRemoteDataSource remoteDataSource;

  /// المصدر المحلي المستخدم للكاش وتفضيلات الإشعارات.
  /// Local data source used for caching and notification preferences.
  final NotificationLocalDataSource localDataSource;

  /// خدمة حالة الشبكة التي تحدد ما إذا كان المسار البعيد متاحًا.
  /// Network service used to determine whether remote calls are available.
  final NetworkInfo networkInfo;

  /// ينشئ تنفيذ المستودع مع المصادر اللازمة لإدارة الإشعارات.
  /// Creates the repository implementation with the dependencies required to
  /// manage notifications.
  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedResult<NotificationEntity>>>
      getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getNotifications(
          page: page,
          limit: limit,
          type: type,
        );
        await localDataSource.cacheNotifications(result.items);
        return Right(result);
      } else {
        final cachedNotifications =
            await localDataSource.getCachedNotifications();
        return Right(PaginatedResult(
          items: cachedNotifications,
          pageNumber: 1,
          pageSize: cachedNotifications.length,
          totalCount: cachedNotifications.length,
        ));
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.markAsRead(notificationId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.markAllAsRead();
        return const Right(null);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> dismissNotification(
      String notificationId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.dismissNotification(notificationId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, bool>>> getNotificationSettings() async {
    try {
      if (await networkInfo.isConnected) {
        final settings = await remoteDataSource.getNotificationSettings();
        await localDataSource.saveNotificationSettings(settings);
        return Right(settings);
      } else {
        final cachedSettings = await localDataSource.getNotificationSettings();
        return Right(cachedSettings);
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(
      Map<String, bool> settings) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateNotificationSettings(settings);
        await localDataSource.saveNotificationSettings(settings);
        return const Right(null);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      if (await networkInfo.isConnected) {
        final count = await remoteDataSource.getUnreadCount();
        return Right(count);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return const Left(ServerFailure('Server error occurred'));
    }
  }
}
