import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';

/// Defines the search contract used by the discovery and map screens.
/// يعرّف عقد البحث الذي تستخدمه شاشات الاكتشاف والخريطة.
abstract class SearchRepository {
  /// Runs the main property search query with the currently selected filters.
  /// ينفذ استعلام البحث الرئيسي عن العقارات باستخدام الفلاتر الحالية.
  Future<Either<Failure, PaginatedResult<SearchResult>>> searchProperties({
    String? searchTerm,
    String? city,
    String? propertyTypeId,
    double? minPrice,
    double? maxPrice,
    int? minStarRating,
    List<String>? requiredAmenities,
    String? unitTypeId,
    List<String>? serviceIds,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? guestsCount,
    Map<String, dynamic>? dynamicFieldFilters,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? preferredCurrency,
    String? sortBy,
    bool previewOnly = false,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// Loads the dynamic filters used to build the advanced search screen.
  /// يحمل الفلاتر الديناميكية المستخدمة في بناء شاشة البحث المتقدمة.
  Future<Either<Failure, SearchFilters>> getSearchFilters();

  /// Returns autocomplete suggestions for the typed query.
  /// يعيد اقتراحات الإكمال التلقائي للنص المكتوب.
  Future<Either<Failure, List<String>>> getSearchSuggestions({
    required String query,
    int limit = 10,
  });

  /// Returns recommended properties tailored to the current user context.
  /// يعيد العقارات الموصى بها بناءً على سياق المستخدم الحالي.
  Future<Either<Failure, List<SearchResult>>> getRecommendedProperties({
    String? userId,
    int limit = 10,
  });

  /// Returns popular destinations that can seed the search experience.
  /// يعيد الوجهات الشائعة التي يمكن استخدامها كبداية لتجربة البحث.
  Future<Either<Failure, List<String>>> getPopularDestinations({
    int limit = 10,
  });
}
