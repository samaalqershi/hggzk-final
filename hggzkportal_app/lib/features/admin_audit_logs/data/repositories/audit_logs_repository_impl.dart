// lib/features/admin_audit_logs/data/repositories/audit_logs_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_logs_repository.dart';
import '../datasources/audit_logs_local_datasource.dart';
import '../datasources/audit_logs_remote_datasource.dart';

/// يربط عقد سجلّات التدقيق في الدومين بالمصدرين البعيد والمحلي مع
/// إدارة واضحة لحالة الاتصال.
/// Bridges the audit-log domain contract with the remote and local sources
/// while managing connectivity-aware behavior.
class AuditLogsRepositoryImpl implements AuditLogsRepository {
  /// المصدر البعيد المسؤول عن جلب السجلّات من الخادم.
  /// Remote datasource responsible for fetching logs from the backend.
  final AuditLogsRemoteDataSource remoteDataSource;

  /// المصدر المحلي الذي يحتفظ بلقطة احتياطية قابلة للاسترجاع.
  /// Local datasource that keeps a recoverable fallback snapshot.
  final AuditLogsLocalDataSource localDataSource;

  /// فاحص الاتصال الذي يحدد ما إذا كنا سنتجه إلى الشبكة أم الكاش.
  /// Connectivity checker that decides whether to use the network or cache.
  final NetworkInfo networkInfo;

  /// يربط المستودع بالمصادر المحقونة التي يعتمد عليها في الجلب والتخزين.
  /// Binds the repository to the injected sources it relies on for fetch and
  /// caching.
  AuditLogsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  @override

  /// يجلب سجلّات التدقيق العامة من الشبكة أو من الكاش بحسب حالة الاتصال.
  /// Fetches general audit logs from the network or cache based on
  /// connectivity.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getAuditLogs(
      AuditLogsQuery query) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getAuditLogs(query);
        await localDataSource.cacheAuditLogs(result.items);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cachedLogs = await localDataSource.getCachedAuditLogs();
        return Right(PaginatedResult(
          items: cachedLogs,
          totalCount: cachedLogs.length,
          pageNumber: 1,
          pageSize: cachedLogs.length,
        ));
      } catch (e) {
        return Left(CacheFailure('No cached data available'));
      }
    }
  }

  @override

  /// يجلب سجلّات نشاط العملاء ويعيدها داخل `Either` كي يسهل التعامل مع
  /// الفشل.
  /// Fetches customer activity logs and wraps the result in an `Either` so
  /// failures are easy to handle.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getCustomerActivityLogs(
      CustomerActivityLogsQuery query) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getCustomerActivityLogs(query);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب سجلّات نشاط العقارات ويعيدها ككيان صفحات داخل `Either`.
  /// Fetches property activity logs and returns them as a paginated entity
  /// inside an `Either`.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getPropertyActivityLogs(
      PropertyActivityLogsQuery query) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getPropertyActivityLogs(query);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب سجلّات نشاط المشرفين مع الالتزام بسلوك الشبكة المتاح حاليًا.
  /// Fetches admin activity logs while respecting the current network
  /// availability.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getAdminActivityLogs(
      AdminActivityLogsQuery query) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getAdminActivityLogs(query);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يصدّر السجلّات على شكل قائمة كاملة إذا كانت الشبكة متاحة.
  /// Exports the logs as a full list when the network is available.
  Future<Either<Failure, List<AuditLog>>> exportAuditLogs(
      AuditLogsQuery query) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.exportAuditLogs(query);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب تفاصيل سجل تدقيق واحد ويعيدها داخل `Either` لتمثيل النجاح أو
  /// الفشل بوضوح.
  /// Fetches a single audit-log detail record and wraps it in an `Either` to
  /// represent success or failure clearly.
  Future<Either<Failure, AuditLog>> getAuditLogDetails(
      String auditLogId) async {
    try {
      final result = await remoteDataSource.getAuditLogDetails(auditLogId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
