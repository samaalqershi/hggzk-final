// lib/features/home/domain/usecases/get_sections_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzk/core/models/paginated_result.dart' as core;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/section.dart';
import '../repositories/home_repository.dart';

/// يحمّل تعريفات الأقسام التي تشكل الصفحة الرئيسية حتى تستطيع طبقة العرض
/// بناء الترتيب الصحيح للمحتوى قبل جلب عناصر كل قسم.
/// Loads the section definitions that shape the home screen so the
/// presentation layer can build the correct layout before fetching each
/// section's items.
class GetSectionsUseCase
    implements UseCase<core.PaginatedResult<Section>, GetSectionsParams> {
  /// المستودع الذي ينسق بين الخادم والكاش عند طلب الأقسام.
  /// Repository that coordinates between backend and cache when sections are
  /// requested.
  final HomeRepository repository;

  /// يربط حالة الاستخدام بالمستودع الذي ينفذ القراءة الفعلية للأقسام.
  /// Binds the use case to the repository that performs the actual section
  /// retrieval.
  GetSectionsUseCase(this.repository);

  @override
  Future<Either<Failure, core.PaginatedResult<Section>>> call(
      GetSectionsParams params) async {
    if (repository is dynamic &&
        (repository as dynamic).getSections is Function) {
      return await (repository as dynamic).getSections(
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
        target: params.target,
        type: params.type,
        forceRefresh: params.forceRefresh,
      );
    }
    return Left(UnknownFailure());
  }
}

/// يجمع معلمات طلب الأقسام مثل الصفحة والحجم والهدف والنوع حتى تبقى دعوة
/// حالة الاستخدام واضحة وقابلة للمقارنة.
/// Groups the section-request parameters such as page, size, target, and type
/// so the use-case call stays explicit and comparable.
class GetSectionsParams extends Equatable {
  /// رقم الصفحة المطلوب تحميلها من قائمة الأقسام.
  /// Page number requested from the section catalog.
  final int pageNumber;

  /// عدد الأقسام المطلوب استرجاعها في كل دفعة.
  /// Number of sections requested per batch.
  final int pageSize;

  /// هدف العرض أو الجمهور الذي نريد تقييد النتائج عليه.
  /// Display target or audience used to restrict the result set.
  final String? target;

  /// نوع القسم المطلوب إذا كان الطلب موجهًا لنمط معين.
  /// Requested section type when the call is scoped to one pattern.
  final String? type;

  /// يحدد ما إذا كان ينبغي تجاوز الكاش وفرض قراءة جديدة.
  /// Indicates whether cache should be bypassed in favor of a fresh read.
  final bool forceRefresh;

  /// ينشئ حزمة المعلمات التي تصف طلب الأقسام.
  /// Creates the parameter bundle that describes a section request.
  const GetSectionsParams({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.target,
    this.type,
    this.forceRefresh = false,
  });
  @override
  List<Object?> get props => [pageNumber, pageSize, target, type, forceRefresh];
}
