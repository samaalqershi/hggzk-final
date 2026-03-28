import 'dart:async';
import 'dart:io'; // إضافة للحصول على Platform
import 'package:hggzkportal/core/utils/timezone_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/local_storage_service.dart';
import '../../services/message_service.dart';
import '../constants/storage_constants.dart';
import '../constants/api_constants.dart';
import '../localization/locale_manager.dart';
import '../bloc/app_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../services/navigation_service.dart';
import '../../injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';

/// Interceptor that injects auth, locale, property, and timezone context into outgoing requests.
/// معترض يضيف سياق المصادقة واللغة والموقع العقاري والمنطقة الزمنية إلى الطلبات الصادرة.
class AuthInterceptor extends Interceptor {
  /// Creates the request interceptor responsible for app-wide request headers.
  /// ينشئ معترض الطلبات المسؤول عن رؤوس الشبكة المشتركة للتطبيق.
  AuthInterceptor();

  /// Adds the active access token, locale, property headers, and timezone metadata before the request is sent.
  /// يضيف رمز الوصول الحالي واللغة ورؤوس العقار وبيانات المنطقة الزمنية قبل إرسال الطلب.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Allow skipping auth header for specific requests
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final localStorage = sl<LocalStorageService>();
    final token = localStorage.getData(StorageConstants.accessToken) as String?;

    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    // propagate role/property context for backend if needed
    final accountRole =
        localStorage.getData(StorageConstants.accountRole)?.toString();
    final propertyId =
        localStorage.getData(StorageConstants.propertyId)?.toString();
    final propertyCurrency =
        localStorage.getData(StorageConstants.propertyCurrency)?.toString();

    if (accountRole != null && accountRole.isNotEmpty) {
      options.headers['X-Account-Role'] = accountRole;
    }
    if (propertyId != null && propertyId.isNotEmpty) {
      options.headers['X-Property-Id'] = propertyId;
    }
    if (propertyCurrency != null && propertyCurrency.isNotEmpty) {
      options.headers['X-Property-Currency'] = propertyCurrency;
    }

    // Add current language to headers
    final locale = LocaleManager.getCurrentLocale();
    options.headers[ApiConstants.acceptLanguage] = locale.languageCode;

    // إضافة معلومات المنطقة الزمنية
    await _addTimezoneHeaders(options);

    // Ensure correct Content-Type for FormData requests
    try {
      if (options.data is FormData) {
        // Remove any JSON defaults so Dio can attach boundary
        options.headers.remove('Content-Type');
        options.headers.remove('content-type');
        options.contentType = 'multipart/form-data';
        if (kDebugMode) {
          print(
              '📎 Overriding Content-Type to multipart/form-data for FormData request');
        }
      }
    } catch (_) {}

