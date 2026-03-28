import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/cities_repository.dart';

/// Loads the city catalog for the admin screen with optional filters.
///
/// يحمل دليل المدن لشاشة الإدارة مع مرشحات اختيارية.
class GetCitiesUseCase implements UseCase<List<City>, GetCitiesParams> {
  /// Repository used to fetch city data.
  ///
  /// المستودع المستخدم لجلب بيانات المدن.
  final CitiesRepository repository;

  /// Connects the query use case to the repository implementation.
  ///
  /// يربط هذا الـ use case بتنفيذ المستودع.
  GetCitiesUseCase(this.repository);

  @override

  /// Forwards the current paging and filter values to the repository.
  ///
  /// يمرر قيم التصفح والفلاتر الحالية إلى المستودع.
  Future<Either<Failure, List<City>>> call(GetCitiesParams params) async {
    return await repository.getCities(
      page: params.page,
      limit: params.limit,
      search: params.search,
      country: params.country,
      isActive: params.isActive,
    );
  }
}

/// Immutable query object that carries paging and filter controls for cities.
///
/// كائن استعلام ثابت يحمل إعدادات الترقيم والفلاتر الخاصة بالمدن.
class GetCitiesParams extends Equatable {
  /// Requested page number when the backend supports pagination.
  ///
  /// رقم الصفحة المطلوبة عندما يدعم الخادم الترقيم.
  final int? page;

  /// Maximum number of records to return per request.
  ///
  /// الحد الأقصى لعدد السجلات المرجعة في الطلب الواحد.
  final int? limit;

  /// Free-text term used to narrow the list by city name or country.
  ///
  /// نص البحث الذي يضيّق القائمة بحسب اسم المدينة أو الدولة.
  final String? search;

  /// Country filter applied before the list is returned to the UI.
  ///
  /// فلتر الدولة المطبّق قبل إعادة القائمة إلى الواجهة.
  final String? country;

  /// Optional active-state filter for moderation and publishing workflows.
  ///
  /// فلتر اختياري للحالة النشطة في مسارات المراجعة والنشر.
  final bool? isActive;

  /// Bundles the query controls used when reading cities from the repository.
  ///
  /// يجمع ضوابط الاستعلام المستخدمة عند قراءة المدن من المستودع.
  const GetCitiesParams({
    this.page,
    this.limit,
    this.search,
    this.country,
    this.isActive,
  });

  @override

  /// Comparison keys for the current city query and filter state.
  ///
  /// مفاتيح المقارنة لاستعلام المدينة وحالة الفلاتر الحالية.
  List<Object?> get props => [page, limit, search, country, isActive];
}
