import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../injection_container.dart';

/// يعرّف الكلاس المجرد `AuthLocalDataSource`.
/// Describes the abstract `AuthLocalDataSource` class.
abstract class AuthLocalDataSource {
  /// Receives `cacheAuthResponse`.
  /// العربية: يعالج `cacheAuthResponse`.
  Future<void> cacheAuthResponse(AuthResponseModel authResponse);

  /// ينفذ العملية `getCachedAuthResponse`.
  /// Runs the `getCachedAuthResponse` operation.
  Future<AuthResponseModel?> getCachedAuthResponse();

  /// ينفذ العملية `cacheAccessToken`.
  /// Runs the `cacheAccessToken` operation.
  Future<void> cacheAccessToken(String token);

  /// ينفذ العملية `getCachedAccessToken`.
  /// Runs the `getCachedAccessToken` operation.
  Future<String?> getCachedAccessToken();

  /// ينفذ العملية `cacheRefreshToken`.
  /// Runs the `cacheRefreshToken` operation.
  Future<void> cacheRefreshToken(String token);

  /// ينفذ العملية `getCachedRefreshToken`.
  /// Runs the `getCachedRefreshToken` operation.
  Future<String?> getCachedRefreshToken();

  /// ينفذ العملية `cacheUser`.
  /// Runs the `cacheUser` operation.
  Future<void> cacheUser(UserModel user);

  /// ينفذ العملية `getCachedUser`.
  /// Runs the `getCachedUser` operation.
  Future<UserModel?> getCachedUser();

  /// ينفذ العملية `clearAuthData`.
  /// Runs the `clearAuthData` operation.
  Future<void> clearAuthData();

  /// ينفذ العملية `isLoggedIn`.
  /// Runs the `isLoggedIn` operation.
  Future<bool> isLoggedIn();

  /// ينفذ العملية `saveData`.
  /// Runs the `saveData` operation.
  Future<void> saveData(String key, dynamic value) async {}
}