    handler.next(options);
  }

  /// Resolves and persists timezone headers so the backend can interpret local dates correctly.
  /// يحل ويخزن رؤوس المنطقة الزمنية حتى يفسر الخادم التواريخ المحلية بشكل صحيح.
  Future<void> _addTimezoneHeaders(RequestOptions options) async {
    try {
      // التأكد من التهيئة
      await TimezoneHelper.initialize();

      // الحصول على timezone
      final timezone = await TimezoneHelper.getDeviceTimezone();
      final offset = TimezoneHelper.getTimezoneOffset();

      // إضافة headers المنطقة الزمنية
      options.headers['X-TimeZone'] = timezone;
      options.headers['X-TimeZone-Offset'] = offset.toString();

      // إضافة معلومات إضافية مفيدة
      options.headers['X-User-Locale'] = Platform.localeName; // ar_SA مثلاً

      // يمكن حفظ timezone في localStorage للاستخدام offline
      final localStorage = sl<LocalStorageService>();
      await localStorage.saveData(StorageConstants.userTimezone, timezone);
      await localStorage.saveData(StorageConstants.userTimezoneOffset, offset);

      if (kDebugMode) {
        print('📍 Timezone Headers Added:');
        print('   - X-TimeZone: $timezone');
        print('   - X-TimeZone-Offset: $offset minutes');
        print('   - X-User-Locale: ${Platform.localeName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error adding timezone headers: $e');
      }

      // محاولة استخدام القيم المحفوظة سابقاً
      try {
        final localStorage = sl<LocalStorageService>();
        final savedTimezone =
            localStorage.getData(StorageConstants.userTimezone);
        final savedOffset =
            localStorage.getData(StorageConstants.userTimezoneOffset);

        if (savedTimezone != null) {
          options.headers['X-TimeZone'] = savedTimezone.toString();
          options.headers['X-TimeZone-Offset'] = (savedOffset ?? 0).toString();
        } else {
          // Default to Yemen timezone
          options.headers['X-TimeZone'] = 'Asia/Aden';
          options.headers['X-TimeZone-Offset'] = '180'; // +3 hours in minutes
        }
      } catch (_) {
        // Last resort defaults
        options.headers['X-TimeZone'] = 'UTC';
        options.headers['X-TimeZone-Offset'] = '0';
      }
    }
  }
}

/// Interceptor that can be used when timezone context needs to be added independently from auth headers.
/// معترض يمكن استخدامه عندما تحتاج رؤوس المنطقة الزمنية إلى الإضافة بشكل مستقل عن رؤوس المصادقة.
class TimezoneInterceptor extends Interceptor {
  /// Creates a timezone-only interceptor that caches its initialization state.
  /// ينشئ معترضًا خاصًا بالمنطقة الزمنية مع تخزين حالة التهيئة.
  TimezoneInterceptor();

  /// Tracks whether timezone support has already been bootstrapped in memory.
  /// يتتبع ما إذا كانت تهيئة دعم المنطقة الزمنية قد نُفذت في الذاكرة.
  static bool _initialized = false;

  /// Adds timezone headers and platform metadata before the request leaves the device.
  /// يضيف رؤوس المنطقة الزمنية وبيانات المنصة قبل مغادرة الطلب للجهاز.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // تهيئة مرة واحدة فقط
    if (!_initialized) {
      await TimezoneHelper.initialize();
      _initialized = true;
    }

    try {
      // إضافة timezone headers
      final headers = TimezoneHelper.getTimezoneHeaders();
      options.headers.addAll(headers);

      // معلومات إضافية
      options.headers['X-App-Platform'] = Platform.operatingSystem;
      options.headers['X-App-Platform-Version'] =
          Platform.operatingSystemVersion;
    } catch (e) {
      if (kDebugMode) {
        print('Error in TimezoneInterceptor: $e');
      }
    }

    handler.next(options);
  }

  /// Optionally enriches response payloads with local-time and formatted date mirrors.
  /// يثري الاستجابات اختياريًا بنسخ محلية ومنسقة من حقول التاريخ.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // يمكن هنا معالجة التواريخ المرجعة من الخادم إذا أردت
    try {
      if (response.data is Map<String, dynamic>) {
        _convertDatesInResponse(response.data);
      } else if (response.data is List) {
        for (var item in response.data) {
          if (item is Map<String, dynamic>) {
            _convertDatesInResponse(item);
          }
        }
      }
    } catch (_) {}

    handler.next(response);
  }

  /// Scans known date fields and adds local-time and formatted copies beside them.
  /// يفحص حقول التاريخ المعروفة ويضيف نسخًا محلية ومنسقة بجانبها.
  void _convertDatesInResponse(Map<String, dynamic> data) {
    // قائمة بأسماء الحقول التي تحتوي على تواريخ
    final dateFields = [
      'createdAt', 'updatedAt', 'deletedAt',
      'startDate', 'endDate', 'date',
      'checkInDate', 'checkOutDate',
      'bookingDate', 'paymentDate',
      // أضف المزيد حسب API الخاص بك
    ];

    for (final field in dateFields) {
      if (data.containsKey(field) && data[field] != null) {
        try {
          // تحويل string إلى DateTime ثم إلى التوقيت المحلي
          if (data[field] is String) {
            final utcDate = DateTime.parse(data[field]);
            final localDate = TimezoneHelper.convertFromUtc(utcDate);
            data['${field}Local'] = localDate.toIso8601String();
            data['${field}Formatted'] = _formatDateTime(localDate);
          }
        } catch (_) {}
      }
    }
  }

  /// Formats a DateTime value as `dd/MM/yyyy HH:mm` for quick display and logging.
  /// ينسق قيمة DateTime بصيغة `dd/MM/yyyy HH:mm` للعرض السريع أو التسجيل.
  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Interceptor that surfaces backend messages when a response signals failure through `success` or `isSuccess`.
