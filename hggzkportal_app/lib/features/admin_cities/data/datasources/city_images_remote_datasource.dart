// lib/features/admin_citys/data/datasources/city_images_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:hggzkportal/core/error/exceptions.dart';
import 'package:hggzkportal/core/constants/app_constants.dart';
import 'package:hggzkportal/core/utils/media_file_safety.dart';
import 'package:hggzkportal/core/utils/video_utils.dart';
import '../models/city_image_model.dart';

/// يعرّف العمليات البعيدة الخاصة بوسائط المدن، من رفع الصور والفيديوهات إلى
/// إعادة ترتيبها وتعيين صورة الغلاف التي ستظهر في لوحة التحكم والواجهة العامة.
/// Defines the remote city-media workflow, from uploading images and videos to
/// reordering them and choosing the cover asset shown in admin and consumer
/// views.
abstract class CityImagesRemoteDataSource {
  /// يرفع صورة أو فيديو لمدينة محفوظة أو لمسودة مؤقتة ويعيد التمثيل النهائي
  /// للوسيط بعد أن يضيف الخادم معرفاته وبياناته الوصفية.
  /// Uploads an image or video for a saved city or a temporary draft and
  /// returns the final media representation after the backend assigns ids and
  /// metadata.
  Future<CityImageModel> uploadImage({
    String? cityId,
    String? tempKey,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  });

  /// يجلب الوسائط الحالية المرتبطة بمدينة أو بمسودة، مع الحفاظ على الترتيب
  /// الذي تعتمد عليه الواجهة عند العرض.
  /// Fetches the media currently linked to a city or draft while preserving the
  /// order expected by the UI.
  Future<List<CityImageModel>> getCityImages(String? cityId, {String? tempKey});

  /// يحدّث بيانات وسيط موجود مثل النص البديل أو الوسوم أو الترتيب بعد اكتمال
  /// عملية الرفع.
  /// Updates an existing media record with metadata changes such as alt text,
  /// tags, or order after upload has finished.
  Future<bool> updateImage(String imageId, Map<String, dynamic> data);

  /// يحذف وسيطًا واحدًا من المعرض البعيد بعد تحديده بمعرفه النهائي.
  /// Deletes a single asset from the remote gallery once its final id is
  /// known.
  Future<bool> deleteImage(String imageId);

  /// يرسل ترتيبًا جديدًا للمعرض حتى يستخدم الخادم والواجهة التسلسل نفسه عند
  /// عرض الصور.
  /// Sends a new gallery sequence so the backend and UI render the same image
  /// order.
  Future<bool> reorderImages(
      String? cityId, String? tempKey, List<String> imageIds);

  /// يحدد وسيطًا معينًا كصورة الغلاف الرئيسية التي تمثل المدينة.
  /// Marks a specific asset as the primary cover that represents the city.
  Future<bool> setAsPrimaryImage(
      String? cityId, String? tempKey, String imageId);
}

/// ينفذ تكامل وسائط المدن مع خدمة الصور المركزية في الخادم، بما يشمل الصور
/// والفيديوهات والمصغرات التي تُنشأ تلقائيًا للفيديو.
/// Implements city-media integration against the shared backend image service,
/// including images, videos, and derived thumbnails for video assets.
class CityImagesRemoteDataSourceImpl implements CityImagesRemoteDataSource {
  /// عميل الشبكة المستخدم لإرسال عمليات الوسائط وتفسير استجابات الخادم.
  /// Network client used to send media operations and interpret backend
  /// responses.
  final ApiClient apiClient;

  /// المسار الأساسي المشترك الذي تمر عبره كل عمليات وسائط المدن.
  /// Shared base endpoint through which all city-media operations are routed.
  static const String _imagesEndpoint = '/api/images';

  /// يربط مصدر البيانات بعميل الشبكة المشترك مع بقية لوحة التحكم.
  /// Binds the datasource to the API client shared across the dashboard.
  CityImagesRemoteDataSourceImpl({required this.apiClient});

