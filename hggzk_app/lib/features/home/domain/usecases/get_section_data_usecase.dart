// lib/features/home/domain/usecases/get_section_data_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzk/core/models/paginated_result.dart' as core;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/section_item_models.dart';
import '../repositories/home_repository.dart';

/// يجلب العناصر التابعة لقسم واحد حتى تستطيع الصفحة الرئيسية رسم بطاقاته أو
/// تحميل المزيد منه بشكل مستقل.
/// Loads the items that belong to one section so the home screen can render
/// its cards or paginate that section independently.
class GetSectionDataUseCase
    implements
        UseCase<core.PaginatedResult<SectionPropertyItemModel>,
            GetSectionDataParams> {
  /// المستودع الذي ينسق بين الخادم والكاش عند قراءة عناصر القسم.
  /// Repository that coordinates between backend and cache when section items
  /// are requested.
  final HomeRepository repository;

  /// يربط حالة الاستخدام بالمستودع الذي يوفر عناصر الأقسام.
  /// Binds the use case to the repository that exposes section-item data.
  GetSectionDataUseCase(this.repository);

  @override
  Future<Either<Failure, core.PaginatedResult<SectionPropertyItemModel>>> call(
      GetSectionDataParams params) async {
    if (repository is dynamic &&
        (repository as dynamic).getSectionPropertyItems is Function) {
      return await (repository as dynamic).getSectionPropertyItems(
        sectionId: params.sectionId,
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
        forceRefresh: params.forceRefresh,
      );
    }
    return const Left(UnknownFailure('GetSectionDataUseCase not implemented'));
  }
}

/// يجمع معلمات طلب بيانات القسم مثل المعرّف والصفحة والحجم حتى تكون دعوة
/// حالة الاستخدام واضحة وقابلة للمقارنة.
/// Groups the parameters for a section-data request, such as id, page, and
/// size, so the use-case invocation stays explicit and comparable.
class GetSectionDataParams extends Equatable {
  /// معرّف القسم الذي نريد تحميل عناصره.
  /// Identifier of the section whose items should be loaded.
  final String sectionId;

  /// الصفحة المطلوبة من عناصر القسم.
  /// Requested page from the section item feed.
  final int pageNumber;

  /// عدد العناصر المطلوب استرجاعها في كل دفعة.
  /// Number of items requested per batch.
  final int pageSize;

  /// يحدد ما إذا كان ينبغي تجاوز الكاش وقراءة نسخة جديدة.
  /// Indicates whether cache should be bypassed for a fresh read.
  final bool forceRefresh;

  /// ينشئ حزمة المعلمات التي تصف طلب بيانات القسم.
  /// Creates the parameter bundle that describes a section-data request.
  const GetSectionDataParams({
    required this.sectionId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.forceRefresh = false,
  });
  @override
  List<Object?> get props => [sectionId, pageNumber, pageSize, forceRefresh];
}
