import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_exceptions.dart';
import '../../../../../core/error/exceptions.dart' hide ApiException;
import '../../../../../core/models/paginated_result.dart';
import '../../../../../core/models/result_dto.dart';
import '../../../../../core/enums/payment_method_enum.dart';
import '../models/payment_model.dart';
import '../models/payment_details_model.dart';
import '../models/payment_analytics_model.dart';
import '../models/money_model.dart';
import '../../domain/entities/payment.dart';

/// Describes the payment operations the admin portal relies on when it needs
/// to inspect, adjust, or analyze financial records.
///
/// تصف هذه الواجهة كل عمليات الدفع التي تعتمد عليها بوابة الإدارة عندما
/// تحتاج إلى قراءة السجل المالي أو تعديله أو تحليله.
abstract class PaymentsRemoteDataSource {
  // Commands
  /// Requests a partial or full refund and lets the backend validate amount,
  /// reason, and eligibility.
  ///
  /// يطلب استردادًا جزئيًا أو كاملًا مع ترك التحقق النهائي للخادم بشأن
  /// المبلغ والسبب وأهلية العملية.
  Future<bool> refundPayment({
    required String paymentId,
    required Money refundAmount,
    required String refundReason,
  });

  /// Voids a payment before it is treated as a completed financial settlement.
  ///
  /// يلغي الدفعة قبل اعتبارها تسوية مالية نهائية.
  Future<bool> voidPayment({required String paymentId});

  /// Updates the server-side lifecycle state for an already recorded payment.
  ///
  /// يحدّث حالة الدفعة المخزنة على الخادم بعد تسجيلها.
  Future<bool> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus newStatus,
  });

  /// Creates or captures a payment for a booking and returns the backend
  /// transaction reference.
  ///
  /// ينشئ الدفعة أو يلتقطها للحجز ثم يعيد مرجع المعاملة الصادر من الخادم.
  Future<String> processPayment({
    required String bookingId,
    required Money amount,
    required PaymentMethod method,
  });

  // Queries
  /// Loads one payment record with the canonical money and status structure.
  ///
  /// يحمّل سجل دفعة واحدًا مع البنية القياسية للمبلغ والحالة.
  Future<PaymentModel> getPaymentById({required String paymentId});

  /// Loads a payment together with its expanded booking, refund, and audit
  /// information.
  ///
  /// يحمّل الدفعة مع تفاصيلها الموسعة الخاصة بالحجز والاسترداد والتدقيق.
  Future<PaymentDetailsModel> getPaymentDetails({required String paymentId});

  /// Queries the payment list using the same filters exposed in the portal
  /// dashboard.
  ///
  /// يستعلم عن قائمة المدفوعات باستخدام الفلاتر نفسها الظاهرة في لوحة الإدارة.
  Future<PaginatedResult<PaymentModel>> getAllPayments({
    PaymentStatus? status,
    PaymentMethod? method,
    String? bookingId,
    String? userId,
    String? propertyId,
    String? unitId,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  });

  /// Loads the payment list for one booking so the portal can show the
  /// settlement history alongside the reservation.
  ///
  /// يحمّل قائمة الدفعات الخاصة بحجز واحد حتى تعرض البوابة سجل التسوية
  /// بجوار بيانات الحجز.
  Future<PaginatedResult<PaymentModel>> getPaymentsByBooking({
    required String bookingId,
    int? pageNumber,
    int? pageSize,
  });

  /// Filters payments by their lifecycle status for operational review.
  ///
  /// يفلتر المدفوعات حسب حالتها التشغيلية للمراجعة الإدارية.
  Future<PaginatedResult<PaymentModel>> getPaymentsByStatus({
    required PaymentStatus status,
    int? pageNumber,
    int? pageSize,
  });

  /// Loads the payments associated with one user for support, audit, or
  /// account-level review.
  ///
  /// يحمّل الدفعات المرتبطة بمستخدم واحد لدعم التدقيق أو المراجعة على مستوى
  /// الحساب.
  Future<PaginatedResult<PaymentModel>> getPaymentsByUser({
    required String userId,
    int? pageNumber,
    int? pageSize,
  });

  /// Groups payments by the collection method chosen by the guest or staff.
  ///
  /// يجمع المدفوعات بحسب طريقة التحصيل المختارة.
  Future<PaginatedResult<PaymentModel>> getPaymentsByMethod({
    required PaymentMethod method,
    int? pageNumber,
    int? pageSize,
  });

  /// Filters payments to a property so managers can compare performance per
  /// asset.
  ///
  /// يفلتر المدفوعات بحسب العقار حتى يمكن مقارنة الأداء بين الأصول.
  Future<PaginatedResult<PaymentModel>> getPaymentsByProperty({
    required String propertyId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  });

  // Analytics
  /// Loads the summary metrics that power the payments analytics dashboard.
  ///
  /// يحمّل المقاييس التجميعية التي تغذي لوحة تحليلات المدفوعات.
  Future<PaymentAnalyticsModel> getPaymentAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
  });

  /// Fetches the revenue breakdown used by finance and reporting views.
  ///
  /// يجلب تفصيل الإيرادات الذي تعتمد عليه شاشات المالية والتقارير.
  Future<Map<String, dynamic>> getRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  });

  /// Returns time-series data used to draw the payment trend chart.
  ///
  /// يعيد بيانات زمنية لرسم مخطط اتجاهات المدفوعات.
  Future<List<PaymentTrendModel>> getPaymentTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  });

  /// Loads refund metrics for the reconciliation and risk-review views.
  ///
  /// يحمّل مؤشرات الاسترداد لعرض التسوية ومراجعة المخاطر.
  Future<RefundAnalyticsModel> getRefundStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
  });
}

