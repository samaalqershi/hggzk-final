import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/city_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/media_file_safety.dart';
import '../../../../core/utils/video_utils.dart';

/// 🌐 Remote Data Source للمدن
abstract class CitiesRemoteDataSource {
  /// الحصول على جميع المدن
  Future<List<CityModel>> getCities();

  /// حفظ قائمة المدن (إضافة أو تحديث)
  Future<bool> saveCities(List<CityModel> cities);

  /// إضافة مدينة جديدة
  Future<String> createCity(CityModel city);

  /// تحديث مدينة موجودة
  Future<bool> updateCity(String oldName, CityModel city);

  /// حذف مدينة
  Future<bool> deleteCity(String name);

  /// البحث في المدن
  Future<List<CityModel>> searchCities(String query);

  /// الحصول على إحصائيات المدن
  Future<Map<String, dynamic>> getCitiesStatistics(
      {DateTime? startDate, DateTime? endDate});

  /// رفع صورة للمدينة
  Future<String> uploadCityImage(String cityName, String imagePath,
      {ProgressCallback? onSendProgress});

  /// حذف صورة من المدينة
  Future<bool> deleteCityImage(String imageUrl);

  /// الحصول على المدن بصفحات
  Future<PaginatedResult<CityModel>> getCitiesPaginated({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? country,
    bool? isActive,
  });
}

class CitiesRemoteDataSourceImpl implements CitiesRemoteDataSource {
  final ApiClient apiClient;

  /// 🔗 المسار الأساسي لـ API المدن
  static const String _basePath = '/api/admin/system-settings/cities';
  // لا يوجد CitiesController على الـ backend؛ نُبقي فقط على مسارات system-settings
  static const String _adminPath = '/api/admin/cities';
  static const String _imagesPath = '/api/images';

  CitiesRemoteDataSourceImpl({required this.apiClient});