/// معترض يعرض رسائل الخادم عندما تشير الاستجابة إلى الفشل عبر `success` أو `isSuccess`.
class UserFeedbackInterceptor extends Interceptor {
  /// Creates a response interceptor that can show backend messages to end users.
  /// ينشئ معترض استجابة يمكنه عرض رسائل الخادم للمستخدم النهائي.
  UserFeedbackInterceptor();

  /// Extracts user-facing messages from a failed response and shows them unless the caller suppressed them.
  /// يستخرج الرسائل الموجهة للمستخدم من الاستجابة الفاشلة ويعرضها ما لم يطلب المستدعي كتمها.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final extra = response.requestOptions.extra;
      final data = response.data;

      if (kDebugMode) {
        print(
            '🔍 [UserFeedbackInterceptor] Response data type: ${data.runtimeType}');
      }

      if (data is Map<String, dynamic>) {
        final hasSuccessKey =
            data.containsKey('success') || data.containsKey('isSuccess');
        final bool? isSuccess =
            data['success'] as bool? ?? data['isSuccess'] as bool?;
        final String message = _extractResponseMessage(data);

        if (kDebugMode) {
          print('🔍 [UserFeedbackInterceptor] hasSuccessKey: $hasSuccessKey');
          print('🔍 [UserFeedbackInterceptor] isSuccess: $isSuccess');
          print('🔍 [UserFeedbackInterceptor] extracted message: "$message"');
          print(
              '🔍 [UserFeedbackInterceptor] suppressErrorToast: ${extra['suppressErrorToast']}');
        }

        if (hasSuccessKey && isSuccess == false) {
          final suppressed = (extra['suppressErrorToast'] == true);
          if (!suppressed && message.isNotEmpty) {
            if (kDebugMode) {
              print(
                  '✅ [UserFeedbackInterceptor] Showing error message: $message');
            }
            MessageService.showError(message);
          } else {
            if (kDebugMode) {
              print(
                  '⚠️ [UserFeedbackInterceptor] Message suppressed or empty. suppressed: $suppressed, isEmpty: ${message.isEmpty}');
            }
          }
        }
        // else if (hasSuccessKey && isSuccess == true) {
        //   final showSuccess = (extra['showSuccessToast'] == true);
        //   if (showSuccess && message.isNotEmpty) {
        //     MessageService.showSuccess(message);
        //   }
        // }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [UserFeedbackInterceptor] Error: $e');
        print('Stack trace: $stackTrace');
      }
    }

    handler.next(response);
  }
}

