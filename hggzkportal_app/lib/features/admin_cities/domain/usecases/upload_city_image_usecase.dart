import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cities_repository.dart';

/// Uploads a city cover or gallery image from the admin workflow.
///
/// يرفع صورة مدينة رئيسية أو ضمن المعرض من رحلة الإدارة.
class UploadCityImageUseCase implements UseCase<String, UploadCityImageParams> {
  /// Repository that performs the actual upload.
  ///
  /// المستودع الذي ينفذ عملية الرفع الفعلية.
  final CitiesRepository repository;

  /// Binds the upload flow to the repository layer.
  ///
  /// يربط مسار الرفع بطبقة المستودع.
  UploadCityImageUseCase(this.repository);

  @override

  /// Uploads the selected image path and forwards progress callbacks when provided.
  ///
  /// يرفع مسار الصورة المختار ويمرر استدعاءات التقدم عند توفرها.
  Future<Either<Failure, String>> call(UploadCityImageParams params) async {
    return await repository.uploadCityImage(
      params.cityName,
      params.imagePath,
      onSendProgress: params.onSendProgress,
    );
  }
}

/// Immutable request object that describes one city-image upload operation.
///
/// كائن طلب ثابت يصف عملية رفع صورة واحدة لمدينة.
class UploadCityImageParams extends Equatable {
  /// Target city name used to attach the uploaded media.
  ///
  /// اسم المدينة المستهدفة الذي يُستخدم لربط الوسائط المرفوعة.
  final String cityName;

  /// Local file path selected by the admin user.
  ///
  /// مسار الملف المحلي الذي اختاره المستخدم.
  final String imagePath;

  /// Optional upload progress callback forwarded to the data source.
  ///
  /// استدعاء اختياري لتقدم الرفع يُمرر إلى مصدر البيانات.
  final ProgressCallback? onSendProgress;

  /// Packs upload arguments into a single immutable request object.
  ///
  /// يجمع معطيات الرفع في كائن طلب ثابت واحد.
  const UploadCityImageParams({
    required this.cityName,
    required this.imagePath,
    this.onSendProgress,
  });

  @override

  /// Comparison keys for the city, file path, and progress callback.
  ///
  /// مفاتيح المقارنة للمدينة ومسار الملف واستدعاء التقدم.
  List<Object?> get props => [cityName, imagePath, onSendProgress];
}
