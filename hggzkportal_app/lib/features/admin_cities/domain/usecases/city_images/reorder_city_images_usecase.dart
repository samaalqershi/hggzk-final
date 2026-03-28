// lib/features/admin_citys/domain/usecases/city_images/reorder_city_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../repositories/city_images_repository.dart';

/// Persists a new ordering for the gallery images of one city.
///
/// يحفظ ترتيبًا جديدًا لصور معرض مدينة واحدة.
class ReorderCityImagesUseCase implements UseCase<bool, ReorderImagesParams> {
  /// Repository used to apply the gallery order update.
  ///
  /// المستودع المستخدم لتطبيق تحديث الترتيب.
  final CityImagesRepository repository;

  /// Connects the reorder request to the repository boundary.
  ///
  /// يربط طلب إعادة الترتيب بحد المستودع.
  ReorderCityImagesUseCase(this.repository);
  @override

  /// يمرر الترتيب الجديد ومعرّف المدينة أو المسودة إلى المستودع ثم يعيد
  /// نتيجة الحفظ.
  /// Passes the new order and the city or draft key to the repository and
  /// returns the save result.
  Future<Either<Failure, bool>> call(ReorderImagesParams params) async {
    return await repository.reorderImages(
        params.cityId, params.tempKey, params.imageIds);
  }
}

/// يجمع كل ما يلزم لإعادة ترتيب صور المعرض في طلب واحد ثابت.
/// Collects everything needed to reorder gallery images into one immutable
/// request.
class ReorderImagesParams {
  /// Saved city identifier that owns the gallery.
  ///
  /// معرّف المدينة المحفوظ المالكة للمعرض.
  final String? cityId;

  /// Temporary draft key for galleries that are not attached to a saved city yet.
  ///
  /// مفتاح مسودة مؤقت للمعارض غير المرتبطة بمدينة محفوظة بعد.
  final String? tempKey;

  /// Ordered list of image identifiers selected by the user.
  ///
  /// قائمة مرتبة بمعرفات الصور كما اختارها المستخدم.
  final List<String> imageIds;

  /// Packs the reorder target and the desired order into one immutable request.
  ///
  /// يجمع الهدف والترتيب المطلوب في كائن طلب ثابت واحد.
  ReorderImagesParams({
    this.cityId,
    this.tempKey,
    required this.imageIds,
  });
}
