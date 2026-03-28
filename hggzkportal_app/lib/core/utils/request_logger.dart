import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// مساعدات تسجيل خفيفة تبيّن متى بدأ الطلب ومتى نجح أو فشل.
/// Lightweight logging helpers that make request start, success, and failure easy to trace.
void logRequestStart(String requestName, {Map<String, dynamic>? details}) {
  debugPrint(
      '>>> [REQUEST START] $requestName${details != null ? ' | details: $details' : ''}');
}

/// يسجل نجاح الطلب مع أي تفاصيل تشخيصية مفيدة حول الاستجابة.
/// Logs a successful request along with optional diagnostic details.
void logRequestSuccess(String requestName,
    {int? statusCode, Map<String, dynamic>? details}) {
  debugPrint(
      '<<< [REQUEST SUCCESS] $requestName${statusCode != null ? ' | status: $statusCode' : ''}${details != null ? ' | details: $details' : ''}');
}

/// يسجل فشل الطلب مع كبح السجلات المكررة في حالات الأخطاء المتوقعة.
/// Logs a failed request while suppressing noisy duplicates for expected errors.
void logRequestError(String requestName, Object error,
    {StackTrace? stackTrace, Map<String, dynamic>? details}) {
  bool suppress = false;
  if (error is DioException) {
    final extra = error.requestOptions.extra;
    if (extra['suppressErrorLog'] == true) {
      suppress = true;
    } else {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      if (status == 401) {
        final message = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : error.message;
        final normalized = (message ?? '').toLowerCase();
        if (normalized.contains('token expired') ||
            normalized.contains('expired')) {
          suppress = true;
        }
      }
    }
  }

  if (!suppress) {
    debugPrint(
        'xxx [REQUEST ERROR] $requestName | error: $error${details != null ? ' | details: $details' : ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
