import 'package:dio/dio.dart';
import 'package:hggzkportal/core/network/api_exceptions.dart';
import '../../../../core/error/exceptions.dart' hide ApiException;
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/media_file_safety.dart';
import '../../../../core/utils/request_logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// عقد مصدر البيانات البعيد الخاص بعمليات المصادقة والتفويض.
/// Describes the remote authentication contract used by repositories.
abstract class AuthRemoteDataSource {
  /// يسجل دخول المستخدم باستخدام البريد الإلكتروني أو رقم الهاتف.
  /// Signs the user in using an email address or phone number.
  Future<AuthResponseModel> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe,
  });

  /// ينشئ حساب مستخدم جديد عبر واجهة التسجيل العامة.
  /// Initializes a new user account through the public registration flow.
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  /// ينهي الجلسة الحالية أو جميع الجلسات المرتبطة بالمستخدم.
  /// Logs the user out from the current session or all sessions.
  Future<void> logout({
    required String userId,
    required String refreshToken,
    bool logoutFromAllDevices = false,
  });

  /// يطلب بدء عملية إعادة تعيين كلمة المرور.
  /// Requests the password reset flow for the provided identity.
  Future<void> resetPassword({
    required String emailOrPhone,
  });

  /// يجدد رموز الوصول والتحديث للجلسة الحالية.
  /// Refreshes the session access and refresh tokens.
  Future<AuthResponseModel> refreshToken({
    required String accessToken,
    required String refreshToken,
  });

  /// يجلب المستخدم الحالي من الخادم.
  /// Fetches the currently authenticated user from the backend.
  Future<UserModel> getCurrentUser();

  /// يحدث الملف الشخصي وبيانات العقار المرافقة عند الحاجة.
  /// Updates the user profile and optional property-related fields.
  Future<void> updateProfile({
    required String userId,
    required String name,
    String? email,
    String? phone,
    List<Map<String, dynamic>>? walletAccounts,
    // Owner's property fields (optional; sent alongside profile)
    String? propertyId,
    String? propertyName,
    String? propertyAddress,
    String? propertyCity,
    String? propertyShortDescription,
    String? propertyDescription,
    String? propertyCurrency,
    int? propertyStarRating,
    double? propertyLatitude,
    double? propertyLongitude,
  });

  /// يغير كلمة مرور المستخدم الحالية.
  /// Changes the current user's password.
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    String? newPasswordConfirmation,
  });

  /// يرفع صورة الملف الشخصي ويعيد بيانات المستخدم المحدثة.
  /// Uploads a profile image and returns the updated user model.
  Future<UserModel> uploadProfileImage({
    required String imagePath,
  });

  /// يؤكد البريد الإلكتروني باستخدام رمز التحقق المستلم.
  /// Verifies the email address using the submitted verification code.
  Future<bool> verifyEmail({
    required String userId,
    required String code,
  });

  /// يعيد إرسال رمز التحقق للبريد الإلكتروني.
  /// Resends the email verification code and returns cooldown seconds.
  Future<int?> resendEmailVerification({
    required String userId,
    required String email,
  });

  /// يسجل مالك عقار جديداً مع إنشاء عقار مرتبط بالحساب.
  /// Registers a new property owner and creates the linked property.
  Future<AuthResponseModel> registerOwnerWithProperty({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String propertyTypeId,
    required String propertyName,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    int starRating = 3,
    String? description,
    String? currency,
    List<Map<String, dynamic>>? walletAccounts,
  });

  /// يسجل الدخول الاجتماعي المخصص لتطبيق البوابة.
  /// Performs the portal-specific social login flow.
  Future<AuthResponseModel> portalSocialLogin({
    required String provider,
    required String token,
    String? nonce,
    String? name,
  });

  /// يكمل بيانات مالك العقار بعد التسجيل أو الدخول الاجتماعي.
  /// Completes the owner profile after sign-up or social login.
  Future<AuthResponseModel> completeOwnerProfile({
    required String name,
    required String phone,
    required String propertyTypeId,
    required String propertyName,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    int starRating = 3,
    String? description,
    String? currency,
    List<Map<String, dynamic>>? walletAccounts,
  });

  /// يحذف حساب مالك العقار مع تمرير بيانات التأكيد المطلوبة.
  /// Deletes the owner account with the required confirmation data.
  Future<void> deleteOwnerAccount({
    String? password,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
    String? reason,
  });
}

