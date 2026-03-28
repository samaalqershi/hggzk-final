// lib/features/admin_citys/presentation/bloc/city_images/city_images_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import '../../../domain/entities/city_image.dart';
import '../../../domain/usecases/city_images/upload_city_image_usecase.dart';
import '../../../domain/usecases/city_images/upload_multiple_city_images_usecase.dart';
import '../../../domain/usecases/city_images/get_city_images_usecase.dart';
import '../../../domain/usecases/city_images/update_city_image_usecase.dart';
import '../../../domain/usecases/city_images/delete_city_image_usecase.dart';
import '../../../domain/usecases/city_images/delete_multiple_city_images_usecase.dart';
import '../../../domain/usecases/city_images/reorder_city_images_usecase.dart';
import '../../../domain/usecases/city_images/set_primary_city_image_usecase.dart';
import 'city_images_event.dart';
import 'city_images_state.dart';

/// Manages the gallery lifecycle for city images: load, upload, reorder, and delete.
///
/// يدير دورة حياة معرض صور المدينة: التحميل، والرفع، وإعادة الترتيب، والحذف.
class CityImagesBloc extends Bloc<CityImagesEvent, CityImagesState> {
  /// Use case that uploads a single media asset.
  ///
  /// use case الذي يرفع ملف وسائط واحدًا.
  final UploadCityImageUseCase uploadCityImage;

  /// Use case that uploads multiple media assets in sequence.
  ///
  /// use case الذي يرفع عدة ملفات وسائط بالتتابع.
  final UploadMultipleCityImagesUseCase uploadMultipleImages;

  /// Use case that loads the current gallery state.
  ///
  /// use case الذي يحمل حالة المعرض الحالية.
  final GetCityImagesUseCase getCityImages;

  /// Use case that patches gallery metadata.
  ///
  /// use case الذي يعدل بيانات المعرض الوصفية.
  final UpdateCityImageUseCase updateCityImage;

  /// Use case that deletes a single gallery item.
  ///
  /// use case الذي يحذف عنصرًا واحدًا من المعرض.
  final DeleteCityImageUseCase deleteCityImage;

  /// Use case that deletes a batch of gallery items.
  ///
  /// use case الذي يحذف دفعة من عناصر المعرض.
  final DeleteMultipleCityImagesUseCase deleteMultipleImages;

  /// Use case that persists the user-selected gallery order.
  ///
  /// use case الذي يحفظ ترتيب المعرض الذي اختاره المستخدم.
  final ReorderCityImagesUseCase reorderImages;

  /// Use case that promotes one image to be the primary cover.
  ///
  /// use case الذي يرفع صورة لتصبح الغلاف الأساسي.
  final SetPrimaryCityImageUseCase setPrimaryImage;

  /// Current gallery snapshot kept in memory to support optimistic updates.
  ///
  /// لقطة المعرض الحالية المحفوظة في الذاكرة لدعم التحديثات السريعة.
  List<CityImage> _currentImages = [];

  /// IDs of currently selected images for batch actions.
  ///
  /// معرفات الصور المحددة حاليًا لعمليات الدفعة.
  Set<String> _selectedImageIds = {};

  /// City context attached to the gallery state.
  ///
  /// سياق المدينة المرتبط بحالة المعرض.
  String? _currentCityId;

  /// Wires gallery use cases into the event pipeline.
  ///
  /// يربط use cases الخاصة بالمعرض بخط معالجة الأحداث.
  CityImagesBloc({
    required this.uploadCityImage,
    required this.uploadMultipleImages,
    required this.getCityImages,
    required this.updateCityImage,
    required this.deleteCityImage,
    required this.deleteMultipleImages,
    required this.reorderImages,
    required this.setPrimaryImage,
  }) : super(const CityImagesInitial()) {
    on<LoadCityImagesEvent>(_onLoadCityImages);
    on<UploadCityImageEvent>(_onUploadCityImage);
    on<UploadMultipleCityImagesEvent>(_onUploadMultipleImages);
    on<UpdateCityImageEvent>(_onUpdateCityImage);
    on<DeleteCityImageEvent>(_onDeleteCityImage);
    on<DeleteMultipleCityImagesEvent>(_onDeleteMultipleImages);
    on<ReorderCityImagesEvent>(_onReorderCityImages);
    on<SetPrimaryCityImageEvent>(_onSetPrimaryCityImage);
    on<ClearCityImagesEvent>(_onClearCityImages);
    on<RefreshCityImagesEvent>(_onRefreshCityImages);
    on<ToggleCityImageSelectionEvent>(_onToggleCityImageSelection);
    on<SelectAllCityImagesEvent>(_onSelectAllCityImages);
    on<DeselectAllCityImagesEvent>(_onDeselectAllCityImages);
  }

