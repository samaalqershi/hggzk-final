// lib/features/admin_citys/domain/usecases/city_images/get_city_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/city_image.dart';
import '../../repositories/city_images_repository.dart';

/// Loads the gallery items for one city or for a temporary draft session.
///
/// يحمل عناصر المعرض لمدينة واحدة أو لجلسة مسودة مؤقتة.
class GetCityImagesUseCase
    implements UseCase<List<CityImage>, GetCityImagesParams> {
  /// Repository responsible for reading the gallery state.
  ///
  /// المستودع المسؤول عن قراءة حالة المعرض.
  final CityImagesRepository repository;

  /// Connects the gallery query to the repository implementation.
  ///
  /// يربط استعلام المعرض بتنفيذ المستودع.
  GetCityImagesUseCase(this.repository);
  @override

  /// يمرر معرّف المدينة أو مفتاح المسودة إلى المستودع ثم يعيد صور المعرض
  /// المطابقة.
  /// Passes either the city id or the draft key to the repository and
  /// returns the matching gallery images.
  Future<Either<Failure, List<CityImage>>> call(
      GetCityImagesParams params) async {
    return await repository.getCityImages(params.cityId,
        tempKey: params.tempKey);
  }
}

/// يجمع هدف جلب صور المدينة في كائن واحد سواء كان المعرض تابعًا لسجل
/// محفوظ أو لمسودة مؤقتة.
/// Collects the target for loading city images into one object, whether the
/// gallery belongs to a saved record or a temporary draft.
class GetCityImagesParams {
  /// Persisted city identifier when the gallery belongs to a saved city.
  ///
  /// معرّف المدينة المحفوظ عندما يكون المعرض تابعًا لمدينة محفوظة.
  final String? cityId;

  /// Temporary draft key used before the city record is created.
  ///
  /// مفتاح مسودة مؤقت يستخدم قبل إنشاء سجل المدينة.
  final String? tempKey;

  /// Encapsulates the gallery lookup target in a single immutable object.
  ///
  /// يجمع هدف جلب المعرض في كائن ثابت واحد.
  GetCityImagesParams({this.cityId, this.tempKey});
}