/// Extracts the most useful message from a backend response envelope.
/// يستخرج أوضح رسالة ممكنة من غلاف الاستجابة القادم من الخادم.
String _extractResponseMessage(Map<String, dynamic> data) {
  if (kDebugMode) {
    print('🔍 [_extractResponseMessage] Input data: $data');
  }

  // Priority 1: Check for structured validation errors before any generic message.
  final errors = data['errors'];

  if (kDebugMode) {
    print(
        '🔍 [_extractResponseMessage] errors type: ${errors.runtimeType}, value: $errors');
  }

  if (errors is List && errors.isNotEmpty) {
    // Filter out empty/null values
    final validErrors = errors
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .map((e) => e.toString().trim())
        .toList();

    if (kDebugMode) {
      print('🔍 [_extractResponseMessage] validErrors: $validErrors');
    }

    if (validErrors.isNotEmpty) {
      // If multiple errors, join them
      if (validErrors.length == 1) {
        final message = validErrors.first;
        if (kDebugMode) {
          print('✅ [_extractResponseMessage] Returning single error: $message');
        }
        return message;
      } else {
        // Format multiple errors nicely
        final message = validErrors.map((e) => '• $e').join('\n');
        if (kDebugMode) {
          print(
              '✅ [_extractResponseMessage] Returning multiple errors: $message');
        }
        return message;
      }
    }
  } else if (errors is Map && errors.isNotEmpty) {
    final List<String> messages = [];
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        messages.addAll(value
            .where((e) => e != null && e.toString().trim().isNotEmpty)
            .map((e) => e.toString().trim()));
      } else if (value != null && value.toString().trim().isNotEmpty) {
        messages.add(value.toString().trim());
      }
    });

    if (messages.isNotEmpty) {
      if (messages.length == 1) {
        final message = messages.first;
        if (kDebugMode) {
          print(
              '✅ [_extractResponseMessage] Returning single map error: $message');
        }
        return message;
      } else {
        final message = messages.map((e) => '• $e').join('\n');
        if (kDebugMode) {
          print(
              '✅ [_extractResponseMessage] Returning multiple map errors: $message');
        }
        return message;
      }
    }
  }

  // Priority 2: Fall back to a general message when no structured errors exist.
  final msg = (data['message'] ?? data['error'] ?? '').toString().trim();
  if (kDebugMode) {
    print('🔍 [_extractResponseMessage] message field: "$msg"');
  }

  if (msg.isNotEmpty) {
    // Skip generic messages if they don't add value
    final genericMessages = [
      'حدثت أخطاء متعددة',
      'حدث خطأ',
      'validation error',
      'validation failed',
    ];

    final isGeneric = genericMessages
        .any((generic) => msg.toLowerCase().contains(generic.toLowerCase()));

    if (kDebugMode) {
      print(
          '🔍 [_extractResponseMessage] isGeneric: $isGeneric, errors: $errors');
    }

    // Only return generic message if there were no errors above
    if (!isGeneric || errors == null) {
      if (kDebugMode) {
        print('✅ [_extractResponseMessage] Returning message: $msg');
      }
      return msg;
    }
  }

  if (kDebugMode) {
    print('⚠️ [_extractResponseMessage] No message found, returning empty');
  }

  return '';
}

/// Interceptor that handles failures, token refresh, and forced logout flows in one place.
/// معترض يتولى الأخطاء وتجديد الرمز وتسجيل الخروج الإجباري في مكان واحد.
class ErrorInterceptor extends Interceptor {
  /// Creates an error interceptor bound to the Dio instance used for refresh retries.
  /// ينشئ معترض أخطاء مرتبطًا بنسخة Dio المستخدمة لإعادة المحاولة بعد التجديد.
  ErrorInterceptor(this._dio);

  /// The Dio instance used to replay requests after a successful token refresh.
  /// نسخة Dio المستخدمة لإعادة إرسال الطلبات بعد نجاح تجديد الرمز.
  final Dio _dio;

  /// Guards the refresh flow so only one token refresh runs at a time.
  /// يحمي مسار التجديد بحيث لا يعمل إلا تجديد واحد في الوقت نفسه.
  static bool _isRefreshing = false;

  /// Completes when the current refresh attempt finishes, allowing waiting requests to continue.
  /// يكتمل عند انتهاء محاولة التجديد الحالية حتى تستطيع الطلبات المنتظرة المتابعة.
  static Completer<void>? _refreshCompleter;