  /// 📋 الحصول على جميع المدن
  @override
  Future<List<CityModel>> getCities() async {
    try {
      final response = await apiClient.get(_basePath);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => CityModel.fromJson(json)).toList();
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch cities',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 💾 حفظ قائمة المدن
  @override
  Future<bool> saveCities(List<CityModel> cities) async {
    try {
      final citiesJson = cities.map((city) => city.toJson()).toList();

      final response = await apiClient.put(
        _basePath,
        data: citiesJson,
      );

      if (response.data['success'] == true) {
        return response.data['data'] ?? false;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to save cities',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ➕ إضافة مدينة جديدة
  @override
  Future<String> createCity(CityModel city) async {
    try {
      // لا يوجد مسار لإنشاء مدينة منفردة؛ ندمجها ضمن القائمة ونحفظ عبر PUT
      final existing = await getCities();
      final updated = [...existing, city];
      final ok = await saveCities(updated);
      if (ok) {
        return city.name;
      }
      throw ApiException(message: 'Failed to create city');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ✏️ تحديث مدينة موجودة
  @override
  Future<bool> updateCity(String oldName, CityModel city) async {
    try {
      // تحديث عبر جلب القائمة وتعديل العنصر ثم PUT للقائمة كاملة
      final existing = await getCities();
      final idx = existing.indexWhere((c) => c.name == oldName);
      if (idx == -1) throw ApiException(message: 'City not found');
      final List<CityModel> updated = List.of(existing);
      updated[idx] = city;
      return await saveCities(updated);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🗑️ حذف مدينة
  @override
  Future<bool> deleteCity(String name) async {
    try {
      final response =
          await apiClient.delete('$_basePath/${Uri.encodeComponent(name)}');
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true || map['isSuccess'] == true) return true;
        // Surface backend reason if conflict
        if (response.statusCode == 409 ||
            map['errorCode'] == 'CITY_DELETE_CONFLICT') {
          throw ApiException(message: map['message'] ?? 'Deletion conflict');
        }
      }
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🔍 البحث في المدن
  @override
  Future<List<CityModel>> searchCities(String query) async {
    try {
      final all = await getCities();
      final q = query.toLowerCase();
      return all
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.country.toLowerCase().contains(q))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📊 الحصول على إحصائيات المدن
  @override
  Future<Map<String, dynamic>> getCitiesStatistics(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();
      final resp = await apiClient.get(
          '/api/admin/system-settings/cities/stats',
          queryParameters: params);
      if (resp.data is Map<String, dynamic>) {
        final map = resp.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] is Map) {
          return Map<String, dynamic>.from(map['data'] as Map);
        }
      }
      // Fallback to local calculation including totalImages
      final all = await getCities();
      final total = all.length;
      final active = all.where((c) => c.isActive ?? true).length;
      final totalImages = all.fold<int>(0, (sum, c) => sum + (c.images.length));
      final byCountry = <String, int>{};
      for (final c in all) {
        byCountry[c.country] = (byCountry[c.country] ?? 0) + 1;
      }
      return {
        'totalCities': total,
        'activeCities': active,
        'totalImages': totalImages,
        'byCountry': byCountry,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📤 رفع صورة للمدينة
  @override
  Future<String> uploadCityImage(String cityName, String imagePath,
      {ProgressCallback? onSendProgress}) async {
    try {
      final uploadFile = await MediaFileSafety.ensureStableReadableCopy(
        imagePath,
        namespace: 'cities',
      );
      if (uploadFile == null) {
        throw ApiException(message: 'تعذر الوصول إلى ملف المدينة المحدد');
      }

      // Build multipart form data explicitly to avoid filename inference issues
      final formData = FormData();
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          uploadFile.path,
          filename: MediaFileSafety.basename(uploadFile.path),
        ),
      ));
      formData.fields
        ..add(const MapEntry('category', 'Gallery'))
        ..add(MapEntry('cityName', cityName));

      // If uploading a video, attach a generated poster too
      if (AppConstants.isVideoFile(uploadFile.path)) {
        final posterPath =
            await VideoUtils.generateVideoThumbnail(uploadFile.path);
        final posterFile = posterPath == null
            ? null
            : await MediaFileSafety.resolveReadableFile(posterPath);
        if (posterFile != null) {
          formData.files.add(MapEntry(
            'videoThumbnail',
            await MultipartFile.fromFile(
              posterFile.path,
              filename: MediaFileSafety.basename(posterFile.path),
            ),
          ));
        }
      }

      final response = await apiClient.post(
        '$_imagesPath/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true) {
          final data = map['image'] ?? map['data'];
          if (data is Map && data['url'] != null) {
            return data['url'] as String;
          }
        }
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload image',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🗑️ حذف صورة من المدينة
  @override
  Future<bool> deleteCityImage(String imageUrl) async {
    try {
      // محاولة إيجاد صورة عبر GET /api/images ثم حذفها عبر ID
      String normalizeToPath(String url) {
        final trimmed = (url).trim();
        try {
          final uri = Uri.parse(trimmed);
          final path = uri.path.isEmpty ? trimmed : uri.path;
          final unescaped = Uri.decodeFull(path);
          return unescaped.startsWith('/') ? unescaped : '/$unescaped';
        } catch (_) {
          final unescaped = Uri.decodeFull(trimmed);
          return unescaped.startsWith('/') ? unescaped : '/$unescaped';
        }
      }

      String basename(String path) {
        final p = normalizeToPath(path);
        final idx = p.lastIndexOf('/');
        if (idx == -1) return p;
        return p.substring(idx + 1);
      }

      final inputPath = normalizeToPath(imageUrl);
      final fileName = basename(inputPath);

      Future<List<dynamic>> fetchImages(String? searchTerm) async {
        final qp = <String, dynamic>{
          'page': 1,
          'limit': 100,
        };
        if (searchTerm != null && searchTerm.isNotEmpty) {
          qp['search'] = searchTerm;
        }
        final resp = await apiClient.get(_imagesPath, queryParameters: qp);
        if (resp.data is Map<String, dynamic>) {
          final map = resp.data as Map<String, dynamic>;
          return (map['images'] as List?) ??
              (map['items'] as List?) ??
              const [];
        }
        return const [];
      }

      // 1) جرّب بالاسم فقط لزيادة فرصة التطابق عبر Contains في الـ backend
      List<dynamic> images = await fetchImages(fileName);
      // 2) إن لم نجد، جرّب المسار كاملاً بدون النطاق
      if (images.isEmpty) {
        images = await fetchImages(inputPath);
      }
      // 3) كملاذ أخير، اجلب أول صفحة بدون بحث
      if (images.isEmpty) {
        images = await fetchImages(null);
      }

      // طابق بدقة مع مراعاة اختلاف النطاق والترميز
      Map<String, dynamic>? match;
      for (final raw in images) {
        if (raw is! Map<String, dynamic>) continue;
        final candidateUrl = (raw['url'] ?? '').toString();
        final candidatePath = normalizeToPath(candidateUrl);
        final isEqual = candidateUrl == imageUrl ||
            candidatePath == inputPath ||
            candidateUrl.endsWith(inputPath);
        if (isEqual) {
          match = raw;
          break;
        }
      }
      if (match != null && match['id'] != null) {
        final id = match['id'].toString();
        final del = await apiClient.delete('$_imagesPath/$id');
        return del.data is Map && del.data['success'] == true ||
            del.statusCode == 204;
      }
      return false;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📑 الحصول على المدن بصفحات
  @override
  Future<PaginatedResult<CityModel>> getCitiesPaginated({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? country,
    bool? isActive,
  }) async {
    try {
      final all = await getCities();
      List<CityModel> filtered = all;
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        filtered = filtered
            .where((c) =>
                c.name.toLowerCase().contains(s) ||
                c.country.toLowerCase().contains(s))
            .toList();
      }
      if (country != null && country.isNotEmpty) {
        final c = country.toLowerCase();
        filtered = filtered.where((x) => x.country.toLowerCase() == c).toList();
      }
      if (isActive != null) {
        filtered =
            filtered.where((x) => (x.isActive ?? true) == isActive).toList();
      }
      final pn = (pageNumber ?? 1) < 1 ? 1 : (pageNumber ?? 1);
      final ps = (pageSize ?? 20) <= 0 ? 20 : (pageSize ?? 20);
      final start = (pn - 1) * ps;
      final end =
          (start + ps) > filtered.length ? filtered.length : (start + ps);
      final pageItems = start < filtered.length
          ? filtered.sublist(start, end)
          : <CityModel>[];
      return PaginatedResult(
        items: pageItems,
        pageNumber: pn,
        pageSize: ps,
        totalCount: filtered.length,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
