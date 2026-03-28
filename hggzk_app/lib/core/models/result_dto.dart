import 'package:equatable/equatable.dart';

/// يحمل ردًا موحدًا من الـ API عندما تكون العملية ناجحة أو فاشلة وتحتاج
/// الطبقات العليا إلى قراءة البيانات ورسالة الحالة والأخطاء من نفس البنية.
/// Wraps an API response in one predictable shape so upper layers can read
/// payload, message, and error metadata through the same contract.
class ResultDto<T> extends Equatable {
  /// يحدد ما إذا كان الخادم يعتبر العملية ناجحة أم لا.
  /// Indicates whether the backend considered the operation successful.
  final bool success;

  /// يحمل الحمولة الفعلية عندما يعيد الخادم نتيجة قابلة للاستخدام.
  /// Carries the actual payload when the server returns usable data.
  final T? data;

  /// نص توضيحي أو تحذيري يرافق النتيجة.
  /// Human-readable context or warning text attached to the result.
  final String? message;

  /// قائمة رسائل الأخطاء التفصيلية عندما يرفض الخادم الطلب.
  /// Detailed error messages returned when the backend rejects a request.
  final List<String> errors;

  /// رمز داخلي أو خارجي يسهّل تصنيف الخطأ أو تتبع مصدره.
  /// An internal or external code used to classify or trace the error.
  final String? errorCode;

  /// لحظة توليد هذا الرد لتسهيل التسجيل أو المقارنة أو الكاش.
  /// The time this response was created, useful for logging and caching.
  final DateTime timestamp;

  /// قيمة بديلة للرمز عندما يرسل الخادم شكلًا مختلفًا من التسمية.
  /// Alternate code field when the backend uses a different naming shape.
  final String? code;

  /// يحدد ما إذا كان ينبغي للواجهة أن تعرض النتيجة داخل حوار.
  /// Tells the UI whether the response should be surfaced in a dialog.
  final bool showAsDialog;

  /// يُستخدم عندما تكون النتيجة جاهزة بالكامل قبل طباعتها أو تمريرها بين
  /// الطبقات.
  /// Used when a response is already normalized and ready to move between
  /// layers or to be logged.
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

  /// يوفّر اسمًا تعبيريًا أكثر لعلم النجاح نفسه دون تغيير السلوك.
  /// Provides a more expressive alias for the success flag.
  bool get isSuccess => success;

  /// يحوّل JSON القادم من الخادم إلى حاوية نتيجة typed، مع دعم `fromJsonT`
  /// عندما تكون الحمولة نفسها معقدة.
  /// Converts a server JSON payload into a typed response wrapper and uses
  /// `fromJsonT` when the nested data needs extra parsing.
  factory ResultDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ResultDto<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
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

  /// يعيد بناء الخريطة الأصلية للرد بحيث يمكن إرسالها أو حفظها أو تسجيلها
  /// دون فقدان الحقول الوصفية.
  /// Rebuilds the response map so it can be serialized, stored, or logged
  /// without losing metadata.
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

  /// يحدد الحقول التي تعتبر هذه النتيجة متطابقة معها عند المقارنة.
  /// Declares the fields that participate in equality comparisons.
  @override
  List<Object?> get props => [
        success,
        data,
        message,
        errors,
        errorCode,
        timestamp,
        code,
        showAsDialog,
      ];
}

/// يمثل الردود التي لا تحمل حمولة فعلية لكنها ما زالت تنقل حالة النجاح أو
/// الرسائل أو رموز الخطأ.
/// Represents responses that do not carry a payload but still expose success,
/// message, and error metadata.
class ResultDtoVoid extends Equatable {
  /// Indicates whether the backend considered the payload-less operation a
  /// success.
  /// يوضح ما إذا كان الخادم قد اعتبر العملية الخالية من الحمولة ناجحة.
  final bool success;

  /// Message returned by the backend to explain the outcome.
  /// الرسالة التي يعيدها الخادم لشرح النتيجة أو الخطأ.
  final String? message;

  /// Detailed error messages when validation or processing fails.
  /// رسائل الأخطاء التفصيلية عند فشل التحقق أو المعالجة.
  final List<String> errors;

  /// Error code used for tracking or categorizing failures.
  /// رمز الخطأ الذي يساعد على التتبع أو التمييز بين الأنواع.
  final String? errorCode;

  /// Timestamp associated with the response envelope.
  /// الطابع الزمني المرتبط بغلاف الاستجابة.
  final DateTime timestamp;

  /// Alternate code field for backends using another naming convention.
  /// حقل رمز بديل عندما يستخدم الخادم تسمية مختلفة.
  final String? code;

  /// Controls whether the UI should present the message in a dialog.
  /// يحدد ما إذا كانت الواجهة ستعرض الرسالة في حوار.
  final bool showAsDialog;

  /// Used for operations that complete without returning a domain payload, such
  /// as delete actions or silent updates.
  /// يُستخدم للعمليات التي تنتهي بدون حمولة نطاقية، مثل الحذف أو التحديثات
  /// الصامتة.
  const ResultDtoVoid({
    required this.success,
    this.message,
    this.errors = const [],
    this.errorCode,
    required this.timestamp,
    this.code,
    this.showAsDialog = false,
  });

  /// Provides a more readable alias for the raw success flag.
  /// يوفّر اسمًا أكثر وضوحًا لعلم النجاح الخام.
  bool get isSuccess => success;

  /// Converts JSON into a payload-less response while preserving status and
  /// message metadata.
  /// يحوّل JSON إلى استجابة خالية من الحمولة مع الحفاظ على حقول الحالة
  /// والرسائل.
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
    );
  }

  /// Serializes the response back into a JSON map without dropping context
  /// fields.
  /// يعيد الاستجابة إلى خريطة JSON من دون إسقاط الحقول السياقية.
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

  /// Lists the fields that determine value equality for payload-less results.
  /// يسرد الحقول التي تحدد تساوي القيم في النتائج الخالية من الحمولة.
  @override
  List<Object?> get props => [
        success,
        message,
        errors,
        errorCode,
        timestamp,
        code,
        showAsDialog,
      ];
}