  /// Prevents repeated logout work when multiple requests fail at the same time.
  /// يمنع تكرار منطق تسجيل الخروج عندما تفشل عدة طلبات في الوقت نفسه.
  static bool _isForceLoggingOut = false;

  /// Handles server-side failures, message surfacing, refresh retries, and the final logout fallback.
  /// يعالج أخطاء الخادم، وإظهار الرسائل، وإعادة المحاولة بعد التجديد، ثم مسار تسجيل الخروج النهائي.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final int? status = err.response?.statusCode;
    final RequestOptions requestOptions = err.requestOptions;

    final authHeader = requestOptions.headers[ApiConstants.authorization];
    final bool hasAuthHeader =
        authHeader != null && authHeader.toString().trim().isNotEmpty;

    // Skip refresh flow for specific requests (e.g., refresh endpoint itself)
    if (requestOptions.extra['skipRefresh'] == true) {
      return handler.next(err);
    }

    // Show validation/server messages globally unless suppressed
    try {
      final suppressed = (requestOptions.extra['suppressErrorToast'] == true);
      // Don't show a toast for 401; we'll refresh/redirect immediately
      if (!suppressed && status != 401) {
        final message = _extractErrorMessage(err);
        if (message.isNotEmpty) {
          MessageService.showError(message);
        }
      }
    } catch (_) {}

    // Only handle 401 Unauthorized (token refresh flow)
    if (status == 401) {
      // If the request is unauthenticated (e.g., login/register), do not run the
      // refresh/logout flow. Let the caller handle the 401 message normally.
      if (!hasAuthHeader) {
        return handler.next(err);
      }

      try {
        final localStorage = sl<LocalStorageService>();
        final String? refreshToken =
            localStorage.getData(StorageConstants.refreshToken) as String?;

        // If no refresh token, logout
        if (refreshToken == null || refreshToken.isEmpty) {
          await _forceLogout();
          // Resolve with a synthetic response to stop further error toasts
          return handler.resolve(Response(
            requestOptions: requestOptions,
            statusCode: 401,
            data: {
              'success': false,
              'message': 'انتهت صلاحية الجلسة، تم تسجيل الخروج.'
            },
          ));
        }

        // If already retried once, avoid infinite loop
        if (requestOptions.extra['retried'] == true) {
          await _forceLogout();
          return handler.resolve(Response(
            requestOptions: requestOptions,
            statusCode: 401,
            data: {
              'success': false,
              'message': 'انتهت صلاحية الجلسة، تم تسجيل الخروج.'
            },
          ));
        }

        // If a refresh is already happening, wait for it
        if (_isRefreshing) {
          try {
            await (_refreshCompleter ?? Completer<void>()
                  ..complete())
                .future;
          } catch (_) {}
        } else {
          // Start refresh
          _isRefreshing = true;
          _refreshCompleter = Completer<void>();
          try {
            await _refreshAccessToken(refreshToken);
            _refreshCompleter?.complete();
          } catch (e) {
            _refreshCompleter?.completeError(e);
            await _forceLogout();
            _isRefreshing = false;
            return handler.resolve(Response(
              requestOptions: requestOptions,
              statusCode: 401,
              data: {
                'success': false,
                'message': 'انتهت صلاحية الجلسة، تم تسجيل الخروج.'
              },
            ));
          }
          _isRefreshing = false;
        }

        // Retry the original request with updated token
        final String? newAccess =
            localStorage.getData(StorageConstants.accessToken) as String?;
        if (newAccess == null || newAccess.isEmpty) {
          await _forceLogout();
          return handler.resolve(Response(
            requestOptions: requestOptions,
            statusCode: 401,
            data: {
              'success': false,
              'message': 'انتهت صلاحية الجلسة، تم تسجيل الخروج.'
            },
          ));
        }

        final Options newOptions = Options(
          method: requestOptions.method,
          headers: {
            ...requestOptions.headers,
            ApiConstants.authorization: '${ApiConstants.bearer} $newAccess',
          },
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          followRedirects: requestOptions.followRedirects,
          validateStatus: requestOptions.validateStatus,
          receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
          extra: {
            ...requestOptions.extra,
            'retried': true,
          },
        );

        final Response response = await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: newOptions,
          cancelToken: requestOptions.cancelToken,
          onReceiveProgress: requestOptions.onReceiveProgress,
          onSendProgress: requestOptions.onSendProgress,
        );
        return handler.resolve(response);
      } catch (_) {
        await _forceLogout();
        return handler.resolve(Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {
            'success': false,
            'message': 'انتهت صلاحية الجلسة، تم تسجيل الخروج.'
          },
        ));
      }
    }

    handler.next(err);
  }

  /// Requests a new access token and throws when the refresh flow fails.
  /// يطلب رمز وصول جديدًا ويرمي استثناءً عندما يفشل مسار التجديد.
  Future<void> _refreshAccessToken(String refreshToken) async {
    final authRepository = sl<AuthRepository>();
    final result =
        await authRepository.refreshToken(refreshToken: refreshToken);
    // Throw on failure so the caller logs out immediately
    result.fold(
      (_) => throw Exception('Failed to refresh access token'),
      (_) => null,
    );
  }

  /// Clears persisted auth state, informs the user, and redirects to the login screen once.
  /// يمسح حالة المصادقة المخزنة، وينبه المستخدم، ويوجه إلى شاشة الدخول مرة واحدة.
  Future<void> _forceLogout() async {
    if (_isForceLoggingOut) return;
    _isForceLoggingOut = true;
    try {
      final authLocalDataSource = sl<AuthLocalDataSource>();
      await authLocalDataSource.clearAuthData();
    } catch (_) {}
    // Dispatch logout to trigger router redirect
    try {
      MessageService.showInfo(
          'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى');
    } catch (_) {}
    try {
      AppBloc.authBloc.add(const LogoutEvent());
      // Navigate immediately to login to avoid showing stale page/errors
      NavigationService.goToLogin();
    } catch (_) {}
    _isForceLoggingOut = false;
  }
}

