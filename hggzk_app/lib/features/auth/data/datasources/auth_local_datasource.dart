import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../../../core/constants/storage_constants.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';

/// يعرّف عمليات التخزين المحلي اللازمة لاستئناف الجلسة واسترجاع بيانات
/// المصادقة من دون الرجوع إلى الشبكة.
/// Defines the local-storage operations required to resume a session and read
/// auth data without hitting the network.
abstract class AuthLocalDataSource {
  /// يخزن حمولة المصادقة الكاملة لاستخدامها لاحقًا.
  /// Stores the complete authentication payload for later reuse.
  Future<void> cacheAuthResponse(AuthResponseModel authResponse);

  /// يعيد حمولة المصادقة المخزنة إن وجدت.
  /// Returns the cached authentication payload when available.
  Future<AuthResponseModel?> getCachedAuthResponse();

  /// يخزن رمز الوصول منفصلًا للاستخدام السريع.
  /// Stores the access token separately for quick lookup.
  Future<void> cacheAccessToken(String token);

  /// يعيد رمز الوصول المخزن محليًا.
  /// Returns the locally cached access token.
  Future<String?> getCachedAccessToken();

  /// يخزن رمز التحديث ليستعمل عند تجديد الجلسة.
  /// Stores the refresh token used for session renewal.
  Future<void> cacheRefreshToken(String token);

  /// يعيد رمز التحديث المخزن.
  /// Returns the cached refresh token.
  Future<String?> getCachedRefreshToken();

  /// يخزن ملف المستخدم الحالي محليًا.
  /// Caches the current user profile locally.
  Future<void> cacheUser(UserModel user);

  /// يعيد ملف المستخدم المخزن إن وجد.
  /// Returns the cached user profile when one exists.
  Future<UserModel?> getCachedUser();

  /// يمسح كل بيانات المصادقة من التخزين المحلي.
  /// Clears all authentication data from local storage.
  Future<void> clearAuthData();

  /// يحدد ما إذا كانت هناك مؤشرات محلية كافية على وجود جلسة.
  /// Indicates whether local storage suggests an active session exists.
  Future<bool> isLoggedIn();

  /// يحفظ قيمة عامة باستخدام المفتاح المحدد عندما تحتاج طبقات أخرى ذلك.
  /// Saves a generic value by key for cases where auth storage shares helper
  /// behavior with other layers.
  Future<void> saveData(String key, dynamic value) async {}
}

/// ينفذ تخزين بيانات المصادقة عبر `SharedPreferences` مع مزامنة بعض القيم
/// المهمة إلى خدمة التخزين المشتركة المستخدمة داخل التطبيق.
/// Implements auth caching through `SharedPreferences` while mirroring key
/// values into the shared storage service used elsewhere in the app.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// مقبض التخزين المحلي الأساسي المستخدم لقراءة القيم وحفظها.
  /// Primary local-storage handle used to read and persist values.
  final SharedPreferences sharedPreferences;

  /// ينشئ المصدر المحلي مع مقبض التخزين الجاهز للاستخدام.
  /// Creates the local data source with the ready-to-use storage handle.
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  static const String _authResponseKey = 'AUTH_RESPONSE';
  static const String _accessTokenKey = 'ACCESS_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _userKey = 'USER_DATA';
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
    } catch (e) {
      throw const CacheException('فشل حفظ بيانات المصادقة');
    }
  }

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

  @override
  Future<String?> getCachedAccessToken() async {
    try {
      return sharedPreferences.getString(_accessTokenKey);
    } catch (e) {
      throw const CacheException('فشل قراءة رمز الوصول');
    }
  }

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

  @override
  Future<String?> getCachedRefreshToken() async {
    try {
      return sharedPreferences.getString(_refreshTokenKey);
    } catch (e) {
      throw const CacheException('فشل قراءة رمز التحديث');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(_userKey, jsonString);
      // sync
      final localStorage = sl<LocalStorageService>();
      await localStorage.saveData(StorageConstants.userId, user.userId);
      await localStorage.saveData(StorageConstants.userEmail, user.email);
    } catch (e) {
      throw const CacheException('فشل حفظ بيانات المستخدم');
    }
  }

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
    } catch (e) {
      throw const CacheException('فشل مسح بيانات المصادقة');
    }
  }

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
