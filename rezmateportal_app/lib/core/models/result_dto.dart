import 'package:equatable/equatable.dart';

class ResultDto<T> extends Equatable {
  final bool success;
  final T? data;
  final String? message;
  final List<String> errors;
  final String? errorCode;
  final DateTime timestamp;
  final String? code;
  final bool showAsDialog;

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

  bool get isSuccess => success;

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

    // If backend returned the payload directly without wrapping, treat it as data
    final bool hasEnvelope =
        json.containsKey('success') ||
        json.containsKey('data') ||
        json.containsKey('Success') ||
        json.containsKey('Data');

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
      // No envelope -> parse whole object as data
      if (fromJsonT != null) {
        parsedData = fromJsonT(json);
      } else {
        parsedData = json as T?;
      }
    }

    List<String> parsedErrors = [];
    final errorsField = getField('errors', 'Errors');
    if (errorsField is List) {
      parsedErrors = errorsField.map((e) => e.toString()).toList();
    } else if (errorsField is String) {
      parsedErrors = [errorsField];
    }

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

    final successRaw = getField('success', 'Success');
    final messageRaw = getField('message', 'Message');
    final errorCodeRaw = getField('errorCode', 'ErrorCode');
    final codeRaw = getField('code', 'Code');
    final showAsDialogRaw = getField('showAsDialog', 'ShowAsDialog');

    return ResultDto<T>(
      success: hasEnvelope
          ? ((successRaw is bool) ? successRaw : false)
          : true,
      data: parsedData,
      message: messageRaw?.toString(),
      errors: parsedErrors,
      errorCode: errorCodeRaw?.toString(),
      timestamp: ts,
      code: codeRaw?.toString(),
      showAsDialog: (showAsDialogRaw is bool)
          ? showAsDialogRaw
          : false,
    );
  }

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

class ResultDtoVoid extends Equatable {
  final bool success;
  final String? message;
  final List<String> errors;
  final String? errorCode;
  final DateTime timestamp;
  final String? code;
  final bool showAsDialog;

  const ResultDtoVoid({
    required this.success,
    this.message,
    this.errors = const [],
    this.errorCode,
    required this.timestamp,
    this.code,
    this.showAsDialog = false,
  });

  bool get isSuccess => success;

  factory ResultDtoVoid.fromJson(Map<String, dynamic> json) {
    return ResultDtoVoid(
      success: json['success'] ?? false,
      message: json['message'],
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
      errorCode: json['errorCode'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      code: json['code'],
      showAsDialog: json['showAsDialog'] == true,
    );
  }

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