import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';

/// Shared base state for every screen that consumes the city catalog.
///
/// الحالة الأساسية المشتركة لكل شاشة تستهلك دليل المدن.
abstract class CitiesState extends Equatable {
  /// Defines the equality boundary for all city states.
  ///
  /// يحدد حد المساواة لجميع حالات المدن.
  const CitiesState();

  /// Leaves the shared state empty so concrete states own their equality data.
  ///
  /// يترك الحالة المشتركة فارغة حتى تمتلك الحالات الفعلية بيانات مساواتها.
  @override
  List<Object?> get props => [];
}

/// Idle state before the city module has started loading data.
///
/// حالة سكون قبل أن تبدأ وحدة المدن بجلب البيانات.
class CitiesInitial extends CitiesState {}

/// Emitted while the catalog is being fetched or refreshed.
///
/// تُرسل أثناء جلب الدليل أو تحديثه.
class CitiesLoading extends CitiesState {}

/// Holds the loaded city list together with pagination and dashboard stats.
///
/// تحتفظ بقائمة المدن المحملة مع الترقيم وإحصائيات اللوحة.
class CitiesLoaded extends CitiesState {
  /// Full city snapshot returned by the repository.
  ///
  /// اللقطة الكاملة للمدن التي أعادها المستودع.
  final List<City> cities;

  /// Current slice shown in the paged table after filtering.
  ///
  /// الشريحة الحالية المعروضة في الجدول بعد التصفية.
  final List<City> filteredCities;

  /// Page number currently visible in the UI.
  ///
  /// رقم الصفحة الظاهر حاليًا في الواجهة.
  final int currentPage;

  /// Total number of pages available for the current snapshot.
  ///
  /// العدد الإجمالي للصفحات المتاحة للّقطة الحالية.
  final int totalPages;

  /// Number of rows rendered per page in the admin table.
  ///
  /// عدد الصفوف المعروضة في كل صفحة داخل جدول الإدارة.
  final int itemsPerPage;

  /// Last search string applied to the loaded snapshot.
  ///
  /// آخر نص بحث طُبق على اللقطة المحملة.
  final String? searchQuery;

  /// Analytics snapshot displayed in the dashboard cards.
  ///
  /// لقطة الإحصائيات المعروضة في بطاقات اللوحة.
  final Map<String, dynamic>? statistics;

  /// Bundles the city list, paging data, and analytics together.
  ///
  /// يجمع قائمة المدن وبيانات الترقيم والإحصائيات معًا.
  const CitiesLoaded({
    required this.cities,
    required this.filteredCities,
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = 10,
    this.searchQuery,
    this.statistics,
  });
  CitiesLoaded copyWith({
    List<City>? cities,
    List<City>? filteredCities,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? searchQuery,
    Map<String, dynamic>? statistics,
  }) {
    return CitiesLoaded(
      cities: cities ?? this.cities,
      filteredCities: filteredCities ?? this.filteredCities,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      searchQuery: searchQuery ?? this.searchQuery,
      statistics: statistics ?? this.statistics,
    );
  }

  /// Uses the visible data snapshot and paging context for equality.
  ///
  /// يعتمد على لقطة البيانات الظاهرة وسياق الترقيم في المساواة القيمية.
  @override
  List<Object?> get props => [
        cities,
        filteredCities,
        currentPage,
        totalPages,
        itemsPerPage,
        searchQuery,
        statistics,
      ];
}

/// Represents a loading failure for the city catalog.
///
/// تمثل فشلًا في تحميل دليل المدن.
class CitiesError extends CitiesState {
  /// Human-readable reason shown when the catalog request fails.
  ///
  /// رسالة سبب الفشل التي تعرض للمستخدم.
  final String message;

  /// Captures the failure message for the screen.
  ///
  /// يلتقط رسالة الفشل الخاصة بالشاشة.
  const CitiesError({required this.message});

  /// Uses the error message for value equality.
  ///
  /// يعتمد على رسالة الخطأ في المساواة القيمية.
  @override
  List<Object?> get props => [message];
}

/// Marks a single city mutation such as save, update, or delete.
///
/// يحدد عملية تعديل واحدة مثل الحفظ أو التحديث أو الحذف.
class CityOperationInProgress extends CitiesState {
  /// Operation name used to tailor the progress indicator.
  ///
  /// اسم العملية المستخدم لتكييف مؤشر التقدم.
  final String operation;

  /// Optional city name used to contextualize the progress banner.
  ///
  /// اسم مدينة اختياري يوضح سياق شريط التقدم.
  final String? cityName;

  /// Emits a focused progress state for a city mutation.
  ///
  /// يرسل حالة تقدم مركزة لعملية تعديل مدينة.
  const CityOperationInProgress({
    required this.operation,
    this.cityName,
  });

  /// Uses the operation name and optional city context for equality.
  ///
  /// يعتمد على اسم العملية وسياق المدينة الاختياري في المساواة القيمية.
  @override
  List<Object?> get props => [operation, cityName];
}

/// Signals that the last city mutation completed successfully.
///
/// تشير إلى أن آخر عملية على المدينة اكتملت بنجاح.
class CityOperationSuccess extends CitiesState {
  /// Success text presented after the operation completes.
  ///
  /// نص النجاح الذي يظهر بعد اكتمال العملية.
  final String message;

  /// Wraps the success message for one-shot feedback.
  ///
  /// يغلف رسالة النجاح للتغذية الراجعة اللحظية.
  const CityOperationSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Signals that a city mutation failed and the UI should surface feedback.
///
/// تشير إلى فشل تعديل مدينة ويجب أن تعرض الواجهة رسالة مناسبة.
class CityOperationFailure extends CitiesState {
  /// Failure text passed back from the repository layer.
  ///
  /// رسالة الفشل القادمة من طبقة المستودع.
  final String message;

  /// Captures the error message for the failed mutation.
  ///
  /// يلتقط رسالة الخطأ الخاصة بالعملية الفاشلة.
  const CityOperationFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Streams the current upload percentage for a city image.
///
/// يبث النسبة الحالية لتقدم رفع صورة المدينة.
class CityImageUploadProgress extends CitiesState {
  /// Progress ratio between zero and one for the active upload.
  ///
  /// نسبة التقدم بين صفر وواحد للرفع النشط.
  final double progress;

  /// City name associated with the running upload.
  ///
  /// اسم المدينة المرتبط بعملية الرفع الجارية.
  final String cityName;

  /// Publishes granular progress updates for the current image upload.
  ///
  /// ينشر تحديثات تقدم دقيقة لرفع الصورة الحالية.
  const CityImageUploadProgress({
    required this.progress,
    required this.cityName,
  });
  @override
  List<Object?> get props => [progress, cityName];
}