  /// Loads the gallery when a saved city or temporary draft context is present.
  ///
  /// يحمل المعرض عند وجود مدينة محفوظة أو سياق مسودة مؤقتة.
  Future<void> _onLoadCityImages(
    LoadCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    // منع جلب الصور إذا لم يكن هناك cityId أو tempKey
    if ((event.cityId == null || event.cityId!.isEmpty) &&
        (event.tempKey == null || event.tempKey!.isEmpty)) {
      emit(const CityImagesLoaded(images: []));
      return;
    }

    emit(const CityImagesLoading(message: 'Loading images...'));

    final Either<Failure, List<CityImage>> result = await getCityImages(
        GetCityImagesParams(cityId: event.cityId, tempKey: event.tempKey));

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (images) {
        _currentImages = images;
        _currentCityId = event.cityId;
        emit(CityImagesLoaded(
          images: images,
          currentCityId: event.cityId,
        ));
      },
    );
  }

  /// Uploads one file and reflects live progress in the state stream.
  ///
  /// يرفع ملفًا واحدًا ويعرض التقدم الحي داخل تيار الحالة.
  Future<void> _onUploadCityImage(
    UploadCityImageEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    // تحقق من وجود cityId أو tempKey قبل الرفع
    if ((event.cityId == null || event.cityId!.isEmpty) &&
        (event.tempKey == null || event.tempKey!.isEmpty)) {
      emit(CityImagesError(
        message: 'لا يمكن رفع الصور بدون معرف الوحدة أو tempKey',
        previousImages: _currentImages,
      ));
      return;
    }

    emit(CityImageUploading(
      currentImages: _currentImages,
      uploadingFileName: event.filePath.split('/').last,
    ));

    final params = UploadImageParams(
      cityId: event.cityId,
      tempKey: event.tempKey,
      filePath: event.filePath,
      category: event.category,
      alt: event.alt,
      isPrimary: event.isPrimary,
      order: event.order,
      tags: event.tags,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          emit(CityImageUploading(
            currentImages: _currentImages,
            uploadingFileName: event.filePath.split('/').last,
            uploadProgress: progress,
          ));
        }
      },
    );

    final Either<Failure, CityImage> result = await uploadCityImage(params);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (image) {
        _currentImages.add(image);
        emit(CityImageUploaded(
          uploadedImage: image,
          allImages: List.from(_currentImages),
        ));
        // بعد ثانية واحدة، عرض قائمة الصور المحدثة
        Future.delayed(const Duration(seconds: 1), () {
          // add(LoadCityImagesEvent(cityId: event.cityId));
        });
      },
    );
  }

  /// Uploads several files and keeps the UI informed about progress per file.
  ///
  /// يرفع عدة ملفات ويُبقي الواجهة على اطلاع بتقدم كل ملف.
  Future<void> _onUploadMultipleImages(
    UploadMultipleCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    emit(CityImageUploading(
      currentImages: _currentImages,
      totalFiles: event.filePaths.length,
      currentFileIndex: 0,
    ));

    final params = UploadMultipleImagesParams(
      cityId: event.cityId,
      tempKey: event.tempKey,
      filePaths: event.filePaths,
      category: event.category,
      tags: event.tags,
      onProgress: (filePath, sent, total) {
        if (total > 0) {
          final progress = sent / total;
          emit(CityImageUploading(
            currentImages: _currentImages,
            uploadingFileName: filePath.split('/').last,
            uploadProgress: progress,
            totalFiles: event.filePaths.length,
          ));
        }
      },
    );

    final Either<Failure, List<CityImage>> result =
        await uploadMultipleImages(params);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (images) {
        _currentImages.addAll(images);
        emit(MultipleImagesUploaded(
          uploadedImages: images,
          allImages: List.from(_currentImages),
          successCount: images.length,
          failedCount: event.filePaths.length - images.length,
        ));
        // بعد ثانية واحدة، عرض قائمة الصور المحدثة
        Future.delayed(const Duration(seconds: 1), () {
          add(LoadCityImagesEvent(
              cityId: event.cityId, tempKey: event.tempKey));
        });
      },
    );
  }

  /// Patches an image and reloads the gallery when the server confirms success.
  ///
  /// يعدل صورة ثم يعيد تحميل المعرض عندما يؤكد الخادم النجاح.
  Future<void> _onUpdateCityImage(
    UpdateCityImageEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    emit(CityImageUpdating(
      currentImages: _currentImages,
      imageId: event.imageId,
    ));

    final params = UpdateImageParams(
      imageId: event.imageId,
      data: event.data,
    );

    final Either<Failure, bool> result = await updateCityImage(params);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (success) {
        if (success && _currentCityId != null) {
          // إعادة تحميل الصور للحصول على البيانات المحدثة
          add(LoadCityImagesEvent(cityId: _currentCityId!));
        } else {
          emit(CityImageUpdated(
            updatedImages: _currentImages,
          ));
        }
      },
    );
  }

  /// Deletes a single image and removes it from the in-memory snapshot.
  ///
  /// يحذف صورة واحدة ويزيلها من اللقطة الموجودة في الذاكرة.
  Future<void> _onDeleteCityImage(
    DeleteCityImageEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    emit(CityImageDeleting(
      currentImages: _currentImages,
      imageId: event.imageId,
    ));

    final Either<Failure, bool> result = await deleteCityImage(event.imageId);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (success) {
        if (success) {
          _currentImages.removeWhere((image) => image.id == event.imageId);
          _selectedImageIds.remove(event.imageId);
          emit(CityImageDeleted(
            remainingImages: List.from(_currentImages),
          ));
        }
      },
    );
  }

  /// Deletes all selected gallery items in one operation.
  ///
  /// يحذف كل عناصر المعرض المحددة في عملية واحدة.
  Future<void> _onDeleteMultipleImages(
    DeleteMultipleCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    emit(CityImagesLoading(message: 'Deleting selected images...'));

    final Either<Failure, bool> result =
        await deleteMultipleImages(event.imageIds);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (success) {
        if (success) {
          _currentImages
              .removeWhere((image) => event.imageIds.contains(image.id));
          _selectedImageIds.clear();
          emit(MultipleImagesDeleted(
            remainingImages: List.from(_currentImages),
            deletedCount: event.imageIds.length,
          ));
        }
      },
    );
  }

  /// Persists the requested order and mirrors it locally on success.
  ///
  /// يحفظ الترتيب المطلوب ويعكسه محليًا عند النجاح.
  Future<void> _onReorderCityImages(
    ReorderCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    emit(ImagesReordering(currentImages: _currentImages));

    final params = ReorderImagesParams(
      cityId: event.cityId,
      tempKey: event.tempKey,
      imageIds: event.imageIds,
    );

    final Either<Failure, bool> result = await reorderImages(params);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (success) {
        if (success) {
          // إعادة ترتيب الصور محلياً
          final Map<String, CityImage> imageMap = {
            for (var image in _currentImages) image.id: image
          };
          _currentImages = event.imageIds
              .map((id) => imageMap[id])
              .whereType<CityImage>()
              .toList();

          emit(ImagesReordered(
            reorderedImages: List.from(_currentImages),
          ));
        }
      },
    );
  }

  /// Promotes the selected image to primary and reloads the gallery afterward.
  ///
  /// يرقّي الصورة المحددة إلى أساسية ثم يعيد تحميل المعرض بعدها.
  Future<void> _onSetPrimaryCityImage(
    SetPrimaryCityImageEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    emit(CityImagesLoading(message: 'Setting primary image...'));

    final params = SetPrimaryImageParams(
      cityId: event.cityId,
      tempKey: event.tempKey,
      imageId: event.imageId,
    );

    final Either<Failure, bool> result = await setPrimaryImage(params);

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (success) {
        if (success) {
          // تحديث الصور محلياً
          for (var image in _currentImages) {
            if (image.id == event.imageId) {
              // نحتاج لتحديث isPrimary هنا
              // قد نحتاج لإعادة تحميل الصور من الخادم
            }
          }

          // إعادة تحميل الصور للحصول على البيانات المحدثة (الحفاظ على tempKey)
          add(LoadCityImagesEvent(
              cityId: event.cityId, tempKey: event.tempKey));
        }
      },
    );
  }

  /// Clears the gallery snapshot and selection metadata.
  ///
  /// يمسح لقطة المعرض وبيانات الاختيار.
  void _onClearCityImages(
    ClearCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) {
    _currentImages = [];
    _selectedImageIds = {};
    _currentCityId = null;
    emit(const CityImagesInitial());
  }

  /// Refreshes the gallery without switching into the loading placeholder.
  ///
  /// يحدّث المعرض من دون الانتقال إلى شاشة التحميل.
  Future<void> _onRefreshCityImages(
    RefreshCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) async {
    // لا نظهر loading state عند التحديث
    final Either<Failure, List<CityImage>> result = await getCityImages(
        GetCityImagesParams(cityId: event.cityId, tempKey: event.tempKey));

    result.fold(
      (failure) => emit(CityImagesError(
        message: _mapFailureToMessage(failure),
        previousImages: _currentImages,
      )),
      (images) {
        _currentImages = images;
        _currentCityId = event.cityId;
        emit(CityImagesLoaded(
          images: images,
          currentCityId: event.cityId,
          selectedImageIds: _selectedImageIds,
          isSelectionMode: _selectedImageIds.isNotEmpty,
        ));
      },
    );
  }

  /// Toggles one image in or out of the current selection set.
  ///
  /// يبدّل صورة واحدة داخل أو خارج مجموعة الاختيار الحالية.
  void _onToggleCityImageSelection(
    ToggleCityImageSelectionEvent event,
    Emitter<CityImagesState> emit,
  ) {
    if (_selectedImageIds.contains(event.imageId)) {
      _selectedImageIds.remove(event.imageId);
    } else {
      _selectedImageIds.add(event.imageId);
    }

    emit(CityImagesLoaded(
      images: _currentImages,
      currentCityId: _currentCityId,
      selectedImageIds: Set.from(_selectedImageIds),
      isSelectionMode: _selectedImageIds.isNotEmpty,
    ));
  }

  /// Selects every visible image so batch actions can be applied.
  ///
  /// يحدد كل صورة ظاهرة حتى يمكن تطبيق عمليات الدفعة.
  void _onSelectAllCityImages(
    SelectAllCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) {
    _selectedImageIds = _currentImages.map((image) => image.id).toSet();

    emit(CityImagesLoaded(
      images: _currentImages,
      currentCityId: _currentCityId,
      selectedImageIds: Set.from(_selectedImageIds),
      isSelectionMode: true,
    ));
  }

  /// Clears every selected image from the current gallery session.
  ///
  /// يزيل تحديد كل الصور من جلسة المعرض الحالية.
  void _onDeselectAllCityImages(
    DeselectAllCityImagesEvent event,
    Emitter<CityImagesState> emit,
  ) {
    _selectedImageIds.clear();

    emit(CityImagesLoaded(
      images: _currentImages,
      currentCityId: _currentCityId,
      selectedImageIds: Set.from(_selectedImageIds),
      isSelectionMode: false,
    ));
  }

  /// Converts repository failures into strings the UI can safely show.
  ///
  /// يحول فشل المستودع إلى نصوص يمكن عرضها بأمان في الواجهة.
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case NetworkFailure:
        return 'Network connection error. Please check your internet connection.';
      case CacheFailure:
        return 'Cache Error';
      default:
        return 'Unexpected error occurred';
    }
  }

  /// العربية: يفرغ حالة الذاكرة المؤقتة للمعرض قبل إغلاق الـ BLoC حتى لا تبقى بيانات عالقة.
  /// English: Clears the in-memory gallery state before the bloc closes so no stale data remains.
  @override
  Future<void> close() {
    _currentImages = [];
    _selectedImageIds = {};
    _currentCityId = null;
    return super.close();
  }
}
