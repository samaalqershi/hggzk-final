import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/city.dart';
import '../entities/currency.dart';

/// هذا العقد يحدد ما يحتاجه نظام المراجع من مدن وعملات دون أن
/// يفرض طريقة الجلب أو التخزين.
/// This contract defines what the reference system needs for cities
/// and currencies without dictating how they are fetched or stored.
abstract class ReferenceRepository {
  /// يجلب المدن المرجعية مع خيار التحديث الإجباري عندما يريد
  /// المستهلك تجاوز النسخة المخزنة.
  /// Fetches reference cities with an optional force-refresh when
  /// the consumer wants to bypass cached data.
  Future<Either<Failure, List<City>>> getCities({bool forceRefresh = false});

  /// يجلب العملات المرجعية بالطريقة نفسها حتى تبقى واجهات الإعداد
  /// والبحث متسقة.
  /// Fetches reference currencies in the same way so settings and
  /// search screens stay consistent.
  Future<Either<Failure, List<Currency>>> getCurrencies(
      {bool forceRefresh = false});
}
