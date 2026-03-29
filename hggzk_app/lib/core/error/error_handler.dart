import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'exceptions.dart';
import 'failures.dart';

/// يحوّل الاستثناءات المتناثرة في طبقة البيانات إلى فشل موحد يمكن
/// لباقي التطبيق التعامل معه دون معرفة التفاصيل التقنية.
/// Converts scattered data-layer exceptions into a single failure
/// vocabulary the rest of the app can consume.
class ErrorHandler {
  /// يترجم أي خطأ معروف إلى `Failure` مناسب للسياق.
  /// Translates known exceptions into the most appropriate failure.
  static Either<Failure, T> handle<T>(dynamic error) {
    if (error is DioException) {
      return Left(_handleDioError(error));
    } else if (error is ApiException) {
      return Left(_handleApiException(error));
    } else if (error is ServerException) {
      return Left(ServerFailure.meta(
        message: error.message,
        code: error.code,
        showAsDialog: error.showAsDialog,
      ));
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
        AppLocalizations.translateSync('common.unexpectedError'),
      ));
    }
  }

  /// يقرأ تفاصيل `DioException` ويحوّلها إلى فشل أعلى يطابق طبيعة
  /// المشكلة مثل المهلة أو الشبكة أو الرد غير الصالح.
  /// Interprets `DioException` and maps it to a higher-level failure
  /// such as timeout, network, or invalid response.
  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return UnknownFailure(
          AppLocalizations.translateSync('common.requestCancelled'),
        );
      case DioExceptionType.connectionError:
        return NetworkFailure();
      case DioExceptionType.badCertificate:
        return ServerFailure(
          AppLocalizations.translateSync('common.badCertificate'),
        );
      case DioExceptionType.unknown:
      default:
        return UnknownFailure();
    }
  }

  /// يفسر ردود HTTP غير الناجحة ويعيدها إلى فشل محدد بحسب رمز
  /// الحالة ومحتوى الرسالة.
  /// Interprets non-successful HTTP responses and turns them into a
  /// specific failure based on status code and payload message.
  static Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return ServerFailure(
        AppLocalizations.translateSync('common.noResponse'),
      );
    }

    final statusCode = response.statusCode;
    final data = response.data;
    String message = AppLocalizations.translateSync('common.unexpectedError');

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

  /// يترجم `ApiException` الخام إلى فشل domain مناسب للحالة.
  /// Converts a raw `ApiException` into the matching domain failure.
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

  // Helper method to extract error message
  /// يستخرج الرسالة الأكثر فائدة لعرضها أو تسجيلها، مع دمج أخطاء
  /// التحقق عندما تكون متاحة.
  /// Extracts the most useful message for display or logging, merging
  /// validation details when they exist.
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