/// Pulls the most specific readable message from Dio error payloads before falling back to status-code text.
/// يستخرج أوضح رسالة ممكنة من حمولة خطأ Dio ثم يعود إلى نص رموز الحالة عند الحاجة.
String _extractErrorMessage(DioException err) {
  final data = err.response?.data;
  // Backend ResultDto pattern: { success, message, errors, errorCode, ... }.
  if (data is Map<String, dynamic>) {
    // Priority 1: Prefer structured validation errors over generic text.
    final errors = data['errors'];

    if (errors is List && errors.isNotEmpty) {
      final validErrors = errors
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();

      if (validErrors.isNotEmpty) {
        if (validErrors.length == 1) {
          return validErrors.first;
        } else {
          return validErrors.map((e) => '• $e').join('\n');
        }
      }
    } else if (errors is Map && errors.isNotEmpty) {
      final List<String> messages = [];
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          messages.addAll(value
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .map((e) => e.toString().trim()));
        } else if (value != null && value.toString().trim().isNotEmpty) {
          messages.add(value.toString().trim());
        }
      });

      if (messages.isNotEmpty) {
        if (messages.length == 1) {
          return messages.first;
        } else {
          return messages.map((e) => '• $e').join('\n');
        }
      }
    }

    // Priority 2: Fall back to an explicit message when no structured errors exist.
    final explicitMessage =
        (data['message'] ?? data['error'] ?? '').toString().trim();
    if (explicitMessage.isNotEmpty) {
      // Skip generic messages if they don't add value
      final genericMessages = [
        'حدثت أخطاء متعددة',
        'حدث خطأ',
        'validation error',
        'validation failed',
      ];

      final isGeneric = genericMessages.any((generic) =>
          explicitMessage.toLowerCase().contains(generic.toLowerCase()));

      if (!isGeneric || errors == null) {
        return explicitMessage;
      }
    }
  }

  // Final fallback based on status code.
  final statusCode = err.response?.statusCode;
  switch (statusCode) {
    case 400:
      return 'طلب غير صحيح';
    case 401:
      return 'غير مصرح بالوصول';
    case 403:
      return 'ليس لديك صلاحية';
    case 404:
      return 'لم يتم العثور على البيانات';
    case 422:
      return 'البيانات المدخلة غير صحيحة';
    case 500:
      return 'خطأ في الخادم';
    case 502:
      return 'الخادم غير متاح مؤقتاً (502). يرجى المحاولة بعد قليل';
    case 503:
      return 'الخدمة غير متاحة حالياً. يرجى المحاولة لاحقاً';
    case 504:
      return 'الخادم يستغرق وقتاً أطول من المعتاد. حاول مرة أخرى';
    default:
      if (statusCode != null) {
        return 'حدث خطأ في الخادم (رمز: $statusCode)';
      }
      return err.message ?? 'حدث خطأ غير متوقع';
  }
}

