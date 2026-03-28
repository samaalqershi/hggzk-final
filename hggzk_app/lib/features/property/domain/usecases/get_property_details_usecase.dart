import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property_detail.dart';
import '../repositories/property_repository.dart';

/// Loads the property detail payload used by the property details screen.
/// يحمل حمولة تفاصيل العقار التي تعتمد عليها شاشة التفاصيل.
///
/// The use case keeps the presentation layer unaware of repository shape and
/// forwards the viewer context so the backend can tailor the response.
/// يعزل هذا الـ use case طبقة العرض عن شكل المستودع، ويمرر سياق المستخدم حتى
/// يخصص الخادم الاستجابة بشكل مناسب.
class GetPropertyDetailsUseCase
    implements UseCase<PropertyDetail, GetPropertyDetailsParams> {
  /// Repository bridge that performs the actual property fetch.
  /// جسر المستودع الذي ينفذ جلب العقار فعليًا.
  final PropertyRepository repository;

  /// Builds the use case around the property repository contract used by this feature.
  /// ينشئ حالة الاستخدام حول عقد مستودع العقارات.
  GetPropertyDetailsUseCase({required this.repository});

  /// Requests one property detail response using the supplied context.
  /// يطلب استجابة تفاصيل عقار واحدة باستخدام السياق الممرر.
  @override
  Future<Either<Failure, PropertyDetail>> call(
      GetPropertyDetailsParams params) async {
    return await repository.getPropertyDetails(
      propertyId: params.propertyId,
      userId: params.userId,
      userRole: params.userRole,
    );
  }
}

/// Parameters required to resolve the correct property detail view.
/// المعطيات المطلوبة للوصول إلى عرض تفاصيل العقار الصحيح.
class GetPropertyDetailsParams extends Equatable {
  /// Backend identifier of the property being opened.
  /// المعرّف الخلفي للعقار الذي يتم فتحه.
  final String propertyId;

  /// Optional viewer id used for personalization and permissions.
  /// معرّف اختياري للمستخدم يفيد التخصيص والصلاحيات.
  final String? userId;

  /// Optional role hint so the backend can shape the response.
  /// تلميح اختياري للدور حتى يكيّف الخادم الاستجابة.
  final String? userRole;

  /// Bundles the identifiers needed to fetch the property details.
  /// يجمع المعرّفات اللازمة لجلب تفاصيل العقار.
  const GetPropertyDetailsParams({
    required this.propertyId,
    this.userId,
    this.userRole,
  });

  /// Keeps request comparisons stable when the UI rebuilds the same query.
  /// يحافظ على ثبات المقارنة عند إعادة بناء نفس الطلب في الواجهة.
  @override
  List<Object?> get props => [propertyId, userId, userRole];
}
