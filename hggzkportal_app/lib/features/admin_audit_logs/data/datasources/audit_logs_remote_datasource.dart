// lib/features/admin_audit_logs/data/datasources/audit_logs_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/audit_log.dart';
import '../models/audit_log_model.dart';

/// يعرّف عمليات جلب وتصدير تفاصيل سجلّات التدقيق من الخادم حسب نوع
/// النشاط والجمهور المستهدف.
/// Defines the remote operations for fetching and exporting audit logs from
/// the backend by activity type and target audience.
abstract class AuditLogsRemoteDataSource {
  /// يجلب السجلّات العامة مع التصفية والصفحات بحسب الاستعلام المرسل.
  /// Fetches the general audit logs with filtering and paging based on the
  /// provided query.
  Future<PaginatedResult<AuditLog>> getAuditLogs(AuditLogsQuery query);

  /// يجلب نشاط العملاء فقط كي يُعرض في شاشات المتابعة أو التقارير
  /// المتخصصة.
  /// Fetches only customer activity so it can be shown in monitoring screens
  /// or specialized reports.
  Future<PaginatedResult<AuditLog>> getCustomerActivityLogs(
      CustomerActivityLogsQuery query);

  /// يجلب نشاط العقارات المرتبط بالتغييرات أو العمليات التنفيذية على
  /// الوحدات العقارية.
  /// Fetches property-related activity tied to changes or operational actions
  /// on property records.
  Future<PaginatedResult<AuditLog>> getPropertyActivityLogs(
      PropertyActivityLogsQuery query);

  /// يجلب نشاط المشرفين لتتبع العمليات الإدارية والتغييرات الحساسة.
  /// Fetches admin activity to track administrative operations and sensitive
  /// changes.
  Future<PaginatedResult<AuditLog>> getAdminActivityLogs(
      AdminActivityLogsQuery query);

  /// يصدر السجلّات وفق الاستعلام نفسه لكن على شكل قائمة كاملة قابلة
  /// للتنزيل.
  /// Exports the logs using the same query shape but as a full downloadable
  /// list.
  Future<List<AuditLog>> exportAuditLogs(AuditLogsQuery query);

  /// يجلب تفاصيل سجل تدقيق محدد لعرض النصوص الكاملة والبيانات المتغيرة
  /// الخاصة به.
  /// Fetches a single audit-log record so its full text and changed data can
  /// be displayed.
  Future<AuditLog> getAuditLogDetails(String auditLogId);
}

/// ينفذ الاتصال البعيد بخدمة التدقيق الإدارية ويحوّل الاستجابات إلى
/// نماذج نطاقية.
/// Implements the remote call flow for the admin audit service and converts
/// responses into domain models.
class AuditLogsRemoteDataSourceImpl implements AuditLogsRemoteDataSource {
  /// عميل الشبكة المشترك الذي يرسل طلبات التدقيق ويستقبل الاستجابات.
  /// Shared network client that sends audit-log requests and receives
  /// responses.
  final ApiClient apiClient;

  /// المسار الأساسي الذي تعرض من خلاله واجهة الإدارة سجلّات التدقيق.
  /// Base endpoint through which the admin API exposes audit logs.
  static const String _baseEndpoint = '/api/admin/audit-logs';

  /// يربط مصدر البيانات البعيد بعميل الشبكة المحقون من طبقة الاعتماد.
  /// Binds the remote datasource to the injected network client from the DI
  /// layer.
  AuditLogsRemoteDataSourceImpl({required this.apiClient});
  @override

