import 'package:flutter/foundation.dart';

/// مساعدات تسجيل خفيفة لتتبع بداية الطلبات ونجاحها وفشلها.
/// Lightweight logging helpers that mark request start, success, and failure.
/// يسجل لحظة بدء الطلب مع أي تفاصيل مساندة.
void logRequestStart(String requestName, {Map<String, dynamic>? details}) {
  debugPrint(
      '>>> [REQUEST START] $requestName${details != null ? ' | details: $details' : ''}');
}

/// يسجل اكتمال الطلب مع رمز الحالة إن توفر.
void logRequestSuccess(String requestName,
    {int? statusCode, Map<String, dynamic>? details}) {
  debugPrint(
      '<<< [REQUEST SUCCESS] $requestName${statusCode != null ? ' | status: $statusCode' : ''}${details != null ? ' | details: $details' : ''}');
}

/// يسجل الخطأ مع التفاصيل الإضافية ثم يطبع stack trace عند وجوده.
void logRequestError(String requestName, Object error,
    {StackTrace? stackTrace, Map<String, dynamic>? details}) {
  debugPrint(
      'xxx [REQUEST ERROR] $requestName | error: $error${details != null ? ' | details: $details' : ''}');
  if (stackTrace != null) {
    debugPrint(stackTrace.toString());
  }
}
