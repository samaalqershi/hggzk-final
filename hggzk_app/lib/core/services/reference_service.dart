import 'package:get_it/get_it.dart';
import 'package:hggzk/features/reference/data/datasources/reference_local_datasource.dart';
import 'package:hggzk/features/reference/domain/entities/city.dart';
import 'package:hggzk/features/reference/domain/entities/currency.dart';

/// يوفّر وصولًا مباشرًا إلى بيانات المدن والعملات الموجودة في الكاش المحلي.
/// Provides direct access to cached city and currency reference data.
class ReferenceService {
  /// مصدر المرجعيات المحلي الذي يقرأ من التخزين المهيأ مسبقًا.
  /// Local reference datasource backed by the cached storage.
  final ReferenceLocalDataSource _local;

  /// يربط الخدمة بمصدر المرجعيات المحلي داخل الحاوية.
  /// Binds the service to the local datasource managed by the container.
  ReferenceService._(this._local);

  /// يعيد النسخة الوحيدة التي تعتمد على نفس مصدر المرجعيات المحلي.
  /// Returns the shared instance backed by the same cached reference source.
  static ReferenceService get instance =>
      ReferenceService._(GetIt.instance<ReferenceLocalDataSource>());

  /// يعيد المدن المحفوظة محليًا بصيغة الكيانات التي تفهمها الواجهة.
  /// Returns cached cities mapped into the domain entities the UI expects.
  List<City> getCachedCities() =>
      _local.getCachedCities().map((e) => e.toEntity()).toList();

  /// يعيد العملات المخزنة محليًا بالشكل الذي تعتمد عليه الطبقات العليا.
  /// Returns cached currencies in the domain shape used by higher layers.
  List<Currency> getCachedCurrencies() =>
      _local.getCachedCurrencies().map((e) => e.toEntity()).toList();
}
