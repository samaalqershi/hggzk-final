import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/network/api_exceptions.dart';
import '../../domain/entities/nearby_place.dart';
import '../../domain/repositories/nearby_places_repository.dart';
import '../datasources/nearby_places_remote_datasource.dart';

class NearbyPlacesRepositoryImpl implements NearbyPlacesRepository {
  final NearbyPlacesRemoteDataSource remoteDataSource;

  NearbyPlacesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NearbyPlace>>> getNearbyPlaces({
    String? propertyId,
    String? searchTerm,
    bool? isActive,
  }) async {
    try {
      final result = await remoteDataSource.getNearbyPlaces(
        propertyId: propertyId,
        searchTerm: searchTerm,
        isActive: isActive,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('تعذر جلب الأماكن القريبة'));
    }
  }

  @override
  Future<Either<Failure, NearbyPlace>> getNearbyPlaceById(
      String nearbyPlaceId) async {
    try {
      final result = await remoteDataSource.getNearbyPlaceById(nearbyPlaceId);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('تعذر جلب بيانات المكان القريب'));
    }
  }

  @override
  Future<Either<Failure, String>> createNearbyPlace(
      Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createNearbyPlace(data);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('تعذر إنشاء المكان القريب'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateNearbyPlace(
      String nearbyPlaceId, Map<String, dynamic> data) async {
    try {
      final result =
          await remoteDataSource.updateNearbyPlace(nearbyPlaceId, data);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('تعذر تحديث المكان القريب'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNearbyPlace(String nearbyPlaceId) async {
    try {
      final result = await remoteDataSource.deleteNearbyPlace(nearbyPlaceId);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('تعذر حذف المكان القريب'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleNearbyPlaceStatus(
      String nearbyPlaceId) async {
    try {
      final result =
          await remoteDataSource.toggleNearbyPlaceStatus(nearbyPlaceId);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('تعذر تغيير حالة المكان القريب'));
    }
  }
}
