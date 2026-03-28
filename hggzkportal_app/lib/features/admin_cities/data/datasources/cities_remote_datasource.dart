import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/city_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/media_file_safety.dart';
import '../../../../core/utils/video_utils.dart';

/// يعرّف العمليات البعيدة المسؤولة عن دورة إدارة المدن في لوحة التحكم،
/// بما يشمل القراءة، الحفظ، البحث، الإحصاءات، ووسائط المدينة.
/// Defines the remote operations that power the admin city-management flow,
/// including reads, saves, search, statistics, and city media handling.
abstract class CitiesRemoteDataSource {
  /// يجلب القائمة الكاملة للمدن كما يعتمدها نظام الإعدادات في الخادم.
  /// Fetches the full city list exactly as maintained by the backend settings
  /// workflow.
  Future<List<CityModel>> getCities();

  /// يحفظ اللقطة الكاملة الحالية للمدن بعد تعديلها في لوحة التحكم، سواء كان
  /// التغيير إضافة أو تحديثًا أو إعادة تنظيم.
  /// Persists the current full city snapshot after admin edits, whether the
  /// change was a create, update, or broader reorganization.
  Future<bool> saveCities(List<CityModel> cities);

  /// ينشئ مدينة جديدة ضمن الكتالوج الإداري ويعيد الاسم الذي اعتُمد بعد الحفظ.
  /// Creates a new city inside the admin catalog and returns the name that was
  /// ultimately persisted.
  Future<String> createCity(CityModel city);

  /// يحدّث مدينة موجودة بالاستناد إلى اسمها السابق حتى يمكن التعامل مع
  /// حالات تغيير الاسم نفسه.
  /// Updates an existing city by referencing its previous name so rename
  /// scenarios can be handled safely.
  Future<bool> updateCity(String oldName, CityModel city);

  /// يحذف مدينة من النظام عندما يسمح الخادم بالإزالة ولا توجد تبعيات تمنعها.
  /// Deletes a city when the backend allows removal and no dependency blocks
  /// the operation.
  Future<bool> deleteCity(String name);

  /// يبحث في المدن بالاعتماد على الاسم أو الدولة لتغذية الفلاتر والجداول
  /// الإدارية السريعة.
  /// Searches cities by name or country to support quick admin filters and
  /// management tables.
  Future<List<CityModel>> searchCities(String query);

  /// يجلب ملخصًا إحصائيًا عن المدن خلال نطاق زمني اختياري لعرض المؤشرات
  /// الإدارية أو التقارير السريعة.
  /// Retrieves an aggregate city summary for an optional time range so admin
  /// dashboards and quick reports can render their metrics.
  Future<Map<String, dynamic>> getCitiesStatistics(
      {DateTime? startDate, DateTime? endDate});

  /// يرفع صورة أو فيديو مرتبطًا بمدينة ويعيد الرابط النهائي الذي سيُحفظ داخل
  /// بياناتها.
  /// Uploads city-related media and returns the final URL that should be stored
  /// in the city payload.
  Future<String> uploadCityImage(String cityName, String imagePath,
      {ProgressCallback? onSendProgress});

  /// يحذف صورة مرتبطة بمدينة بعد مطابقة الرابط مع السجل الفعلي داخل خدمة
  /// الوسائط.
  /// Deletes a city image after matching the provided URL to the actual record
  /// stored in the media service.
  Future<bool> deleteCityImage(String imageUrl);

  /// يقسم المدن إلى صفحات بعد تطبيق معايير البحث والدولة والحالة لتغذية
  /// الجداول الإدارية الكبيرة.
  /// Produces a paginated city slice after applying search, country, and
  /// activity filters for large admin tables.
  Future<PaginatedResult<CityModel>> getCitiesPaginated({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? country,
    bool? isActive,
  });
}

/// ينفذ التكامل الفعلي مع واجهات خادم المدن، مع بدائل عملية عندما يكون
/// الـ backend مبنيًا على تحديث القائمة كاملة بدل نقاط CRUD مستقلة.
/// Implements the actual city API integration, including pragmatic fallbacks
/// when the backend favors whole-list updates over dedicated CRUD endpoints.
class CitiesRemoteDataSourceImpl implements CitiesRemoteDataSource {
  /// عميل الشبكة الذي ينفذ الطلبات ويحوّل أخطاء Dio إلى أخطاء نطاقية مفهومة.
  /// Network client that executes requests and translates Dio failures into
  /// domain-level exceptions.
  final ApiClient apiClient;

  /// المسار الأساسي الذي يستخدمه نظام الإعدادات لحفظ وإدارة المدن.
  /// Base path used by the system-settings backend for city management.
  static const String _basePath = '/api/admin/system-settings/cities';
  // The backend exposes city actions via system settings rather than a dedicated controller.

  /// المسار الموحد لخدمة الصور التي تخزن وسائط المدن.
  /// Shared media endpoint used to store city-related images and videos.
  static const String _imagesPath = '/api/images';

  /// يربط مصدر البيانات البعيد بعميل الشبكة المشترك مع بقية لوحة التحكم.
  /// Binds the remote datasource to the API client shared across the dashboard.
  CitiesRemoteDataSourceImpl({required this.apiClient});