/// يعرّف الكلاس `AuthLocalDataSourceImpl`.
/// Describes the `AuthLocalDataSourceImpl` class.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Holds the `sharedPreferences` value.
  /// العربية: يخزن القيمة `sharedPreferences`.
  final SharedPreferences sharedPreferences;

  /// ينشئ مثيلاً من `AuthLocalDataSourceImpl`.
  /// Builds an instance of `AuthLocalDataSourceImpl`.
  AuthLocalDataSourceImpl({required this.sharedPreferences});

  /// يخزن العضو `_authResponseKey`.
  /// Holds the `_authResponseKey` member.
  static const String _authResponseKey = 'AUTH_RESPONSE';

  /// يخزن العضو `_accessTokenKey`.
  /// Holds the `_accessTokenKey` member.
  static const String _accessTokenKey = 'ACCESS_TOKEN';

  /// يخزن العضو `_refreshTokenKey`.
  /// Holds the `_refreshTokenKey` member.
  static const String _refreshTokenKey = 'REFRESH_TOKEN';

  /// يخزن العضو `_userKey`.
  /// Holds the `_userKey` member.
  static const String _userKey = 'USER_DATA';

  /// ينفذ العملية `saveData`.
  /// Runs the `saveData` operation.
  @override
  Future<void> saveData(String key, dynamic value) async {
    try {
      if (value is String) {
        await sharedPreferences.setString(key, value);
      } else if (value is int) {
        await sharedPreferences.setInt(key, value);
      } else if (value is double) {
        await sharedPreferences.setDouble(key, value);
      } else if (value is bool) {
        await sharedPreferences.setBool(key, value);
      } else if (value is List<String>) {
        await sharedPreferences.setStringList(key, value);
      }
    } catch (e) {
      throw const CacheException('فشل حفظ البيانات');
    }
  }

  /// ينفذ العملية `cacheAuthResponse`.
  /// Runs the `cacheAuthResponse` operation.
  @override
  Future<void> cacheAuthResponse(AuthResponseModel authResponse) async {
    try {
      final jsonString = json.encode(authResponse.toJson());
      await sharedPreferences.setString(_authResponseKey, jsonString);
      await cacheAccessToken(authResponse.accessToken);
      await cacheRefreshToken(authResponse.refreshToken);
      await cacheUser(authResponse.user as UserModel);

      // keep LocalStorageService in sync for interceptors
      final localStorage = sl<LocalStorageService>();
      await localStorage.saveData(
          StorageConstants.accessToken, authResponse.accessToken);
      await localStorage.saveData(
          StorageConstants.refreshToken, authResponse.refreshToken);
      await localStorage.saveData(
          StorageConstants.userId, authResponse.user.userId);
      await localStorage.saveData(
          StorageConstants.userEmail, authResponse.user.email);
      await localStorage.saveData(StorageConstants.accountRole,
          (authResponse.user as UserModel).accountRole ?? '');
      await localStorage.saveData(StorageConstants.propertyId,
          (authResponse.user as UserModel).propertyId ?? '');
      await localStorage.saveData(StorageConstants.propertyName,
          (authResponse.user as UserModel).propertyName ?? '');
      await localStorage.saveData(StorageConstants.propertyCurrency,
          (authResponse.user as UserModel).propertyCurrency ?? '');
    } catch (e) {
      throw const CacheException('فشل حفظ بيانات المصادقة');
    }
  }

  /// ينفذ العملية `getCachedAuthResponse`.
  /// Runs the `getCachedAuthResponse` operation.
  @override
  Future<AuthResponseModel?> getCachedAuthResponse() async {
    try {
      final jsonString = sharedPreferences.getString(_authResponseKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return AuthResponseModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw const CacheException('فشل قراءة بيانات المصادقة');
    }
  }

  /// ينفذ العملية `cacheAccessToken`.
  /// Runs the `cacheAccessToken` operation.
  @override
  Future<void> cacheAccessToken(String token) async {
    try {
      await sharedPreferences.setString(_accessTokenKey, token);
      // sync
      final localStorage = sl<LocalStorageService>();
      await localStorage.saveData(StorageConstants.accessToken, token);
    } catch (e) {
      throw const CacheException('فشل حفظ رمز الوصول');
    }
  }

  /// ينفذ العملية `getCachedAccessToken`.
  /// Runs the `getCachedAccessToken` operation.
  @override
  Future<String?> getCachedAccessToken() async {
    try {
      return sharedPreferences.getString(_accessTokenKey);
    } catch (e) {
      throw const CacheException('فشل قراءة رمز الوصول');
    }
  }

  /// ينفذ العملية `cacheRefreshToken`.
  /// Runs the `cacheRefreshToken` operation.
  @override
  Future<void> cacheRefreshToken(String token) async {
    try {
      await sharedPreferences.setString(_refreshTokenKey, token);
      // sync
      final localStorage = sl<LocalStorageService>();
      await localStorage.saveData(StorageConstants.refreshToken, token);
    } catch (e) {
      throw const CacheException('فشل حفظ رمز التحديث');
    }
  }

  /// ينفذ العملية `getCachedRefreshToken`.
  /// Runs the `getCachedRefreshToken` operation.
  @override
  Future<String?> getCachedRefreshToken() async {
    try {
      return sharedPreferences.getString(_refreshTokenKey);
    } catch (e) {
      throw const CacheException('فشل قراءة رمز التحديث');
    }
  }

  /// ينفذ العملية `cacheUser`.
  /// Runs the `cacheUser` operation.
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(_userKey, jsonString);
      // sync
      final localStorage = sl<LocalStorageService>();
      await localStorage.saveData(StorageConstants.userId, user.userId);
      await localStorage.saveData(StorageConstants.userEmail, user.email);
      await localStorage.saveData(
          StorageConstants.accountRole, user.accountRole ?? '');
      await localStorage.saveData(
          StorageConstants.propertyId, user.propertyId ?? '');
      await localStorage.saveData(
          StorageConstants.propertyName, user.propertyName ?? '');
      await localStorage.saveData(
          StorageConstants.propertyCurrency, user.propertyCurrency ?? '');
    } catch (e) {
      throw const CacheException('فشل حفظ بيانات المستخدم');
    }
  }

  /// ينفذ العملية `getCachedUser`.
  /// Runs the `getCachedUser` operation.
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(_userKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw const CacheException('فشل قراءة بيانات المستخدم');
    }
  }

  /// ينفذ العملية `clearAuthData`.
  /// Runs the `clearAuthData` operation.
  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_authResponseKey),
        sharedPreferences.remove(_accessTokenKey),
        sharedPreferences.remove(_refreshTokenKey),
        sharedPreferences.remove(_userKey),
      ]);
      // sync
      final localStorage = sl<LocalStorageService>();
      await localStorage.removeData(StorageConstants.accessToken);
      await localStorage.removeData(StorageConstants.refreshToken);
      await localStorage.removeData(StorageConstants.userId);
      await localStorage.removeData(StorageConstants.userEmail);
      await localStorage.removeData(StorageConstants.accountRole);
      await localStorage.removeData(StorageConstants.propertyId);
      await localStorage.removeData(StorageConstants.propertyName);
      await localStorage.removeData(StorageConstants.propertyCurrency);
    } catch (e) {
      throw const CacheException('فشل مسح بيانات المصادقة');
    }
  }

  /// ينفذ العملية `isLoggedIn`.
  /// Runs the `isLoggedIn` operation.
  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getCachedAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