/// Concrete payment data source that talks to the admin payments endpoints.
///
/// مصدر البيانات الفعلي الذي يتواصل مع نهايات الـ API الخاصة بالإدارة.
class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  /// HTTP client used to call the payment endpoints.
  ///
  /// عميل HTTP المستخدم للوصول إلى نهايات الدفع.
  final ApiClient apiClient;

  /// Base path shared by all admin payment requests.
  ///
  /// المسار الأساسي المشترك لجميع طلبات الدفع الخاصة بالإدارة.
  static const String _baseEndpoint = '/api/admin/payments';

  /// Injects the HTTP client so the data source stays testable and isolated
  /// from the transport layer.
  ///
  /// يحقن عميل الشبكة ليبقى مصدر البيانات قابلًا للاختبار ومفصولًا عن
  /// تفاصيل طبقة النقل.
  PaymentsRemoteDataSourceImpl({required this.apiClient});

  /// Calls the refund endpoint and maps the result into a strict success flag.
  ///
  /// يستدعي نقطة الاسترداد ثم يحوّل النتيجة إلى قيمة نجاح صريحة.
  @override
  Future<bool> refundPayment({
    required String paymentId,
    required Money refundAmount,
    required String refundReason,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/refund',
        data: {
          'paymentId': paymentId,
          'refundAmount': (refundAmount as MoneyModel).toJson(),
          'refundReason': refundReason,
        },
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to refund payment');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        // If refund endpoint not found or payment missing, treat as failed refund
        throw ServerException(e.message);
      }
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Sends a void request for a payment that should no longer be settled.
  ///
  /// يرسل طلب الإلغاء للدفعات التي يجب ألا تُسوى بعد الآن.
  @override
  Future<bool> voidPayment({required String paymentId}) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/void',
        data: {'paymentId': paymentId},
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to void payment');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Persists the new payment status on the server after a workflow change.
  ///
  /// يحفظ حالة الدفع الجديدة على الخادم بعد تغيّر سير العمل.
  @override
  Future<bool> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus newStatus,
  }) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$paymentId/status',
        data: {
          'paymentId': paymentId,
          'newStatus': newStatus.backendKey,
        },
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(
            result.message ?? 'Failed to update payment status');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Starts payment processing and returns the transaction identifier issued
  /// by the backend.
  ///
  /// يبدأ معالجة الدفع ثم يعيد معرّف المعاملة الصادر من الخادم.
  @override
  Future<String> processPayment({
    required String bookingId,
    required Money amount,
    required PaymentMethod method,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/process',
        data: {
          'bookingId': bookingId,
          'amount': (amount as MoneyModel).toJson(),
          'method': method.backendValue,
        },
      );

      final result = ResultDto<String>.fromJson(
        response.data,
        (json) => json.toString(),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw ServerException(result.message ?? 'Failed to process payment');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Fetches one payment with the backend's canonical payment record shape.
  ///
  /// يجلب دفعة واحدة بصيغة السجل القياسي المعتمد في الخادم.
  @override
  Future<PaymentModel> getPaymentById({required String paymentId}) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$paymentId');

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return PaymentModel.fromJson(result.data!);
      } else {
        throw ServerException(result.message ?? 'Failed to get payment');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Fetches the expanded payment view including booking and audit context.
  ///
  /// يجلب عرض الدفع الموسع بما في ذلك سياق الحجز والتدقيق.
  @override
  Future<PaymentDetailsModel> getPaymentDetails(
      {required String paymentId}) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$paymentId/details');

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return PaymentDetailsModel.fromJson(result.data!);
      } else {
        throw ServerException(
            result.message ?? 'Failed to get payment details');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Applies the portal's filter set to the general payments listing.
  ///
  /// يطبّق مجموعة الفلاتر الخاصة بالبوابة على قائمة المدفوعات العامة.
  @override
  Future<PaginatedResult<PaymentModel>> getAllPayments({
    PaymentStatus? status,
    PaymentMethod? method,
    String? bookingId,
    String? userId,
    String? propertyId,
    String? unitId,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status.backendKey;
      if (method != null) queryParams['method'] = method.backendValue;
      if (bookingId != null) queryParams['bookingId'] = bookingId;
      if (userId != null) queryParams['userId'] = userId;
      if (propertyId != null) queryParams['propertyId'] = propertyId;
      if (unitId != null) queryParams['unitId'] = unitId;
      if (minAmount != null) queryParams['minAmount'] = minAmount;
      if (maxAmount != null) queryParams['maxAmount'] = maxAmount;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;

      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: queryParams,
      );

      return PaginatedResult<PaymentModel>.fromJson(
        response.data,
        (json) => PaymentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Loads the transactions attached to one booking reference.
  ///
  /// يحمّل المعاملات المرتبطة بمرجع حجز واحد.
  @override
  Future<PaginatedResult<PaymentModel>> getPaymentsByBooking({
    required String bookingId,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'bookingId': bookingId,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/by-booking',
        queryParameters: queryParams,
      );

      return PaginatedResult<PaymentModel>.fromJson(
        response.data,
        (json) => PaymentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Returns only the transactions that match one payment status.
  ///
  /// يعيد فقط المعاملات المطابقة لحالة دفع واحدة.
  @override
  Future<PaginatedResult<PaymentModel>> getPaymentsByStatus({
    required PaymentStatus status,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status.backendKey,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/by-status',
        queryParameters: queryParams,
      );

      return PaginatedResult<PaymentModel>.fromJson(
        response.data,
        (json) => PaymentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Finds payments associated with a single user identity.
  ///
  /// يجد المدفوعات المرتبطة بهوية مستخدم واحدة.
  @override
  Future<PaginatedResult<PaymentModel>> getPaymentsByUser({
    required String userId,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/by-user',
        queryParameters: queryParams,
      );

      return PaginatedResult<PaymentModel>.fromJson(
        response.data,
        (json) => PaymentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Filters transactions by the payment method used during capture.
  ///
  /// يفلتر المعاملات بحسب طريقة الدفع المستخدمة عند التحصيل.
  @override
  Future<PaginatedResult<PaymentModel>> getPaymentsByMethod({
    required PaymentMethod method,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'paymentMethod': method.backendValue,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/by-method',
        queryParameters: queryParams,
      );

      return PaginatedResult<PaymentModel>.fromJson(
        response.data,
        (json) => PaymentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Retrieves payments for one property, optionally constrained by date.
  ///
  /// يستخرج المدفوعات الخاصة بعقار واحد مع إمكانية تقييدها بالتاريخ.
  @override
  Future<PaginatedResult<PaymentModel>> getPaymentsByProperty({
    required String propertyId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'propertyId': propertyId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/by-property',
        queryParameters: queryParams,
      );

      return PaginatedResult<PaymentModel>.fromJson(
        response.data,
        (json) => PaymentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Fetches the aggregates that back the payments analytics page.
  ///
  /// يجلب المجاميع التي تُغذي صفحة تحليلات المدفوعات.
  @override
  Future<PaymentAnalyticsModel> getPaymentAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (propertyId != null) queryParams['propertyId'] = propertyId;

      Response response;
      try {
        response = await apiClient.get(
          '$_baseEndpoint/analytics',
          queryParameters: queryParams,
        );
      } on ApiException catch (e) {
        // Fallback: try capitalized endpoint if not found
        if (e.statusCode == 404) {
          response = await apiClient.get(
            '$_baseEndpoint/Analytics',
            queryParameters: queryParams,
          );
        } else {
          rethrow;
        }
      }

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return PaymentAnalyticsModel.fromJson(result.data!);
      } else {
        throw ServerException(result.message ?? 'Failed to get analytics');
      }
    } on ApiException catch (e) {
      // Return empty analytics for 404 to avoid hard-failing the UI
      if (e.statusCode == 404) {
        return _createEmptyAnalytics(startDate, endDate);
      }
      throw ServerException(e.message);
    } on DioException catch (e) {
      // Return empty analytics for 404 to avoid hard-failing the UI
      if (e.response?.statusCode == 404) {
        return _createEmptyAnalytics(startDate, endDate);
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Builds a zeroed analytics payload so the dashboard can render safely
  /// when the backend has no data for the requested range.
  ///
  /// يبني حمولة تحليلات فارغة حتى تستمر اللوحة في العرض بأمان عندما لا
  /// توجد بيانات للنطاق المطلوب.
  PaymentAnalyticsModel _createEmptyAnalytics(
      DateTime? startDate, DateTime? endDate) {
    return PaymentAnalyticsModel.fromJson({
      'summary': const PaymentSummaryModel(
        totalTransactions: 0,
        totalAmount:
            MoneyModel(amount: 0, currency: 'YER', formattedAmount: '0 ر.ي'),
        averageTransactionValue:
            MoneyModel(amount: 0, currency: 'YER', formattedAmount: '0 ر.ي'),
        successRate: 0,
        successfulTransactions: 0,
        failedTransactions: 0,
        pendingTransactions: 0,
        totalRefunded:
            MoneyModel(amount: 0, currency: 'YER', formattedAmount: '0 ر.ي'),
        refundCount: 0,
      ).toJson(),
      'trends': const <dynamic>[],
      'methodAnalytics': const {},
      'statusAnalytics': const {},
      'refundAnalytics': const RefundAnalyticsModel(
        totalRefunds: 0,
        totalRefundedAmount:
            MoneyModel(amount: 0, currency: 'YER', formattedAmount: '0 ر.ي'),
        refundRate: 0,
        averageRefundTime: 0,
        refundReasons: {},
        trends: [],
      ).toJson(),
      'startDate':
          (startDate ?? DateTime.now().subtract(const Duration(days: 30)))
              .toIso8601String(),
      'endDate': (endDate ?? DateTime.now()).toIso8601String(),
    });
  }

  /// Builds the revenue report payload used by the finance dashboard.
  ///
  /// يبني حمولة تقرير الإيرادات التي تستخدمها لوحة المالية.
  @override
  Future<Map<String, dynamic>> getRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (propertyId != null) 'propertyId': propertyId,
      };

      Response response;
      try {
        response = await apiClient.get(
          '$_baseEndpoint/revenue-report',
          queryParameters: queryParams,
        );
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          response = await apiClient.get(
            '$_baseEndpoint/RevenueReport',
            queryParameters: queryParams,
          );
        } else {
          rethrow;
        }
      }

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw ServerException(result.message ?? 'Failed to get revenue report');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return <String, dynamic>{};
      }
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Fetches trend data used to render the time-series chart.
  ///
  /// يجلب بيانات الاتجاهات المستخدمة في رسم المخطط الزمني.
  @override
  Future<List<PaymentTrendModel>> getPaymentTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (propertyId != null) 'propertyId': propertyId,
      };

      Response response;
      try {
        response = await apiClient.get(
          '$_baseEndpoint/trends',
          queryParameters: queryParams,
        );
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          response = await apiClient.get(
            '$_baseEndpoint/Trends',
            queryParameters: queryParams,
          );
        } else {
          rethrow;
        }
      }

      final result = ResultDto<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (result.success && result.data != null) {
        return result.data!
            .map((json) => PaymentTrendModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(result.message ?? 'Failed to get trends');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return <PaymentTrendModel>[];
      }
      throw ServerException(e.message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return <PaymentTrendModel>[];
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  /// Loads the refund aggregates that finance and risk-review screens need to
  /// compare reversals, timing, and exposure.
  ///
  /// يحمّل المجاميع الخاصة بالاسترداد التي تحتاجها شاشات المالية ومراجعة
  /// المخاطر لمقارنة العكسات والتوقيت والتعرّض المالي.
  @override
  Future<RefundAnalyticsModel> getRefundStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (propertyId != null) queryParams['propertyId'] = propertyId;

      Response response;
      try {
        response = await apiClient.get(
          '$_baseEndpoint/refund-statistics',
          queryParameters: queryParams,
        );
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          response = await apiClient.get(
            '$_baseEndpoint/RefundStatistics',
            queryParameters: queryParams,
          );
        } else {
          rethrow;
        }
      }

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return RefundAnalyticsModel.fromJson(result.data!);
      } else {
        throw ServerException(
            result.message ?? 'Failed to get refund statistics');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return const RefundAnalyticsModel(
          totalRefunds: 0,
          totalRefundedAmount: MoneyModel(
              amount: 0, currency: 'USD', formattedAmount: 'USD 0.00'),
          refundRate: 0,
          averageRefundTime: 0,
          refundReasons: {},
          trends: [],
        );
      }
      throw ServerException(e.message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const RefundAnalyticsModel(
          totalRefunds: 0,
          totalRefundedAmount: MoneyModel(
              amount: 0, currency: 'USD', formattedAmount: 'USD 0.00'),
          refundRate: 0,
          averageRefundTime: 0,
          refundReasons: {},
          trends: [],
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }
}
