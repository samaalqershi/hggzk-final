import 'package:dio/dio.dart';
import 'package:hggzk/core/network/api_exceptions.dart';
import '../../../../core/error/exceptions.dart' hide ApiException;
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/request_logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// يحدد العمليات الشبكية الخاصة بالمصادقة وإدارة الحساب في تطبيق العميل.
/// Declares the remote authentication and account-management calls used by the
/// client app.
abstract class AuthRemoteDataSource {
  /// يرسل طلب تسجيل الدخول التقليدي ويعيد حمولة الجلسة الجديدة.
  /// Sends the classic sign-in request and returns the new session payload.
  Future<AuthResponseModel> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe,
  });

  /// ينشئ حسابًا جديدًا ويعيد البيانات اللازمة لبدء الجلسة.
  /// Registers a new account and returns the data needed to start a session.
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  /// ينهي الجلسة الحالية من جهة الخادم.
  /// Terminates the current session on the backend.
  Future<void> logout({
    required String userId,
    required String refreshToken,
    bool logoutFromAllDevices = false,
  });

  /// يبدأ مسار استرجاع كلمة المرور للمستخدم المحدد.
  /// Starts the password-recovery flow for the targeted user.
  Future<void> resetPassword({
    required String emailOrPhone,
  });

  /// يطلب تجديد رمز الوصول باستخدام رمز التحديث الحالي.
  /// Requests a fresh access token using the current refresh token.
  Future<AuthResponseModel> refreshToken({
    required String accessToken,
    required String refreshToken,
  });

  /// ينفذ تسجيل الدخول عبر مزود اجتماعي خارجي.
  /// Performs sign-in through an external social provider.
  Future<AuthResponseModel> socialLogin({
    required String provider,
    required String token,
    String? nonce,
    String? name,
  });

  /// يجلب الملف الشخصي الحالي للمستخدم المصادق.
  /// Fetches the current profile for the authenticated user.
  Future<UserModel> getCurrentUser();

  /// يحدث البيانات الأساسية للملف الشخصي.
  /// Updates the core profile fields.
  Future<void> updateProfile({
    required String userId,
    required String name,
    String? email,
    String? phone,
  });

  /// يغير كلمة المرور الحالية للمستخدم.
  /// Changes the user's current password.
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    String? newPasswordConfirmation,
  });

  /// يحذف الحساب نهائيًا من جهة الخادم.
  /// Permanently deletes the account on the backend.
  Future<void> deleteAccount({
    required String userId,
    String? password,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
    String? reason,
  });

  /// يرفع صورة الملف الشخصي ويعيد النسخة المحدثة من المستخدم.
  /// Uploads a profile image and returns the updated user.
  Future<UserModel> uploadProfileImage({
    required String imagePath,
  });

  /// يتحقق من رمز تأكيد البريد الإلكتروني.
  /// Verifies an email confirmation code.
  Future<bool> verifyEmail({
    required String userId,
    required String code,
  });

  /// يطلب إعادة إرسال رمز تحقق البريد ويعيد زمن الانتظار إن توفر.
  /// Requests a new email-verification code and returns a retry delay when
  /// available.
  Future<int?> resendEmailVerification({
    required String userId,
    required String email,
  });
}