/// تنفيذ API لعمليات المصادقة المعتمدة على `ApiClient`.
/// API-backed implementation of the authentication remote datasource.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// عميل HTTP الموحد للتعامل مع واجهات الخادم.
  /// Shared HTTP client used to talk to backend endpoints.
  final ApiClient apiClient;

  /// ينشئ مصدر بيانات مصادقة عن بعد اعتماداً على عميل API موحد.
  /// Builds the remote auth datasource with the shared API client.
  AuthRemoteDataSourceImpl({required this.apiClient});

  /// ينفذ العملية `deleteOwnerAccount`.
  /// Runs the `deleteOwnerAccount` operation.
  @override
  Future<void> deleteOwnerAccount({
    String? password,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
    String? reason,
  }) async {
    const requestName = 'auth.deleteOwnerAccount';
    logRequestStart(requestName);
    try {
      final response = await apiClient.post(
        '/api/common/auth/account/delete',
        data: {
          if (password != null && password.trim().isNotEmpty)
            'password': password,
          if (socialProvider != null && socialProvider.trim().isNotEmpty)
            'socialProvider': socialProvider,
          if (socialToken != null && socialToken.trim().isNotEmpty)
            'socialToken': socialToken,
          if (socialNonce != null && socialNonce.trim().isNotEmpty)
            'socialNonce': socialNonce,
          if (reason != null) 'reason': reason,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDtoVoid.fromJson(response.data);
      if (!resultDto.success) {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل حذف الحساب'),
          statusCode: response.statusCode,
          data: resultDto.errors,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `login`.
  /// Runs the `login` operation.
  @override
  Future<AuthResponseModel> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe,
  }) async {
    const requestName = 'auth.login';
    logRequestStart(requestName, details: {
      'emailOrPhone': emailOrPhone,
      'rememberMe': rememberMe,
    });
    try {
      final response = await apiClient.post(
        '/api/common/auth/login',
        data: {
          // backend common login uses Email/Password
          'email': emailOrPhone,
          'password': password,
          'rememberMe': rememberMe,
        },
        // Login page already handles errors via AuthBloc; avoid duplicate global toasts.
        options: Options(
          extra: {
            'suppressErrorToast': true,
          },
        ),
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return AuthResponseModel.fromJson(resultDto.data!);
      } else {
        // UserFeedbackInterceptor already showed the error message to user
        // Just throw exception for business logic handling without noisy logging
        final errorMessage = resultDto.message ??
            (resultDto.errors.isNotEmpty
                ? resultDto.errors.join(', ')
                : 'فشل تسجيل الدخول');

        logRequestError(requestName, errorMessage, stackTrace: null);

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          data: resultDto.errors,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      // Only log stack trace for unexpected exceptions, not business logic failures
      if (e is! ApiException) {
        logRequestError(requestName, e, stackTrace: s);
      }
      if (e is ServerException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `verifyEmail`.
  /// Runs the `verifyEmail` operation.
  @override
  Future<bool> verifyEmail({
    required String userId,
    required String code,
  }) async {
    const requestName = 'auth.verifyEmail';
    logRequestStart(requestName);
    try {
      final response = await apiClient.post(
        '/api/client/auth/verify-email',
        data: {
          'userId': userId,
          'verificationToken': code,
        },
      );
      logRequestSuccess(requestName, statusCode: response.statusCode);
      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );
      if (result.success) {
        return true;
      }

      throw ApiException(
        message: result.message ??
            (result.errors.isNotEmpty
                ? result.errors.join(', ')
                : 'فشل تأكيد البريد الإلكتروني'),
        statusCode: response.statusCode,
        data: result.errors,
        code: result.errorCode ?? result.code,
      );
    } on DioException catch (e) {
      logRequestError(requestName, e);
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `resendEmailVerification`.
  /// Runs the `resendEmailVerification` operation.
  @override
  Future<int?> resendEmailVerification({
    required String userId,
    required String email,
  }) async {
    const requestName = 'auth.resendEmailVerification';
    logRequestStart(requestName);
    try {
      final response = await apiClient.post(
        '/api/client/auth/resend-email-verification',
        data: {
          'userId': userId,
          'email': email,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (!resultDto.success) {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل إعادة إرسال رمز التحقق'),
          statusCode: response.statusCode,
          data: resultDto.errors,
        );
      }

      final data = resultDto.data ?? const {};
      final retryAfter = data['retryAfterSeconds'];
      return retryAfter is int ? retryAfter : null;
    } on DioException catch (e) {
      logRequestError(requestName, e);
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      logRequestError(requestName, e);
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `register`.
  /// Runs the `register` operation.
  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    const requestName = 'auth.register';
    logRequestStart(requestName, details: {
      'name': name,
      'email': email,
      'phone': phone,
    });
    try {
      final response = await apiClient.post(
        '/api/client/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return AuthResponseModel.fromJson(resultDto.data!);
      } else {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل إنشاء الحساب'),
          statusCode: response.statusCode,
          data: resultDto.errors,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `portalSocialLogin`.
  /// Runs the `portalSocialLogin` operation.
  @override
  Future<AuthResponseModel> portalSocialLogin({
    required String provider,
    required String token,
    String? nonce,
    String? name,
  }) async {
    const requestName = 'auth.portalSocialLogin';
    logRequestStart(requestName, details: {
      'provider': provider,
    });
    try {
      final response = await apiClient.post(
        '/api/common/auth/portal-social-login',
        data: {
          'provider': provider,
          'token': token,
          if (nonce != null) 'nonce': nonce,
          if (name != null) 'name': name,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return AuthResponseModel.fromJson(resultDto.data!);
      }

      throw ApiException(
        message: resultDto.message ??
            (resultDto.errors.isNotEmpty
                ? resultDto.errors.join(', ')
                : 'فشل تسجيل الدخول عبر حساب التواصل الاجتماعي'),
        statusCode: response.statusCode,
        data: resultDto.errors,
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `completeOwnerProfile`.
  /// Runs the `completeOwnerProfile` operation.
  @override
  Future<AuthResponseModel> completeOwnerProfile({
    required String name,
    required String phone,
    required String propertyTypeId,
    required String propertyName,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    int starRating = 3,
    String? description,
    String? currency,
    List<Map<String, dynamic>>? walletAccounts,
  }) async {
    const requestName = 'auth.completeOwnerProfile';
    logRequestStart(requestName, details: {
      'name': name,
      'phone': phone,
      'propertyName': propertyName,
      'city': city,
    });
    try {
      final response = await apiClient.post(
        '/api/common/auth/complete-owner-profile',
        data: {
          'name': name,
          'phone': phone,
          'propertyTypeId': propertyTypeId,
          'propertyName': propertyName,
          'city': city,
          'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'starRating': starRating,
          if (description != null) 'description': description,
          if (currency != null) 'currency': currency,
          if (walletAccounts != null) 'walletAccounts': walletAccounts,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return AuthResponseModel.fromJson(resultDto.data!);
      }

      throw ApiException(
        message: resultDto.message ??
            (resultDto.errors.isNotEmpty
                ? resultDto.errors.join(', ')
                : 'فشل استكمال بيانات المالك'),
        statusCode: response.statusCode,
        data: resultDto.errors,
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `logout`.
  /// Runs the `logout` operation.
  @override
  Future<void> logout({
    required String userId,
    required String refreshToken,
    bool logoutFromAllDevices = false,
  }) async {
    const requestName = 'auth.logout';
    logRequestStart(requestName, details: {
      'userId': userId,
      'logoutFromAllDevices': logoutFromAllDevices,
    });
    try {
      final response = await apiClient.post(
        '/api/client/auth/logout',
        data: {
          'userId': userId,
          'refreshToken': refreshToken,
          'logoutFromAllDevices': logoutFromAllDevices,
        },
        options: Options(
          extra: {
            'skipRefresh': true,
          },
        ),
      );
      logRequestSuccess(requestName, statusCode: response.statusCode);
      final resultDto = ResultDtoVoid.fromJson(response.data);
      if (!resultDto.success) {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تسجيل الخروج'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `resetPassword`.
  /// Runs the `resetPassword` operation.
  @override
  Future<void> resetPassword({required String emailOrPhone}) async {
    const requestName = 'auth.resetPassword';
    logRequestStart(requestName, details: {
      'emailOrPhone': emailOrPhone,
    });
    try {
      final response = await apiClient.post(
        '/api/client/auth/request-password-reset',
        data: {
          'emailOrPhone': emailOrPhone,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDtoVoid.fromJson(response.data);

      if (!resultDto.success) {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل إرسال رابط إعادة تعيين كلمة المرور'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `refreshToken`.
  /// Runs the `refreshToken` operation.
  @override
  Future<AuthResponseModel> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    const requestName = 'auth.refreshToken';
    logRequestStart(requestName);
    try {
      final response = await apiClient.post(
        '/api/common/auth/refresh-token',
        data: {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        },
        options: Options(
          extra: {
            'skipAuth': true,
            'skipRefresh': true,
            'suppressErrorLog': true,
          },
        ),
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return AuthResponseModel.fromJson(resultDto.data!);
      } else {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تحديث الجلسة'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `getCurrentUser`.
  /// Runs the `getCurrentUser` operation.
  @override
  Future<UserModel> getCurrentUser() async {
    const requestName = 'auth.getCurrentUser';
    logRequestStart(requestName);
    try {
      final response = await apiClient.get('/api/common/users/current');

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return UserModel.fromJson(resultDto.data!);
      } else {
        final String message = resultDto.message ??
            (resultDto.errors.isNotEmpty
                ? resultDto.errors.join(', ')
                : 'فشل جلب المستخدم الحالي');
        throw ApiException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `updateProfile`.
  /// Runs the `updateProfile` operation.
  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    String? email,
    String? phone,
    List<Map<String, dynamic>>? walletAccounts,
    String? propertyId,
    String? propertyName,
    String? propertyAddress,
    String? propertyCity,
    String? propertyShortDescription,
    String? propertyDescription,
    String? propertyCurrency,
    int? propertyStarRating,
    double? propertyLatitude,
    double? propertyLongitude,
  }) async {
    const requestName = 'auth.updateProfile';
    logRequestStart(requestName, details: {
      'userId': userId,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    });
    try {
      final data = <String, dynamic>{
        'userId': userId,
        'name': name,
      };

      if (phone != null) data['phone'] = phone;
      if (email != null)
        data['email'] = email; // if backend accepts in this endpoint

      // Owner's property fields in same payload
      if (propertyId != null) data['propertyId'] = propertyId;
      if (propertyName != null) data['propertyName'] = propertyName;
      if (propertyAddress != null) data['propertyAddress'] = propertyAddress;
      if (propertyCity != null) data['propertyCity'] = propertyCity;
      if (propertyShortDescription != null)
        data['propertyShortDescription'] = propertyShortDescription;
      if (propertyDescription != null)
        data['propertyDescription'] = propertyDescription;
      if (propertyCurrency != null) data['propertyCurrency'] = propertyCurrency;
      if (propertyStarRating != null)
        data['propertyStarRating'] = propertyStarRating;
      if (propertyLatitude != null) data['propertyLatitude'] = propertyLatitude;
      if (propertyLongitude != null)
        data['propertyLongitude'] = propertyLongitude;
      if (email != null) data['email'] = email;
      if (walletAccounts != null) data['walletAccounts'] = walletAccounts;

      final response = await apiClient.put(
        '/api/client/auth/profile',
        data: data,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDtoVoid.fromJson(response.data);

      if (!resultDto.success) {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تحديث الملف الشخصي'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `changePassword`.
  /// Runs the `changePassword` operation.
  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    String? newPasswordConfirmation,
  }) async {
    const requestName = 'auth.changePassword';
    logRequestStart(requestName, details: {
      'userId': userId,
    });
    try {
      final response = await apiClient.post(
        '/api/client/auth/change-password',
        data: {
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDtoVoid.fromJson(response.data);

      if (!resultDto.success) {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تغيير كلمة المرور'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `uploadProfileImage`.
  /// Runs the `uploadProfileImage` operation.
  @override
  Future<UserModel> uploadProfileImage({
    required String imagePath,
  }) async {
    const requestName = 'auth.uploadProfileImage';
    logRequestStart(requestName);
    try {
      final imageFile = await MediaFileSafety.ensureStableReadableCopy(
        imagePath,
        namespace: 'profile_images',
      );
      if (imageFile == null) {
        throw ApiException(message: 'تعذر الوصول إلى صورة الملف الشخصي');
      }

      final fileName = MediaFileSafety.basename(imageFile.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'category': 'profile',
      });

      final response = await apiClient.upload(
        '/api/client/auth/profile/image',
        formData: formData,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);
      // The upload endpoint returns only the new image URL; fetch the full, updated user
      // to keep the app's state consistent with backend.
      final updatedUser = await getCurrentUser();
      return updatedUser;
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// ينفذ العملية `registerOwnerWithProperty`.
  /// Runs the `registerOwnerWithProperty` operation.
  @override
  Future<AuthResponseModel> registerOwnerWithProperty({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String propertyTypeId,
    required String propertyName,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    int starRating = 3,
    String? description,
    String? currency,
    List<Map<String, dynamic>>? walletAccounts,
  }) async {
    const requestName = 'auth.registerOwnerWithProperty';
    logRequestStart(requestName, details: {
      'name': name,
      'email': email,
      'phone': phone,
      'propertyName': propertyName,
      'city': city,
    });
    try {
      final response = await apiClient.post(
        '/api/admin/Users/register-owner',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'propertyTypeId': propertyTypeId,
          'propertyName': propertyName,
          'city': city,
          'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'starRating': starRating,
          if (description != null) 'description': description,
          if (currency != null) 'currency': currency,
          if (walletAccounts != null) 'walletAccounts': walletAccounts,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
        (json) => json as Map<String, dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        final data = resultDto.data!;
        // Build AuthResponseModel from the register-owner response
        return AuthResponseModel(
          user: UserModel(
            userId: (data['userId'] ?? '').toString(),
            name: data['userName'] ?? name,
            email: data['email'] ?? email,
            phone: phone,
            roles: ['Owner'],
            accountRole: 'Owner',
            propertyId: (data['propertyId'] ?? '').toString(),
            propertyName: data['propertyName'] ?? propertyName,
            propertyCurrency: data['propertyCurrency'] ?? currency ?? 'YER',
            profileImage: null,
            emailVerifiedAt: null,
            phoneVerifiedAt: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: data['accessToken'] ?? '',
          refreshToken: data['refreshToken'] ?? '',
          expiresAt: data['accessTokenExpiry'] != null
              ? DateTime.tryParse(data['accessTokenExpiry'].toString())
              : DateTime.now().add(const Duration(hours: 1)),
        );
      } else {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل إنشاء حساب المالك'),
          statusCode: response.statusCode,
          data: resultDto.errors,
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