/// Lightweight interceptor that prints request, response, and error traces in debug builds.
/// معترض خفيف يطبع آثار الطلب والاستجابة والخطأ في نسخ التصحيح فقط.
class LoggingInterceptor extends Interceptor {
  /// Logs outgoing requests to help trace API calls during development.
  /// يسجل الطلبات الصادرة لتسهيل تتبع استدعاءات الـ API أثناء التطوير.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  /// Logs successful responses so developers can inspect status codes and endpoints quickly.
  /// يسجل الاستجابات الناجحة حتى يتمكن المطور من مراجعة رمز الحالة والمسار بسرعة.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  /// Logs failed requests so transport or server issues are visible in debug output.
  /// يسجل الطلبات الفاشلة حتى تظهر مشاكل النقل أو الخادم في مخرجات التصحيح.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    handler.next(err);
  }
}

/// Debug interceptor that prints the effective outgoing headers without mutating the request.
/// معترض تصحيح يطبع الرؤوس الصادرة الفعلية من دون تعديل الطلب نفسه.
class RequestHeadersLoggingInterceptor extends Interceptor {
  /// Prints the resolved URL and important headers so header issues are easy to diagnose.
  /// يطبع الرابط المحلل والرؤوس المهمة حتى يسهل تشخيص مشاكل الرؤوس.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        final isAbsolute = options.path.startsWith('http://') ||
            options.path.startsWith('https://');
        final fullUrl = isAbsolute
            ? options.path
            : '${options.baseUrl}${options.path.startsWith('/') ? options.path : '/${options.path}'}';
        print('🛰️ Outgoing Request: ${options.method} $fullUrl');
        final headers = options.headers;
        final auth = headers['Authorization']?.toString() ??
            headers['authorization']?.toString() ??
            '';
        final hasAuth = auth.isNotEmpty;
        print('🔐 Authorization present: $hasAuth');
        final effectiveCt = options.contentType ??
            headers['Content-Type'] ??
            headers['content-type'];
        if (effectiveCt != null) {
          print('📎 Content-Type: $effectiveCt');
        }
        if (headers.containsKey('Accept-Language')) {
          print('🌍 Accept-Language: ${headers['Accept-Language']}');
        }
        if (headers.containsKey('X-Account-Role')) {
          print('🏷️ X-Account-Role: ${headers['X-Account-Role']}');
        }
        if (headers.containsKey('X-Property-Id')) {
          print('🏨 X-Property-Id: ${headers['X-Property-Id']}');
        }
      } catch (_) {}
    }
    handler.next(options);
  }
}