  /// يجلب السجلّات العامة من الخادم ويطابق أكثر من شكل استجابة محتمل.
  /// Fetches the general logs from the backend and tolerates multiple response
  /// shapes.
  Future<PaginatedResult<AuditLog>> getAuditLogs(AuditLogsQuery query) async {
    try {
      final queryParams = query.toMap();

      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        // التحقق من البنية الصحيحة للاستجابة
        if (response.data is Map && response.data.containsKey('items')) {
          final items = (response.data['items'] as List? ?? [])
              .map((json) =>
                  AuditLogModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return PaginatedResult<AuditLog>(
            items: items,
            totalCount: response.data['totalCount'] ?? 0,
            pageNumber: response.data['pageNumber'] ?? 1,
            pageSize: response.data['pageSize'] ?? 20,
          );
        } else {
          // إذا كانت البنية مختلفة، حاول تحليلها مباشرة
          return PaginatedResult<AuditLog>.fromJson(
            response.data,
            (json) => AuditLogModel.fromJson(json),
          );
        }
      } else {
        throw const ServerException('Invalid response format');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch audit logs',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }

  @override

  /// يجلب تفاصيل سجل تدقيق واحد بالمعرف كي تعرضه شاشة التفاصيل.
  /// Fetches a single audit-log record by id so the details screen can render
  /// it.
  Future<AuditLog> getAuditLogDetails(String auditLogId) async {
    try {
      final response =
          await apiClient.get('$_baseEndpoint/$auditLogId/details');
      if (response.data is Map<String, dynamic>) {
        return AuditLogModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Invalid response for audit log details');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch audit log details',
      );
    }
  }

  @override

  /// يجلب نشاط العملاء مع نفس منطق التصفية والترقيم المستخدم في القوائم
  /// العامة.
  /// Fetches customer activity using the same filtering and paging logic used
  /// by the general lists.
  Future<PaginatedResult<AuditLog>> getCustomerActivityLogs(
      CustomerActivityLogsQuery query) async {
    try {
      final queryParams = query.toMap();

      final response =
          await apiClient.get(_baseEndpoint, queryParameters: queryParams);

      if (response.data != null) {
        if (response.data is Map && response.data.containsKey('items')) {
          final items = (response.data['items'] as List? ?? [])
              .map((json) =>
                  AuditLogModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return PaginatedResult<AuditLog>(
            items: items,
            totalCount: response.data['totalCount'] ?? 0,
            pageNumber: response.data['pageNumber'] ?? 1,
            pageSize: response.data['pageSize'] ?? 20,
          );
        } else {
          return PaginatedResult<AuditLog>.fromJson(
            response.data,
            (json) => AuditLogModel.fromJson(json),
          );
        }
      } else {
        throw const ServerException('Invalid response format');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ??
            'Failed to fetch customer activity logs',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }

  @override

  /// يجلب نشاط العقارات مع الحفاظ على المرونة في شكل الاستجابة القادمة من
  /// الخادم.
  /// Fetches property activity while remaining flexible about the backend's
  /// response shape.
  Future<PaginatedResult<AuditLog>> getPropertyActivityLogs(
      PropertyActivityLogsQuery query) async {
    try {
      final queryParams = query.toMap();

      final response =
          await apiClient.get(_baseEndpoint, queryParameters: queryParams);

      if (response.data != null) {
        if (response.data is Map && response.data.containsKey('items')) {
          final items = (response.data['items'] as List? ?? [])
              .map((json) =>
                  AuditLogModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return PaginatedResult<AuditLog>(
            items: items,
            totalCount: response.data['totalCount'] ?? 0,
            pageNumber: response.data['pageNumber'] ?? 1,
            pageSize: response.data['pageSize'] ?? 20,
          );
        } else {
          return PaginatedResult<AuditLog>.fromJson(
            response.data,
            (json) => AuditLogModel.fromJson(json),
          );
        }
      } else {
        throw const ServerException('Invalid response format');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ??
            'Failed to fetch property activity logs',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }

  @override

  /// يجلب نشاط المشرفين مع دعم الاستجابة المباشرة أو المغلفة بحسب ما
  /// يعيده الـ API.
  /// Fetches admin activity while supporting either direct or wrapped
  /// responses from the API.
  Future<PaginatedResult<AuditLog>> getAdminActivityLogs(
      AdminActivityLogsQuery query) async {
    try {
      final queryParams = query.toMap();

      final response =
          await apiClient.get(_baseEndpoint, queryParameters: queryParams);

      if (response.data != null) {
        if (response.data is Map && response.data.containsKey('items')) {
          final items = (response.data['items'] as List? ?? [])
              .map((json) =>
                  AuditLogModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return PaginatedResult<AuditLog>(
            items: items,
            totalCount: response.data['totalCount'] ?? 0,
            pageNumber: response.data['pageNumber'] ?? 1,
            pageSize: response.data['pageSize'] ?? 20,
          );
        } else {
          return PaginatedResult<AuditLog>.fromJson(
            response.data,
            (json) => AuditLogModel.fromJson(json),
          );
        }
      } else {
        throw const ServerException('Invalid response format');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch admin activity logs',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }

  @override

  /// يصدّر السجلّات على نطاق واسع مع مراعاة استجابات النجاح أو الخطأ
  /// المتعددة.
  /// Exports the logs in bulk while handling multiple success or error
  /// response styles.
  Future<List<AuditLog>> exportAuditLogs(AuditLogsQuery query) async {
    try {
      final queryParams = {...query.toMap(), 'pageSize': 10000};

      final response =
          await apiClient.get(_baseEndpoint, queryParameters: queryParams);

      if (response.data != null) {
        // التحقق من وجود isSuccess flag إذا كان API يستخدمه
        if (response.data is Map && response.data.containsKey('isSuccess')) {
          if (response.data['isSuccess'] == true) {
            final data = response.data['data'];
            if (data is List) {
              return data
                  .map((json) =>
                      AuditLogModel.fromJson(json as Map<String, dynamic>))
                  .toList();
            } else if (data is Map && data.containsKey('items')) {
              return (data['items'] as List? ?? [])
                  .map((json) =>
                      AuditLogModel.fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          } else {
            throw ServerException(
              response.data['message'] ?? 'Failed to export audit logs',
            );
          }
        }

        // إذا لم يكن هناك isSuccess flag، حاول معالجة البيانات مباشرة
        if (response.data is List) {
          return response.data
              .map((json) =>
                  AuditLogModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map && response.data.containsKey('items')) {
          return (response.data['items'] as List? ?? [])
              .map((json) =>
                  AuditLogModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw const ServerException('Invalid export response format');
        }
      } else {
        throw const ServerException('Empty response received');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw const ServerException(
          'Export size too large. Please narrow down your filters.',
        );
      }
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to export audit logs',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }
}
