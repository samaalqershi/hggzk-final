// lib/features/admin_citys/data/repositories/city_images_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/error/exceptions.dart';
import 'package:hggzkportal/core/network/network_info.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/city_image.dart';
import '../../domain/repositories/city_images_repository.dart';
import '../datasources/city_images_remote_datasource.dart';
import '../models/city_image_model.dart';

/// Repository that mediates city image operations between the UI and the API.
///
/// مستودع يتوسط عمليات صور المدن بين الواجهة والـ API.
class CityImagesRepositoryImpl implements CityImagesRepository {
  /// Remote data source used for uploads and gallery mutations.
  ///
  /// مصدر البيانات البعيد المستخدم للرفع وتعديلات المعرض.
  final CityImagesRemoteDataSource remoteDataSource;

  /// Network checker used to avoid remote calls when offline.
  ///
  /// فاحص الشبكة المستخدم لتجنب الاستدعاءات البعيدة عند انقطاع الاتصال.
  final NetworkInfo networkInfo;

  /// Creates the repository around the gallery remote source and connectivity gate.
  ///
  /// ينشئ المستودع حول المصدر البعيد للمعرض وبوابة الاتصال.
  CityImagesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// يرفع وسيطًا واحدًا للمدينة ويعيد النتيجة ككيان نطاقي.
  /// Uploads a single city media item and returns the result as a domain
  /// entity.
  @override
  Future<Either<Failure, CityImage>> uploadImage({
    String? cityId,
    String? tempKey,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final CityImageModel result = await remoteDataSource.uploadImage(
          cityId: cityId,
          tempKey: tempKey,
          filePath: filePath,
          category: category,
          alt: alt,
          isPrimary: isPrimary,
          order: order,
          tags: tags,
          onSendProgress: onSendProgress,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يجلب الوسائط المرتبطة بمدينة أو بمسودة مؤقتة من الخادم.
  /// Fetches the media linked to a city or temporary draft from the backend.
  @override
  Future<Either<Failure, List<CityImage>>> getCityImages(String? cityId,
      {String? tempKey}) async {
    if (await networkInfo.isConnected) {
      try {
        final List<CityImageModel> result =
            await remoteDataSource.getCityImages(cityId, tempKey: tempKey);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يحدّث بيانات وسيط واحد مثل الوسم أو النص البديل أو الترتيب.
  /// Updates a single media item such as its tag, alt text, or order.
  @override
  Future<Either<Failure, bool>> updateImage(
    String imageId,
    Map<String, dynamic> data,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.updateImage(imageId, data);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يحذف وسيطًا واحدًا من المعرض البعيد.
  /// Deletes a single media item from the remote gallery.
  @override
  Future<Either<Failure, bool>> deleteImage(String imageId) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.deleteImage(imageId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يعيد ترتيب الوسائط في المعرض وفق الترتيب الجديد المطلوب.
  /// Reorders the gallery media according to the requested new sequence.
  @override
  Future<Either<Failure, bool>> reorderImages(
    String? cityId,
    String? tempKey,
    List<String> imageIds,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result =
            await remoteDataSource.reorderImages(cityId, tempKey, imageIds);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يعيّن صورةً معينة كصورة الغلاف الأساسية للمدينة.
  /// Marks a specific image as the city's primary cover image.
  @override
  Future<Either<Failure, bool>> setAsPrimaryImage(
    String? cityId,
    String? tempKey,
    String imageId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result =
            await remoteDataSource.setAsPrimaryImage(cityId, tempKey, imageId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يحذف مجموعة من الصور الواحدة تلو الأخرى ويعيد نتيجة جماعية موحدة.
  /// Deletes multiple images one by one and returns a unified batch result.
  @override
  Future<Either<Failure, bool>> deleteMultipleImages(
      List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        bool allDeleted = true;
        for (final imageId in imageIds) {
          final result = await remoteDataSource.deleteImage(imageId);
          if (!result) {
            allDeleted = false;
            break;
          }
        }
        return Right(allDeleted);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  /// يرفع مجموعة صور مع الاحتفاظ بكل صورة نجحت فيها العملية.
  /// Uploads a batch of images while keeping every successfully uploaded item.
  @override
  Future<Either<Failure, List<CityImage>>> uploadMultipleImages({
    String? cityId,
    String? tempKey,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final List<CityImageModel> uploadedImages = [];
        int order = 0;

        for (final filePath in filePaths) {
          try {
            final result = await remoteDataSource.uploadImage(
              cityId: cityId,
              tempKey: tempKey,
              filePath: filePath,
              category: category,
              isPrimary: order == 0, // الصورة الأولى تكون رئيسية
              order: order,
              tags: tags,
              onSendProgress: onProgress != null
                  ? (sent, total) => onProgress(filePath, sent, total)
                  : null,
            );
            uploadedImages.add(result);
            order++;
          } catch (e) {
            // تجاهل الصور الفاشلة والاستمرار
            continue;
          }
        }

        if (uploadedImages.isEmpty) {
          return const Left(ServerFailure('Failed to upload any images'));
        }

        return Right(uploadedImages);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