/// ينفذ عمليات المصادقة عبر `ApiClient` مع توحيد التسجيل التشخيصي وتحويل
/// الأخطاء إلى استثناءات مناسبة للطبقات الأعلى.
/// Implements authentication calls through `ApiClient` while standardizing
/// request logging and converting failures into higher-level exceptions.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// عميل الشبكة المركزي المستخدم لكل طلبات المصادقة.
  /// Shared API client used for all authentication requests.
  final ApiClient apiClient;

  /// ينشئ المصدر البعيد مع عميل الشبكة المعتمد.
  /// Creates the remote data source with the configured API client.
  AuthRemoteDataSourceImpl({required this.apiClient});
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
        '/api/client/auth/login',
        data: {
          'emailOrPhone': emailOrPhone,
          'password': password,
          'rememberMe': rememberMe,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      if (resultDto.success && resultDto.data != null) {
        final auth = AuthResponseModel.fromJson(resultDto.data!);
        try {
          final userResp = await apiClient.get(
            '/api/common/users/current',
            options: Options(
              headers: {
                'Authorization': 'Bearer ${auth.accessToken}',
              },
            ),
          );
          final userDto = ResultDto<Map<String, dynamic>>.fromJson(
            userResp.data,
            (json) => json,
          );
          if (userDto.success && userDto.data != null) {
            final fullUser = UserModel.fromJson(userDto.data!);
            return AuthResponseModel(
              user: fullUser,
              accessToken: auth.accessToken,
              refreshToken: auth.refreshToken,
              expiresAt: auth.expiresAt,
            );
          }
        } catch (_) {}
        return auth;
      } else {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تسجيل الدخول'),
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

  @override
  Future<void> deleteAccount({
    required String userId,
    String? password,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
    String? reason,
  }) async {
    const requestName = 'auth.deleteAccount';
    logRequestStart(requestName, details: {
      'userId': userId,
    });
    try {
      final response = await apiClient.post(
        '/api/client/auth/account/delete',
        data: {
          'userId': userId,
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

  @override
  Future<AuthResponseModel> socialLogin({
    required String provider,
    required String token,
    String? nonce,
    String? name,
  }) async {
    const requestName = 'auth.socialLogin';
    logRequestStart(requestName, details: {
      'provider': provider,
    });
    try {
      final response = await apiClient.post(
        '/api/client/auth/social-login',
        data: {
          'provider': provider,
          'token': token,
          if (nonce != null) 'nonce': nonce,
          if (name != null) 'name': name,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      if (resultDto.success && resultDto.data != null) {
        final auth = AuthResponseModel.fromJson(resultDto.data!);
        try {
          final userResp = await apiClient.get(
            '/api/common/users/current',
            options: Options(
              headers: {
                'Authorization': 'Bearer ${auth.accessToken}',
              },
            ),
          );
          final userDto = ResultDto<Map<String, dynamic>>.fromJson(
            userResp.data,
            (json) => json,
          );
          if (userDto.success && userDto.data != null) {
            final fullUser = UserModel.fromJson(userDto.data!);
            return AuthResponseModel(
              user: fullUser,
              accessToken: auth.accessToken,
              refreshToken: auth.refreshToken,
              expiresAt: auth.expiresAt,
            );
          }
        } catch (_) {}
        return auth;
      } else {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تسجيل الدخول الاجتماعي'),
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
        response.data,
        (json) => json,
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
            'skipAuth': true,
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

  @override
  Future<AuthResponseModel> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    const requestName = 'auth.refreshToken';
    logRequestStart(requestName);
    try {
      final response = await apiClient.post(
        '/api/client/auth/refresh-token',
        data: {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        },
        options: Options(
          extra: {
            'skipAuth': true,
            'skipRefresh': true,
          },
        ),
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
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

  @override
  Future<UserModel> getCurrentUser() async {
    const requestName = 'auth.getCurrentUser';
    logRequestStart(requestName);
    try {
      final response = await apiClient.get('/api/common/users/current');

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
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

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    String? email,
    String? phone,
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

  @override
  Future<UserModel> uploadProfileImage({
    required String imagePath,
  }) async {
    const requestName = 'auth.uploadProfileImage';
    logRequestStart(requestName);
    try {
      final fileName = imagePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath, filename: fileName),
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

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      if (resultDto.success) {
        return true;
      } else {
        throw ApiException(
          message: resultDto.message ??
              (resultDto.errors.isNotEmpty
                  ? resultDto.errors.join(', ')
                  : 'فشل تأكيد البريد الإلكتروني'),
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
        response.data,
        (json) => json,
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
      if (retryAfter is int) return retryAfter;
      return null;
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
