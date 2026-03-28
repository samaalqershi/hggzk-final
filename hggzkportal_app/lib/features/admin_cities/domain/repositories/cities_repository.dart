import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/city.dart';

/// Contract for city administration actions regardless of the underlying data source.
///
/// عقد يحدد عمليات إدارة المدن بغض النظر عن مصدر البيانات المستخدم.
abstract class CitiesRepository {
  /// Returns the city collection with optional pagination and filters.
  ///
  /// يعيد مجموعة المدن مع دعم اختياري للترقيم والتصفية.
  Future<Either<Failure, List<City>>> getCities({
    int? page,
    int? limit,
    String? search,
    String? country,
    bool? isActive,
  });

  /// Persists a full city batch when the admin edits the city catalog in bulk.
  ///
  /// يحفظ دفعة كاملة من المدن عند تعديل الدليل الإداري بشكل جماعي.
  Future<Either<Failure, bool>> saveCities(List<City> cities);

  /// Creates a city entry and returns the persisted representation.
  ///
  /// ينشئ مدينة جديدة ويعيد النسخة التي تم حفظها.
  Future<Either<Failure, City>> createCity(City city);

  /// Rewrites an existing city identified by its previous name.
  ///
  /// يحدّث مدينة موجودة اعتمادًا على اسمها السابق.
  Future<Either<Failure, City>> updateCity(String oldName, City city);

  /// Removes a city from the catalog and returns the operation outcome.
  ///
  /// يحذف مدينة من الدليل ويعيد نتيجة العملية.
  Future<Either<Failure, bool>> deleteCity(String name);

  /// Searches the local or remote city catalog using a free-text query.
  ///
  /// يبحث داخل دليل المدن المحلي أو البعيد اعتمادًا على النص المدخل.
  Future<Either<Failure, List<City>>> searchCities(String query);

  /// Collects city analytics for the requested time range.
  ///
  /// يجمع إحصائيات المدن للفترة الزمنية المطلوبة.
  Future<Either<Failure, Map<String, dynamic>>> getCitiesStatistics(
      {DateTime? startDate, DateTime? endDate});

  /// Uploads a city image and streams progress updates for the UI.
  ///
  /// يرفع صورة للمدينة مع بث تقدم الرفع للواجهة.
  Future<Either<Failure, String>> uploadCityImage(
      String cityName, String imagePath,
      {ProgressCallback? onSendProgress});

  /// Deletes a city image by its URL or backend reference.
  ///
  /// يحذف صورة مدينة عبر رابطها أو المرجع الذي يعتمده الخادم.
  Future<Either<Failure, bool>> deleteCityImage(String imageUrl);
}
