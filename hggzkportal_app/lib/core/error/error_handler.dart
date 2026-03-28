import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../network/api_exceptions.dart' as network_exceptions;
import 'exceptions.dart';
import 'failures.dart';

/// يحول الاستثناءات الخام القادمة من الشبكة أو التخزين أو المجال إلى كائنات
/// `Failure` موحدة تستطيع الطبقات الأعلى التعامل معها بطريقة متسقة.
/// Translates raw exceptions coming from network, storage, or domain code
/// into normalized `Failure` objects that upper layers can handle
/// consistently.
class ErrorHandler {
  /// يحلل الخطأ الوارد ويعيد مكافئه من نوع `Failure` داخل `Either`.
  /// Inspects the incoming error and returns its `Failure` equivalent wrapped
  /// in an `Either`.
  static Either<Failure, T> handle<T>(dynamic error) {
    if (error is DioException) {
      return Left(_handleDioError(error));
    } else if (error is network_exceptions.ApiException) {
      return Left(_handleNetworkApiException(error));
    } else if (error is ApiException) {
      return Left(_handleApiException(error));
    } else if (error is ServerException) {
      return Left(ServerFailure(error.message));
    } else if (error is NetworkException) {
      return Left(NetworkFailure(error.message));
    } else if (error is CacheException) {
      return Left(CacheFailure(error.message));
    } else if (error is AuthenticationException) {
      return Left(AuthenticationFailure(error.message));
    } else if (error is UnauthorizedException) {
      return Left(UnauthorizedFailure(error.message));
    } else if (error is ValidationException) {
      return Left(ValidationFailureWithErrors(
        message: error.message,
        errors: error.errors ?? {},
      ));
    } else if (error is NotFoundException) {
      return Left(NotFoundFailure(error.message));
    } else if (error is TimeoutException) {
      return Left(TimeoutFailure(error.message));
    } else {
      return Left(UnknownFailure(
        error.toString(),
      ));
    }
  }

  /// يحول أخطاء Dio المنخفضة المستوى إلى نوع الفشل الأنسب لسياق التطبيق.
  /// Converts low-level Dio failures into the most appropriate application
  /// failure type.
  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const UnknownFailure('تم إلغاء الطلب');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
        return const ServerFailure('خطأ في شهادة الأمان');
      case DioExceptionType.unknown:
        return const UnknownFailure();
    }
  }

  /// يفسر الاستجابات غير الناجحة من الخادم اعتمادًا على رمز HTTP والحمولة
  /// الراجعة.
  /// Interprets unsuccessful backend responses using the HTTP status code and
  /// returned payload.
  static Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerFailure('لا توجد استجابة من الخادم');
    }

    final statusCode = response.statusCode;
    final data = response.data;
    String message = 'حدث خطأ';

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ApiFailure(message: message, code: statusCode.toString());
      case 401:
        if (message.contains('expired') || message.contains('انتهت')) {
          return SessionExpiredFailure(message);
        }
        return UnauthorizedFailure(message);
      case 403:
        return PermissionDeniedFailure(message);
      case 404:
        return NotFoundFailure(message);
      case 422:
        Map<String, List<String>>? errors;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          errors = Map<String, List<String>>.from(
            data['errors'].map((key, value) => MapEntry(
                  key,
                  value is List ? List<String>.from(value) : [value.toString()],
                )),
          );
        }
        return ValidationFailureWithErrors(
            message: message, errors: errors ?? {});
      case 500:
      case 502:
      case 503:
        return ServerFailure(message);
      default:
        return ServerFailure(message);
    }
  }

  /// يحول استثناءات طبقة `core/network/api_exceptions.dart` إلى `Failure`
  /// مفهوم لبقية المشروع.
  /// Maps exceptions coming from `core/network/api_exceptions.dart` into a
  /// `Failure` understood by the rest of the project.
  static Failure _handleNetworkApiException(
      network_exceptions.ApiException error) {
    if (error.statusCode == 401) {
      return UnauthorizedFailure(error.message);
    } else if (error.statusCode == 403) {
      return PermissionDeniedFailure(error.message);
    } else if (error.statusCode == 404) {
      return NotFoundFailure(error.message);
    } else if (error.statusCode == 422) {
      return ValidationFailure(error.message);
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkFailure(error.message);
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return TimeoutFailure(error.message);
    } else {
      return ServerFailure(error.message);
    }
  }

  /// يحول استثناءات الـ API المحلية المستخدمة في طبقات أخرى إلى `Failure`
  /// موحد.
  /// Maps the local API exception type used in other layers into a normalized
  /// `Failure`.
  static Failure _handleApiException(ApiException error) {
    if (error.statusCode == 401) {
      return UnauthorizedFailure(error.message);
    } else if (error.statusCode == 403) {
      return PermissionDeniedFailure(error.message);
    } else if (error.statusCode == 404) {
      return NotFoundFailure(error.message);
    } else if (error.statusCode == 422) {
      return ValidationFailure(error.message);
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkFailure(error.message);
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return TimeoutFailure(error.message);
    } else {
      return ServerFailure(error.message);
    }
  }

  /// يستخرج الرسالة الأنسب للعرض من كائن الفشل، مع دمج أخطاء التحقق متعددة
  /// الحقول عند الحاجة.
  /// Extracts the most useful display message from a failure, flattening
  /// field-level validation errors when needed.
  static String getErrorMessage(Failure failure) {
    if (failure is ValidationFailure && failure.errors != null) {
      // Join all validation errors
      final allErrors =
          failure.errors!.values.expand((errors) => errors).join('\n');
      return allErrors.isNotEmpty ? allErrors : failure.message;
    }
    return failure.message;
  }
}
