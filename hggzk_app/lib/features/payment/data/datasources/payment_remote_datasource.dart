import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/request_logger.dart';
import '../models/transaction_model.dart';

/// يعرّف العمليات الشبكية الخاصة بمعالجة الدفع وجلب سجل المعاملات.
/// Declares the remote operations used to process payments and fetch
/// transaction history.
abstract class PaymentRemoteDataSource {
  Future<ResultDto<TransactionModel>> processPayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String paymentMethod,
    required String currency,
    Map<String, dynamic>? cardDetails,
    String? walletId,
    Map<String, dynamic>? paymentData,
  });
  Future<ResultDto<PaginatedResult<TransactionModel>>> getPaymentHistory({
    required String userId,
    int pageNumber = 1,
    int pageSize = 10,
    String? status,
    String? paymentMethod,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
  });
}

/// ينفذ طلبات الدفع عبر `ApiClient` ويترجم الاستجابات إلى نماذج معاملات
/// موحدة.
/// Implements payment requests through `ApiClient` and maps responses into
/// normalized transaction models.
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;
  PaymentRemoteDataSourceImpl({required this.apiClient});
  @override
  Future<ResultDto<TransactionModel>> processPayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String paymentMethod,
    required String currency,
    Map<String, dynamic>? cardDetails,
    String? walletId,
    Map<String, dynamic>? paymentData,
  }) async {
    const requestName = 'payment.processPayment';
    logRequestStart(requestName, details: {
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'currency': currency,
    });
    try {
      final body = <String, dynamic>{
        'bookingId': bookingId,
        'userId': userId,
        'amount': {
          'amount': amount,
          'currency': currency,
        },
        'paymentMethod': paymentMethod,
      };

      if (cardDetails != null) {
        body['cardDetails'] = cardDetails;
      }

      if (walletId != null) {
        body['walletId'] = walletId;
      }

      if (paymentData != null) {
        body['paymentData'] = paymentData;
      }

      final response = await apiClient.post(
        '/api/client/payments/process',
        data: body,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultDto = ResultDto.fromJson(
          response.data,
          (json) => TransactionModel.fromProcessPaymentResponse(json),
        );

        if (resultDto.success && resultDto.data != null) {
          return resultDto;
        } else {
          throw ServerException(
            resultDto.message ?? 'فشل في معالجة الدفع',
            code: resultDto.errorCode ?? resultDto.code,
            showAsDialog: resultDto.showAsDialog,
          );
        }
      } else {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          throw ServerException(
            data['message'] ?? 'فشل في معالجة الدفع',
            code: data['errorCode']?.toString() ?? data['code']?.toString(),
            showAsDialog: data['showAsDialog'] == true,
          );
        }
        throw ServerException('فشل في معالجة الدفع');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          data['message'] ?? e.message ?? 'حدث خطأ في الشبكة',
          code: data['errorCode']?.toString() ?? data['code']?.toString(),
          showAsDialog: data['showAsDialog'] == true,
        );
      }
      throw ServerException(e.message ?? 'حدث خطأ في الشبكة');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('خطأ غير متوقع: $e');
    }
  }

  @override
  Future<ResultDto<PaginatedResult<TransactionModel>>> getPaymentHistory({
    required String userId,
    int pageNumber = 1,
    int pageSize = 10,
    String? status,
    String? paymentMethod,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    const requestName = 'payment.getPaymentHistory';
    logRequestStart(requestName, details: {
      'userId': userId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    });
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (status != null) queryParams['status'] = status;
      if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
      if (fromDate != null)
        queryParams['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['toDate'] = toDate.toIso8601String();
      if (minAmount != null) queryParams['minAmount'] = minAmount;
      if (maxAmount != null) queryParams['maxAmount'] = maxAmount;

      final response = await apiClient.get(
        '/api/client/payments/history',
        queryParameters: queryParams,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => PaginatedResult.fromJson(
            json,
            (paymentJson) => TransactionModel.fromJson(paymentJson),
          ),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'فشل في جلب سجل المدفوعات');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'حدث خطأ في الشبكة');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('خطأ غير متوقع: $e');
    }
  }
}
