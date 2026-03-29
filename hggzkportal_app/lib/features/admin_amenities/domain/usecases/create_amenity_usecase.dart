import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/amenities_repository.dart';

/// ينشئ مرفقًا جديدًا داخل المستودع مع كل المعلومات التي يحتاجها الإداري
/// لعرضه أو ربطه لاحقًا بأنواع العقارات.
/// Creates a new amenity in the repository with the information needed for
/// later display or property-type binding.
class CreateAmenityUseCase implements UseCase<String, CreateAmenityParams> {
  /// المستودع الذي يتولى حفظ المرفق الجديد في طبقة البيانات.
  /// The repository responsible for persisting the new amenity in data.
  final AmenitiesRepository repository;

  /// Creates the use case that delegates amenity creation to the repository.
  CreateAmenityUseCase(this.repository);

  @override

  /// يمرر تفاصيل المرفق الجديد إلى المستودع ويعيد المعرف الناتج بعد
  /// الإنشاء.
  /// Passes the new amenity details to the repository and returns the
  /// identifier produced after creation.
  Future<Either<Failure, String>> call(CreateAmenityParams params) async {
    return await repository.createAmenity(
      name: params.name,
      nameEn: params.nameEn,
      description: params.description,
      descriptionEn: params.descriptionEn,
      icon: params.icon,
      propertyTypeId: params.propertyTypeId,
      isDefaultForType: params.isDefaultForType,
    );
  }
}

/// يجمع حقول إنشاء المرفق في حمولة واحدة حتى تبقى عملية الإنشاء واضحة
/// وقابلة لإعادة الاستخدام.
/// Collects amenity-creation fields in one payload so the creation flow stays
/// clear and reusable.
class CreateAmenityParams extends Equatable {
  /// الاسم الظاهر للمرفق داخل الواجهة ولوحات الإدارة.
  /// The visible amenity name shown in the UI and admin screens.
  final String name;

  /// الاسم الإنجليزي الموازي للمرفق.
  /// English name stored alongside the Arabic value.
  final String? nameEn;

  /// الوصف الذي يشرح طبيعة المرفق أو استخدامه.
  /// The description that explains what the amenity is or how it is used.
  final String description;

  /// الوصف الإنجليزي الموازي للمرفق.
  /// English description stored alongside the primary text.
  final String? descriptionEn;

  /// اسم الأيقونة أو المفتاح الذي يمثل المرفق بصريًا.
  /// The icon name or key used to represent the amenity visually.
  final String icon;

  /// معرّف نوع العقار عندما يكون هذا المرفق مرتبطًا بنوع محدد فقط.
  /// The property-type identifier when the amenity belongs to a specific
  /// type only.
  final String? propertyTypeId;

  /// يحدد ما إذا كان هذا المرفق افتراضيًا لنوع العقار المحدد.
  /// Indicates whether the amenity should be the default for that property
  /// type.
  final bool isDefaultForType;

  /// Creates the immutable payload needed to create an amenity.
  const CreateAmenityParams({
    required this.name,
    this.nameEn,
    required this.description,
    this.descriptionEn,
    required this.icon,
    this.propertyTypeId,
    this.isDefaultForType = false,
  });

  @override

  /// تعتمد المساواة على جميع قيم الإنشاء لأن أي تغيير فيها ينتج طلبًا
  /// مختلفًا.
  /// Equality depends on every creation field because any change produces a
  /// different request.
  List<Object?> get props => [
        name,
        nameEn,
        description,
        descriptionEn,
        icon,
        propertyTypeId,
        isDefaultForType
      ];
}