  /// يجلب جميع المدن كما يعرضها الخادم في إعدادات النظام الحالية.
  /// Loads every city currently exposed by the backend system settings.
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

  /// يرسل القائمة الكاملة إلى الخادم لأن البنية الحالية تحفظ المدن عبر
  /// تحديث جماعي بدلاً من تحديث عنصر منفرد.
  /// Sends the full collection to the backend because the current contract
  /// persists cities through bulk updates rather than item-level endpoints.
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

  /// يضيف مدينة جديدة عبر دمجها مع القائمة الحالية ثم إعادة حفظ المجموعة
  /// كاملة بما يتوافق مع شكل الـ backend.
  /// Adds a city by merging it into the current list and re-saving the entire
  /// collection to match the backend contract.
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

  /// يحدّث مدينة قائمة عبر استبدالها داخل القائمة ثم رفع النسخة الكاملة
  /// المعدلة إلى الخادم.
  /// Updates an existing city by replacing it inside the list and then sending
  /// the modified full collection back to the backend.
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

  /// يحذف مدينة بالاسم بعد ترميز المسار، مع تمرير سبب التعارض إذا منع الخادم
  /// الحذف لوجود تبعيات مرتبطة.
  /// Deletes a city by encoded name and preserves conflict details when the
  /// backend refuses removal because of linked dependencies.
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

  /// ينفذ بحثًا محليًا فوق القائمة الكاملة عندما لا يوفر الخادم نقطة نهاية
  /// مستقلة للبحث.
  /// Performs in-memory searching over the fetched collection when the backend
  /// does not expose a dedicated search endpoint.
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

  /// يطلب الإحصاءات من الخادم أولًا، ثم يحسب بدائل محلية موثوقة إذا كانت
  /// الاستجابة ناقصة أو غير مدعومة.
  /// Requests city metrics from the backend first, then derives trustworthy
  /// local fallback values when the response is missing or unsupported.
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

  /// يرفع صورة أو فيديو لمدينة، مع توليد Poster للفيديوهات حتى تتوفر معاينة
  /// مرئية قبل التشغيل.
  /// Uploads image or video media for a city and generates a poster for videos
  /// so the UI can show a visual preview before playback.
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

  /// يحاول مطابقة الرابط المرسل مع سجل الوسائط الحقيقي عبر أكثر من أسلوب بحث
  /// قبل تنفيذ الحذف النهائي بالمعرف.
  /// Tries several matching strategies to resolve the actual media record from
  /// the supplied URL before issuing the final delete by id.
  @override
  Future<bool> deleteCityImage(String imageUrl) async {
    try {
      /// يطبّع الروابط حتى تصبح قابلة للمقارنة سواء جاءت كاملة أو كمسار
      /// نسبي أو على شكل URL مشفّر.
      /// Normalizes URLs so they can be compared whether they arrive as full
      /// URLs, relative paths, or encoded strings.
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

      /// يستخرج اسم الملف من المسار المطبّع لاستخدامه في البحث الأولي عن
      /// الوسائط المطابقة.
      /// Extracts the file name from the normalized path for the first-pass
      /// media lookup.
      String basename(String path) {
        final p = normalizeToPath(path);
        final idx = p.lastIndexOf('/');
        if (idx == -1) return p;
        return p.substring(idx + 1);
      }

      final inputPath = normalizeToPath(imageUrl);
      final fileName = basename(inputPath);

      /// يجلب دفعة من الصور المرشحة مع خيار البحث النصي حتى نتمكن من مطابقة
      /// السجل الصحيح قبل تنفيذ الحذف.
      /// Loads a batch of candidate images with optional text search so we can
      /// match the correct record before deletion.
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

      /// يبدأ بأضيق تطابق ممكن عبر الاسم لرفع احتمال العثور على السجل المقصود.
      /// Starts with the narrowest match by file name to increase the chance
      /// of finding the intended record.
      List<dynamic> images = await fetchImages(fileName);

      /// إذا لم يظهر تطابق واضح، نحاول المسار الكامل بدون النطاق.
      /// If no clear match appears, try the full path without the domain.
      if (images.isEmpty) {
        images = await fetchImages(inputPath);
      }

      /// كحل أخير، نجلب أول صفحة بدون بحث لنبحث داخل كل العناصر المتاحة.
      /// As a final fallback, fetch the first page without a search term and
      /// inspect every available item.
      if (images.isEmpty) {
        images = await fetchImages(null);
      }

      /// يطابق السجل بدقة مع مراعاة اختلاف النطاق والترميز بين الخدمة
      /// والطلب الأصلي.
      /// Resolves the record precisely while accounting for domain and
      /// encoding differences between the service and the original request.
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

  /// يطبق البحث والتصفية محليًا ثم يبني نتيجة صفحات متوافقة مع الجداول
  /// الإدارية التي تتوقع رقم صفحة وإجماليًا واضحًا.
  /// Applies local filtering and then builds a paginated result tailored for
  /// admin tables that expect explicit page numbers and totals.
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
