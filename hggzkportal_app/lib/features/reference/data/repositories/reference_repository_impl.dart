import 'package:hggzkportal/core/error/error_handler.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/city.dart' as domain;
import '../../domain/entities/currency.dart' as domain;
import '../../domain/repositories/reference_repository.dart';
import '../datasources/reference_local_datasource.dart';
import '../datasources/reference_remote_datasource.dart';

/// يعرّف الكلاس `ReferenceRepositoryImpl`.
/// Describes the `ReferenceRepositoryImpl` class.
class ReferenceRepositoryImpl implements ReferenceRepository {
  /// Holds the `remote` value.
  /// العربية: يخزن القيمة `remote`.
  final ReferenceRemoteDataSource remote;

  /// يخزن العضو `local`.
  /// Holds the `local` member.
  final ReferenceLocalDataSource local;

  /// ينشئ مثيلاً من `ReferenceRepositoryImpl`.
  /// Builds an instance of `ReferenceRepositoryImpl`.
  ReferenceRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<domain.City>>> getCities(
      {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && local.isCitiesCacheFresh()) {
        final cached = local.getCachedCities();
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toEntity()).toList());
        }
      }
      final remoteList = await remote.getCities();
      await local.cacheCities(remoteList);
      return Right(remoteList.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cached = local.getCachedCities();
      if (cached.isNotEmpty) {
        return Right(cached.map((e) => e.toEntity()).toList());
      }
      return ErrorHandler.handle(e);
    }
  }

  @override
  Future<Either<Failure, List<domain.Currency>>> getCurrencies(
      {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && local.isCurrenciesCacheFresh()) {
        final cached = local.getCachedCurrencies();
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toEntity()).toList());
        }
      }
      final remoteList = await remote.getCurrencies();
      await local.cacheCurrencies(remoteList);
      return Right(remoteList.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cached = local.getCachedCurrencies();
      if (cached.isNotEmpty) {
        return Right(cached.map((e) => e.toEntity()).toList());
      }
      return ErrorHandler.handle(e);
    }
  }
}
