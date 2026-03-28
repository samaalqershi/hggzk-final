import 'package:equatable/equatable.dart';

/// يمثل نتيجة عامة من الخادم تجمع بين النجاح أو الفشل والبيانات
/// والملاحظات النصية في غلاف واحد مناسب للطبقات العليا.
/// Represents a generic server result that packages success/failure, payload,
/// and text feedback into a single container for higher layers.
class ResultDto<T> extends Equatable {
  /// يحدد ما إذا كانت العملية نجحت حسب الاستجابة النهائية.
  /// Indicates whether the operation succeeded according to the final
  /// response.
  final bool success;

  /// البيانات الفعلية المرتبطة بالاستجابة عندما تكون موجودة.
  /// The actual payload associated with the response when available.
  final T? data;

  /// رسالة بشرية يمكن عرضها للمستخدم أو تسجيلها.
  /// A human-readable message that can be shown to the user or logged.
  final String? message;

  /// قائمة الأخطاء النصية المرتبطة بالعملية أو التحقق.
  /// The list of textual errors associated with the operation or validation.
  final List<String> errors;

  /// رمز أو معرف خطأ مختصر يفيد في التحليل أو التتبع.
  /// A short error code or identifier useful for diagnostics and tracing.
  final String? errorCode;

  /// وقت إنشاء الاستجابة أو وقت تسجيلها من الخادم.
  /// The time the response was created or recorded by the server.
  final DateTime timestamp;

  /// رمز إضافي قد تستخدمه الواجهة أو طبقة التكامل للتمييز بين الحالات.
  /// An extra code that the UI or integration layer may use to distinguish
  /// cases.
  final String? code;

  /// يحدد ما إذا كان ينبغي إبراز الرسالة على هيئة حوار.
  /// Indicates whether the message should be surfaced as a dialog.
  final bool showAsDialog;

  /// Creates a typed response envelope with status, data, and diagnostic info.
  const ResultDto({
    required this.success,
    this.data,
    this.message,
    this.errors = const [],
    this.errorCode,
    required this.timestamp,
    this.code,
    this.showAsDialog = false,
  });

  /// يختصر فحص النجاح بحيث يقرأه المستهلكون كخاصية معنوية مباشرة.
  /// Exposes the success flag as a semantic convenience getter for callers.
  bool get isSuccess => success;

  /// يحلل JSON من خوادم قد تستخدم أسماء مفاتيح مختلفة أو قد تعيد الحمولة
  /// مباشرة من دون غلاف ثابت.
  /// Parses JSON from servers that may use different key names or may return
  /// the payload directly without a fixed envelope.
  factory ResultDto.fromJson(
    Map<String, dynamic>? json,
    T Function(dynamic)? fromJsonT,
  ) {
    if (json == null) {
      return ResultDto<T>(
        success: false,
        data: null,
        message: 'استجابة غير صالحة',
        errors: const ['الاستجابة فارغة'],
        errorCode: 'INVALID_RESPONSE',
        timestamp: DateTime.now(),
        code: null,
        showAsDialog: false,
      );
    }

    // يتحقق من وجود غلاف استجابة أم أن الخادم أرسل الحمولة مباشرة.
    final bool hasEnvelope = json.containsKey('success') ||
        json.containsKey('data') ||
        json.containsKey('Success') ||
        json.containsKey('Data');

    // يقرأ الحقل باستخدام شكل camelCase أو PascalCase لتغطية اختلافات
    // الخوادم.
    dynamic getField(String camelKey, String pascalKey) {
      if (json.containsKey(camelKey)) return json[camelKey];
      if (json.containsKey(pascalKey)) return json[pascalKey];
      return null;
    }

    T? parsedData;
    if (hasEnvelope) {
      final raw = getField('data', 'Data');
      if (raw != null) {
        if (raw != null && fromJsonT != null) {
          parsedData = fromJsonT(raw);
        } else {
          parsedData = raw as T?;
        }
      }
    } else {
      if (fromJsonT != null) {
        parsedData = fromJsonT(json);
      } else {
        parsedData = json as T?;
      }
    }

    // يجمع رسائل الأخطاء مهما جاءت كقائمة أو نص منفرد.
    List<String> parsedErrors = [];
    final errorsField = getField('errors', 'Errors');
    if (errorsField is List) {
      parsedErrors = errorsField.map((e) => e.toString()).toList();
    } else if (errorsField is String) {
      parsedErrors = [errorsField];
    }

    // يقرأ الطابع الزمني مع الاحتياط لقيم غير قابلة للتحليل.
    DateTime ts;
    final tsRaw = getField('timestamp', 'Timestamp');
    if (tsRaw != null) {
      try {
        ts = DateTime.parse(tsRaw.toString());
      } catch (_) {
        ts = DateTime.now();
      }
    } else {
      ts = DateTime.now();
    }

    // يستخرج الحقول الاختيارية التي قد يعتمد عليها UI أو سجل الأخطاء.
    final successRaw = getField('success', 'Success');
    final messageRaw = getField('message', 'Message');
    final errorCodeRaw = getField('errorCode', 'ErrorCode');
    final codeRaw = getField('code', 'Code');
    final showAsDialogRaw = getField('showAsDialog', 'ShowAsDialog');

    return ResultDto<T>(
      success: hasEnvelope ? ((successRaw is bool) ? successRaw : false) : true,
      data: parsedData,
      message: messageRaw?.toString(),
      errors: parsedErrors,
      errorCode: errorCodeRaw?.toString(),
      timestamp: ts,
      code: codeRaw?.toString(),
      showAsDialog: (showAsDialogRaw is bool) ? showAsDialogRaw : false,
    );
  }