  /// Uploads one city media file, generating thumbnails for videos when
  /// needed before forwarding the multipart payload to the backend.
  ///
  /// يرفع ملف وسائط واحدًا لمدينة معينة، مع توليد صورة مصغرة للفيديو عند
  /// الحاجة قبل إرسال الحمولة متعددة الأجزاء إلى الخادم.
  @override
  Future<CityImageModel> uploadImage({
    String? cityId,
    String? tempKey,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final uploadFile = await MediaFileSafety.ensureStableReadableCopy(
        filePath,
        namespace: 'city_images',
      );
      if (uploadFile == null) {
        throw const ServerException('تعذر الوصول إلى ملف المدينة المحدد');
      }

      String? posterPath;
      if (AppConstants.isVideoFile(uploadFile.path)) {
        posterPath = await VideoUtils.generateVideoThumbnail(uploadFile.path);
      }
      final posterFile = posterPath == null
          ? null
          : await MediaFileSafety.resolveReadableFile(posterPath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          uploadFile.path,
          filename: MediaFileSafety.basename(uploadFile.path),
        ),
        'cityId': cityId,
        if (tempKey != null) 'tempKey': tempKey,
        if (category != null) 'category': category,
        if (alt != null) 'alt': alt,
        'isPrimary': isPrimary,
        if (order != null) 'order': order,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        if (posterFile != null)
          'videoThumbnail': await MultipartFile.fromFile(
            posterFile.path,
            filename: MediaFileSafety.basename(posterFile.path),
          ),
      });

      final response = await apiClient.post(
        '$_imagesEndpoint/upload',
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
        if (map['success'] == true && map['image'] != null) {
          return CityImageModel.fromJson(map['image']);
        }
        // بعض البيئات قد ترجع تحت data
        if (map['success'] == true && map['data'] != null) {
          final data = map['data'];
          if (data is Map<String, dynamic> && data.containsKey('url')) {
            return CityImageModel.fromJson(data);
          }
        }
      }
      throw ServerException(
          response.data['message'] ?? 'Failed to upload image');
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data['message'] ?? 'Failed to upload image');
    }
  }

  /// Retrieves the ordered media gallery for a saved city or temporary draft.
  ///
  /// يجلب معرض الوسائط المرتب لمدينة محفوظة أو لمسودة مؤقتة.
  @override
  Future<List<CityImageModel>> getCityImages(String? cityId,
      {String? tempKey}) async {
    try {
      final qp = <String, dynamic>{
        'cityId': cityId,
        'sortBy': 'order',
        'sortOrder': 'asc',
      };
      if (tempKey != null) qp['tempKey'] = tempKey;
      final response =
          await apiClient.get(_imagesEndpoint, queryParameters: qp);

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final List<dynamic> list =
            (map['images'] as List?) ?? (map['items'] as List?) ?? const [];
        return list.map((json) => CityImageModel.fromJson(json)).toList();
      }
      throw const ServerException('Invalid response when fetching images');
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch city images');
    }
  }

  /// Updates metadata for one existing city media item after upload.
  ///
  /// يحدّث البيانات الوصفية لوسيط مدينة موجود بعد اكتمال الرفع.
  @override
  Future<bool> updateImage(String imageId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        '$_imagesEndpoint/$imageId',
        data: data,
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data['message'] ?? 'Failed to update image');
    }
  }

  /// Deletes one city media asset from the backend gallery by its final id.
  ///
  /// يحذف وسيط مدينة واحدًا من المعرض الخلفي باستخدام معرّفه النهائي.
  @override
  Future<bool> deleteImage(String imageId) async {
    try {
      final response = await apiClient.delete('$_imagesEndpoint/$imageId');
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data['message'] ?? 'Failed to delete image');
    }
  }

  @override
  Future<bool> reorderImages(
      String? cityId, String? tempKey, List<String> imageIds) async {
    try {
      final payload = {
        'imageIds': imageIds,
        if (cityId != null) 'cityId': cityId,
        if (tempKey != null) 'tempKey': tempKey,
      };
      final response =
          await apiClient.post('$_imagesEndpoint/reorder', data: payload);
      return response.statusCode == 204 ||
          (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data['message'] ?? 'Failed to reorder images');
    }
  }

  @override
  Future<bool> setAsPrimaryImage(
      String? cityId, String? tempKey, String imageId) async {
    try {
      final body = {
        if (cityId != null) 'cityId': cityId,
        if (tempKey != null) 'tempKey': tempKey,
      };
      final response = await apiClient
          .post('$_imagesEndpoint/$imageId/set-primary', data: body);
      return response.statusCode == 204 ||
          (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data['message'] ?? 'Failed to set primary image');
    }
  }
}
