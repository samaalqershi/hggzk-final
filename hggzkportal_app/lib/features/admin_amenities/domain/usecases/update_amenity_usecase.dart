import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/amenities_repository.dart';

/// يحدّث بيانات مرفق موجود حتى يعكس الاسم أو الوصف أو الأيقونة الجديدة
/// داخل الإدارة.
/// Updates an existing amenity so the name, description, or icon reflect the
/// latest admin changes.
class UpdateAmenityUseCase implements UseCase<bool, UpdateAmenityParams> {
  /// المستودع الذي يطبّق التحديث الفعلي على المرفق.
  /// The repository that applies the actual amenity update.
  final AmenitiesRepository repository;

  /// Creates the update use case backed by the amenities repository.
  UpdateAmenityUseCase(this.repository);

  @override

  /// يمرر معرّف المرفق والقيم الجديدة إلى المستودع ويعيد نتيجة التحديث.
  /// Passes the amenity id and new values to the repository and returns the
  /// update result.
  Future<Either<Failure, bool>> call(UpdateAmenityParams params) async {
    return await repository.updateAmenity(
      amenityId: params.amenityId,
      name: params.name,
      nameEn: params.nameEn,
      description: params.description,
      descriptionEn: params.descriptionEn,
      icon: params.icon,
    );
  }
}

/// يجمع الحقول القابلة للتعديل في المرفق ضمن طلب واحد حتى تبقى عملية
/// التحديث مرنة وواضحة.
/// Collects the editable amenity fields into one request so the update flow
/// stays flexible and clear.
class UpdateAmenityParams extends Equatable {
  /// معرّف المرفق المراد تعديله.
  /// The identifier of the amenity being edited.
  final String amenityId;

  /// الاسم الجديد للمرفق عندما يراد تغييره.
  /// The new amenity name when a rename is requested.
  final String? name;

  /// الاسم الإنجليزي الجديد للمرفق عندما يلزم تحديثه.
  /// The new English amenity name when needed.
  final String? nameEn;

  /// الوصف الجديد للمرفق عندما يحتاج النص إلى تحديث.
  /// The new description when the text needs to be refreshed.
  final String? description;

  /// الوصف الإنجليزي الجديد للمرفق عند الحاجة.
  /// The new English description when needed.
  final String? descriptionEn;

  /// الأيقونة الجديدة التي تمثل المرفق بصريًا.
  /// The new icon that represents the amenity visually.
  final String? icon;

  /// Creates the immutable payload used to update an amenity.
  const UpdateAmenityParams({
    required this.amenityId,
    this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    this.icon,
  });

  @override

  /// تعتمد المساواة على جميع قيم التحديث لأن كل حقل قد يغيّر النتيجة.
  /// Equality depends on every update field because each one can change the
  /// result.
  List<Object?> get props =>
      [amenityId, name, nameEn, description, descriptionEn, icon];
}
