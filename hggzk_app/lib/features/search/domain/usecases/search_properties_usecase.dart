import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzk/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

/// Executes the property search flow with the filters selected by the user.
/// ينفذ مسار البحث عن العقارات باستخدام الفلاتر التي يختارها المستخدم.
class SearchPropertiesUseCase
    implements UseCase<PaginatedResult<SearchResult>, SearchPropertiesParams> {
  /// Repository bridge that talks to search data sources.
  /// جسر المستودع الذي يتواصل مع مصادر بيانات البحث.
  final SearchRepository repository;

  /// Creates the use case around the search repository contract.
  /// ينشئ حالة الاستخدام اعتمادًا على عقد مستودع البحث.
  SearchPropertiesUseCase(this.repository);

  /// Sends the search criteria to the repository and returns paginated results.
  /// يرسل معايير البحث إلى المستودع ويعيد النتائج المقسمة إلى صفحات.
  @override
  Future<Either<Failure, PaginatedResult<SearchResult>>> call(
      SearchPropertiesParams params) async {
    return await repository.searchProperties(
      searchTerm: params.searchTerm,
      city: params.city,
      propertyTypeId: params.propertyTypeId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      minStarRating: params.minStarRating,
      requiredAmenities: params.requiredAmenities,
      unitTypeId: params.unitTypeId,
      serviceIds: params.serviceIds,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      adults: params.adults,
      children: params.children,
      guestsCount: params.guestsCount,
      dynamicFieldFilters: params.dynamicFieldFilters,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
      preferredCurrency: params.preferredCurrency,
      sortBy: params.sortBy,
      previewOnly: params.previewOnly,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

/// Parameters that describe one search request from the discovery screens.
/// المعطيات التي تصف طلب بحث واحدًا من شاشات الاكتشاف.
class SearchPropertiesParams extends Equatable {
  /// Text entered by the user in the search box.
  /// النص الذي يدخله المستخدم في مربع البحث.
  final String? searchTerm;

  /// City used to narrow the result set.
  /// المدينة المستخدمة لتضييق نطاق النتائج.
  final String? city;

  /// Property type selected in the search filters.
  /// نوع العقار المحدد داخل فلاتر البحث.
  final String? propertyTypeId;

  /// Lower bound of the price filter.
  /// الحد الأدنى لفلتر السعر.
  final double? minPrice;

  /// Upper bound of the price filter.
  /// الحد الأقصى لفلتر السعر.
  final double? maxPrice;

  /// Minimum acceptable star rating.
  /// الحد الأدنى المقبول لتقييم النجوم.
  final int? minStarRating;

  /// Amenities that must exist for the result to qualify.
  /// المزايا التي يجب أن تكون موجودة حتى تُقبل النتيجة.
  final List<String>? requiredAmenities;

  /// Unit type selected when the search is scoped to units.
  /// نوع الوحدة المختار عندما يكون البحث موجهًا للوحدات.
  final String? unitTypeId;

  /// Services that the result should include.
  /// الخدمات التي يجب أن تتوفر في النتيجة.
  final List<String>? serviceIds;

  /// Arrival date used for availability-aware searches.
  /// تاريخ الوصول المستخدم في البحث المعتمد على التوفر.
  final DateTime? checkIn;

  /// Departure date paired with the arrival date.
  /// تاريخ المغادرة المرتبط بتاريخ الوصول.
  final DateTime? checkOut;

  /// Number of adult guests included in the search.
  /// عدد الضيوف البالغين ضمن البحث.
  final int? adults;

  /// Number of child guests included in the search.
  /// عدد الأطفال ضمن البحث.
  final int? children;

  /// Total guest count used by backend matching logic.
  /// إجمالي عدد الضيوف المستخدم في مطابقة الخادم.
  final int? guestsCount;

  /// Dynamic field filters built from backend-defined search fields.
  /// فلاتر الحقول الديناميكية المبنية من حقول البحث المعرفة في الخادم.
  final Map<String, dynamic>? dynamicFieldFilters;

  /// Reference latitude for proximity search.
  /// خط العرض المرجعي للبحث القريب.
  final double? latitude;

  /// Reference longitude for proximity search.
  /// خط الطول المرجعي للبحث القريب.
  final double? longitude;

  /// Maximum radius used when the search is location-aware.
  /// نصف القطر الأقصى المستخدم عندما يكون البحث مرتبطًا بالموقع.
  final double? radiusKm;

  /// Currency preference used for price normalization.
  /// تفضيل العملة المستخدم لتوحيد الأسعار.
  final String? preferredCurrency;

  /// Sorting hint forwarded to the backend.
  /// تلميح الترتيب المرسل إلى الخادم.
  final String? sortBy;

  /// Limits the response to preview data when the UI needs a lighter payload.
  /// يقيّد الاستجابة ببيانات معاينة عندما تحتاج الواجهة حمولة أخف.
  final bool previewOnly;

  /// Page number requested from the paginated search feed.
  /// رقم الصفحة المطلوب من موجز البحث المقسم.
  final int pageNumber;

  /// Number of items requested per page.
  /// عدد العناصر المطلوبة في كل صفحة.
  final int pageSize;

  /// Bundles the full search query passed to the repository.
  /// يجمع طلب البحث الكامل المرسل إلى المستودع.
  const SearchPropertiesParams({
    this.searchTerm,
    this.city,
    this.propertyTypeId,
    this.minPrice,
    this.maxPrice,
    this.minStarRating,
    this.requiredAmenities,
    this.unitTypeId,
    this.serviceIds,
    this.checkIn,
    this.checkOut,
    this.adults,
    this.children,
    this.guestsCount,
    this.dynamicFieldFilters,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.preferredCurrency,
    this.sortBy,
    this.previewOnly = false,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  /// Keeps equality aligned with the active query state.
  /// يحافظ على ثبات المقارنة مع حالة الاستعلام الحالية.
  @override
  List<Object?> get props => [
        searchTerm,
        city,
        propertyTypeId,
        minPrice,
        maxPrice,
        minStarRating,
        requiredAmenities,
        unitTypeId,
        serviceIds,
        checkIn,
        checkOut,
        adults,
        children,
        guestsCount,
        dynamicFieldFilters,
        latitude,
        longitude,
        radiusKm,
        preferredCurrency,
        sortBy,
        previewOnly,
        pageNumber,
        pageSize,
      ];
}
