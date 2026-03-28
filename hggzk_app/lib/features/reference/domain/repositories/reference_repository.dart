import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/city.dart';
import '../entities/currency.dart';

/// Provides repository behavior for `ReferenceRepository`.
/// العربية: يوفر سلوك المستودع الخاص بـ `ReferenceRepository`.
abstract class ReferenceRepository {
  /// Exposes the cities.
  /// العربية: يعيد cities.
  Future<Either<Failure, List<City>>> getCities({bool forceRefresh = false});

  /// Exposes the currencies.
  /// العربية: يعيد currencies.
  Future<Either<Failure, List<Currency>>> getCurrencies(
      {bool forceRefresh = false});
}