  /// يحول النتيجة إلى JSON جاهز للتخزين أو النقل بين الطبقات.
  /// Serializes the result into JSON ready for storage or cross-layer
  /// transport.
  Map<String, dynamic> toJson([Map<String, dynamic> Function(T?)? toJsonT]) {
    return {
      'success': success,
      'data': data != null && toJsonT != null ? toJsonT(data) : data,
      'message': message,
      'errors': errors,
      'errorCode': errorCode,
      'timestamp': timestamp.toIso8601String(),
      'code': code,
      'showAsDialog': showAsDialog,
    };
  }

  /// تعتمد المساواة على الحقول التي تمثل هوية النتيجة فعليًا.
  /// Defines equality using the fields that actually identify the result.
  @override
  List<Object?> get props => [
        success,
        data,
        message,
        errors,
        errorCode,
        timestamp,
        code,
      ];
}

/// نسخة مبسطة من `ResultDto` مخصصة عندما لا توجد بيانات مرافقة للنتيجة.
/// A simplified `ResultDto` variant used when the response has no payload.
class ResultDtoVoid extends Equatable {
  /// يحدد نجاح العملية في الردود التي لا تحمل بيانات.
  /// Indicates whether the operation succeeded in data-less responses.
  final bool success;

  /// رسالة موجزة من الخادم أو طبقة التكامل.
  /// A short message from the server or integration layer.
  final String? message;

  /// رسائل الأخطاء النصية إن وجدت.
  /// Textual error messages when present.
  final List<String> errors;

  /// رمز أو تصنيف مختصر للخطأ.
  /// A short code or classification for the error.
  final String? errorCode;

  /// وقت إصدار الاستجابة أو تسجيلها.
  /// The time the response was issued or logged.
  final DateTime timestamp;

  /// رمز إضافي للاستهلاك الداخلي أو العرض.
  /// An additional code for internal or presentation use.
  final String? code;

  /// يحدد ما إذا كانت الرسالة يجب أن تظهر كحوار.
  /// Indicates whether the message should appear as a dialog.
  final bool showAsDialog;

  /// Creates a response envelope without data payload.
  const ResultDtoVoid({
    required this.success,
    this.message,
    this.errors = const [],
    this.errorCode,
    required this.timestamp,
    this.code,
    this.showAsDialog = false,
  });

  /// يختصر حالة النجاح لاستخدامها في الفروع المنطقية مباشرة.
  /// Exposes the success flag as a direct helper for branching logic.
  bool get isSuccess => success;

  /// يحول JSON الخاص بالاستجابات الخالية من البيانات إلى كائن typed بسيط.
  /// Parses JSON for no-payload responses into a simple typed object.
  factory ResultDtoVoid.fromJson(Map<String, dynamic> json) {
    return ResultDtoVoid(
      success: json['success'] ?? false,
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : [],
      errorCode: json['errorCode'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      code: json['code'],
      showAsDialog: json['showAsDialog'] == true,
    );
  }

  /// يصدّر الاستجابة بصيغة JSON مناسبة للتخزين أو التمرير.
  /// Serializes the response into JSON suitable for storage or transport.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'errors': errors,
      'errorCode': errorCode,
      'timestamp': timestamp.toIso8601String(),
      'code': code,
    };
  }

  /// تعتمد المساواة على القيم التي تمثل هوية هذه النتيجة المبسطة.
  /// Defines equality using the values that identify this simplified result.
  @override
  List<Object?> get props => [
        success,
        message,
        errors,
        errorCode,
        timestamp,
        code,
      ];
}
