import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/amenities_repository.dart';

/// يربط مرفقًا واحدًا بعقار محدد مع ضبط حالة التوفر والتكلفة الإضافية
/// والملاحظة النصية في طلب واحد واضح.
/// Links one amenity to a specific property while carrying availability,
/// extra cost, and a short description in one focused request.
class AssignAmenityToPropertyUseCase
    implements UseCase<bool, AssignAmenityParams> {
  /// المستودع المسؤول عن تنفيذ ربط المرافق بالعقارات.
  /// The repository that performs the amenity-to-property assignment.
  final AmenitiesRepository repository;

  /// Creates a use case that delegates the assignment flow to the repository.
  AssignAmenityToPropertyUseCase(this.repository);

  @override

  /// يمرر تفاصيل الإسناد إلى المستودع ويعيد نتيجة العملية كما هي من دون
  /// إضافة منطق جانبي.
  /// Forwards the assignment details to the repository and returns the
  /// repository result without adding extra orchestration.
  Future<Either<Failure, bool>> call(AssignAmenityParams params) async {
    return await repository.assignAmenityToProperty(
      amenityId: params.amenityId,
      propertyId: params.propertyId,
      isAvailable: params.isAvailable,
      extraCost: params.extraCost,
      description: params.description,
    );
  }
}

/// يجمع كل القيم اللازمة لربط مرفق بعقار واحد في كائن immutable واحد.
/// Collects all values required to assign one amenity to one property inside
/// a single immutable object.
class AssignAmenityParams extends Equatable {
  /// معرّف المرفق الذي سيتم ربطه بالعقار.
  /// The amenity identifier that will be attached to the property.
  final String amenityId;

  /// معرّف العقار الهدف الذي يستقبل المرفق.
  /// The target property identifier that receives the amenity.
  final String propertyId;

  /// يحدد ما إذا كان المرفق متاحًا فعليًا داخل العقار.
  /// Indicates whether the amenity should be marked as available.
  final bool isAvailable;

  /// كلفة إضافية اختيارية تظهر عندما يكون هذا المرفق مدفوعًا.
  /// Optional extra cost used when this amenity is not included for free.
  final double? extraCost;

  /// وصف مختصر يوضح تفاصيل الإسناد أو شروطه للمستخدم أو الإدارة.
  /// A short description that explains the assignment details or conditions.
  final String? description;

  /// Creates the immutable assignment payload used by the use case.
  const AssignAmenityParams({
    required this.amenityId,
    required this.propertyId,
    this.isAvailable = true,
    this.extraCost,
    this.description,
  });

  @override

  /// تعتمد المساواة على كل قيمة تشكّل الطلب نفسه حتى لا يختلط بطلب آخر.
  /// Equality depends on every value that defines the request so one payload
  /// is not confused with another.
  List<Object?> get props => [
        amenityId,
        propertyId,
        isAvailable,
        extraCost,
        description,
      ];
}
