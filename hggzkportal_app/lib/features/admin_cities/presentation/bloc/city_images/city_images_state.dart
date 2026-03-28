import 'package:equatable/equatable.dart';
import '../../../domain/entities/city_image.dart';

/// العربية: يعرّف حالات معرض صور المدينة من السكون إلى الرفع والحذف وإعادة الترتيب.
/// English: Defines the city image gallery states from idle to upload, deletion, and reorder flows.
abstract class CityImagesState extends Equatable {
  /// العربية: ينشئ الأساس المشترك لجميع حالات المعرض.
  /// English: Creates the shared base for all gallery states.
  const CityImagesState();

  /// العربية: لا توجد حقول مشتركة هنا، لذا تعتمد المساواة على الفئات الفرعية.
  /// English: No shared fields exist here, so equality is controlled by subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: تمثل الحالة قبل تحميل أي معرض أو سياق مدينة.
/// English: Represents the state before any gallery or city context has been loaded.
class CityImagesInitial extends CityImagesState {
  /// العربية: ينشئ حالة السكون الأولية.
  /// English: Creates the initial idle state.
  const CityImagesInitial();
}

/// العربية: تشير إلى أن المعرض قيد الجلب أو المعالجة حاليًا.
/// English: Indicates that the gallery is currently being fetched or processed.
class CityImagesLoading extends CityImagesState {
  /// العربية: النص الظاهر للمستخدم أثناء التحميل.
  /// English: The user-facing message shown while loading.
  final String? message;

  /// العربية: ينشئ حالة التحميل مع رسالة اختيارية.
  /// English: Creates the loading state with an optional message.
  const CityImagesLoading({this.message});

  /// العربية: يعتمد على رسالة التحميل عند المقارنة.
  /// English: Uses the loading message for equality.
  @override
  List<Object?> get props => [message];
}

/// العربية: تحمل الصور الحالية مع سياق المدينة وحالة التحديد.
/// English: Holds the current images together with the city context and selection state.
class CityImagesLoaded extends CityImagesState {
  /// العربية: عناصر المعرض الحالية المتاحة للمستخدم الإداري.
  /// English: The current gallery items available to the admin user.
  final List<CityImage> images;

  /// العربية: معرّفات الصور المحددة حاليًا لعمليات الدفعة.
  /// English: The identifiers of the images currently selected for batch actions.
  final Set<String> selectedImageIds;

  /// العربية: سياق المدينة المرتبط حاليًا بالمعرض المحمل.
  /// English: The city context currently associated with the loaded gallery.
  final String? currentCityId;

  /// العربية: يوضح ما إذا كان المعرض في وضع التحديد.
  /// English: Indicates whether the gallery is currently in selection mode.
  final bool isSelectionMode;

  /// العربية: ينشئ حالة المعرض المحمّل بكل عناصره الحالية.
  /// English: Creates the loaded gallery state with its current content.
  const CityImagesLoaded({
    required this.images,
    this.selectedImageIds = const {},
    this.currentCityId,
    this.isSelectionMode = false,
  });

  /// العربية: ينشئ نسخة معدلة مع إبقاء القيم غير المحددة كما هي.
  /// English: Creates a modified copy while preserving unspecified values.
  CityImagesLoaded copyWith({
    List<CityImage>? images,
    Set<String>? selectedImageIds,
    String? currentCityId,
    bool? isSelectionMode,
  }) {
    return CityImagesLoaded(
      images: images ?? this.images,
      selectedImageIds: selectedImageIds ?? this.selectedImageIds,
      currentCityId: currentCityId ?? this.currentCityId,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  /// العربية: يعتمد على الصور المحددة وسياق المدينة ووضع التحديد.
  /// English: Uses the images, selection set, city context, and selection mode for equality.
  @override
  List<Object?> get props =>
      [images, selectedImageIds, currentCityId, isSelectionMode];
}

/// العربية: تمثل فشلًا في عمليات المعرض مع إمكانية الاحتفاظ بآخر صور ناجحة.
/// English: Represents a gallery failure while optionally keeping the last successful images.
class CityImagesError extends CityImagesState {
  /// العربية: رسالة الخطأ التي تظهر عند فشل عمليات المعرض.
  /// English: The error message shown when gallery operations fail.
  final String message;

  /// العربية: الصور المحتفظ بها من آخر تحميل ناجح إن وجدت.
  /// English: The images preserved from the previous successful load, if any.
  final List<CityImage>? previousImages;

  /// العربية: ينشئ حالة الخطأ مع الرسالة واللقطة السابقة الاختيارية.
  /// English: Creates the error state with its message and optional previous snapshot.
  const CityImagesError({
    required this.message,
    this.previousImages,
  });

  /// العربية: يعتمد على رسالة الخطأ واللقطة السابقة عند المقارنة.
  /// English: Uses the error message and previous snapshot for equality.
  @override
  List<Object?> get props => [message, previousImages];
}

/// العربية: تمثل رفع صورة أو عدة صور مع متابعة التقدم الحالي.
/// English: Represents uploading one or more images while tracking current progress.
class CityImageUploading extends CityImagesState {
  /// العربية: لقطة المعرض الظاهرة أثناء تقدم الرفع.
  /// English: The gallery snapshot visible while upload is in progress.
  final List<CityImage> currentImages;

  /// العربية: نسبة تقدم الملف النشط حاليًا عندما تكون متاحة.
  /// English: The progress ratio for the currently active file when available.
  final double? uploadProgress;

  /// العربية: اسم الملف المعروض في مؤشرات التقدم.
  /// English: The file name shown in progress indicators.
  final String? uploadingFileName;

  /// العربية: فهرس الملف النشط داخل الرفع المتعدد.
  /// English: The index of the active file in a multi-file upload flow.
  final int? currentFileIndex;

  /// العربية: العدد الإجمالي للملفات في دفعة الرفع الحالية.
  /// English: The total number of files in the current batch upload.
  final int? totalFiles;

  /// العربية: ينشئ حالة الرفع مع بيانات التقدم الحالية.
  /// English: Creates the uploading state with its current progress data.
  const CityImageUploading({
    required this.currentImages,
    this.uploadProgress,
    this.uploadingFileName,
    this.currentFileIndex,
    this.totalFiles,
  });

  /// العربية: يعتمد على لقطة المعرض ومؤشرات التقدم الحالية.
  /// English: Uses the gallery snapshot and current progress indicators for equality.
  @override
  List<Object?> get props => [
        currentImages,
        uploadProgress,
        uploadingFileName,
        currentFileIndex,
        totalFiles,
      ];
}

/// العربية: تمثل نجاح رفع صورة واحدة وإضافة نتيجتها إلى المعرض.
/// English: Represents a successful single-image upload and its addition to the gallery.
class CityImageUploaded extends CityImagesState {
  /// العربية: بيانات الصورة المرجعة بعد نجاح الرفع.
  /// English: The image metadata returned after a successful upload.
  final CityImage uploadedImage;

  /// العربية: لقطة المعرض بعد إضافة الصورة الجديدة.
  /// English: The gallery snapshot after the new image has been added.
  final List<CityImage> allImages;

  /// العربية: نص التأكيد الذي يظهر بعد اكتمال الرفع.
  /// English: The confirmation text shown after the upload completes.
  final String successMessage;

  /// العربية: ينشئ حالة نجاح الرفع لصورة واحدة.
  /// English: Creates the single-image upload success state.
  const CityImageUploaded({
    required this.uploadedImage,
    required this.allImages,
    this.successMessage = 'Image uploaded successfully',
  });

  /// العربية: يعتمد على الصورة المرفوعة واللقطة النهائية ورسالة النجاح.
  /// English: Uses the uploaded image, final gallery snapshot, and success message for equality.
  @override
  List<Object?> get props => [uploadedImage, allImages, successMessage];
}

/// العربية: تمثل نجاح رفع عدة صور دفعة واحدة.
/// English: Represents a successful multi-image batch upload.
class MultipleImagesUploaded extends CityImagesState {
  /// العربية: الصور التي رُفعت بنجاح في الدفعة الحالية.
  /// English: The images successfully uploaded in the current batch.
  final List<CityImage> uploadedImages;

  /// العربية: لقطة المعرض الكاملة بعد الرفع الجماعي.
  /// English: The full gallery snapshot after the batch upload.
  final List<CityImage> allImages;

  /// العربية: عدد العناصر التي رُفعت بنجاح.
  /// English: The number of items uploaded successfully.
  final int successCount;

  /// العربية: عدد العناصر التي فشلت أثناء الدفعة.
  /// English: The number of items that failed during the batch.
  final int failedCount;

  /// العربية: نص التأكيد لإكمال الرفع الجماعي.
  /// English: The confirmation text for batch upload completion.
  final String successMessage;

  /// العربية: ينشئ حالة نجاح الرفع الجماعي.
  /// English: Creates the multi-image upload success state.
  const MultipleImagesUploaded({
    required this.uploadedImages,
    required this.allImages,
    required this.successCount,
    this.failedCount = 0,
    this.successMessage = 'Images uploaded successfully',
  });

  /// العربية: يعتمد على الصور المرفوعة واللقطة النهائية وعدد النجاح والفشل.
  /// English: Uses the uploaded images, final gallery snapshot, and success/failure counts for equality.
  @override
  List<Object?> get props => [
        uploadedImages,
        allImages,
        successCount,
        failedCount,
        successMessage,
      ];
}

/// العربية: تمثل حالة حذف صورة واحدة من المعرض.
/// English: Represents the state of deleting a single image from the gallery.
class CityImageDeleting extends CityImagesState {
  /// العربية: لقطة المعرض قبل اكتمال الحذف.
  /// English: The gallery snapshot before deletion completes.
  final List<CityImage> currentImages;

  /// العربية: معرّف الصورة الجاري حذفها.
  /// English: The identifier of the image currently being deleted.
  final String imageId;

  /// العربية: ينشئ حالة الحذف لصورة واحدة.
  /// English: Creates the single-image deletion state.
  const CityImageDeleting({
    required this.currentImages,
    required this.imageId,
  });

  /// العربية: يعتمد على لقطة المعرض ومعرّف الصورة المحذوفة.
  /// English: Uses the gallery snapshot and image id for equality.
  @override
  List<Object?> get props => [currentImages, imageId];
}

/// العربية: تمثل نجاح حذف صورة واحدة من المعرض.
/// English: Represents a successful deletion of a single gallery image.
class CityImageDeleted extends CityImagesState {
  /// العربية: عناصر المعرض المتبقية بعد نجاح الحذف.
  /// English: The gallery items left after the delete succeeds.
  final List<CityImage> remainingImages;

  /// العربية: نص التأكيد لعملية الحذف.
  /// English: The confirmation text for the deletion.
  final String successMessage;

  /// العربية: ينشئ حالة نجاح حذف الصورة.
  /// English: Creates the single-image delete success state.
  const CityImageDeleted({
    required this.remainingImages,
    this.successMessage = 'Image deleted successfully',
  });

  /// العربية: يعتمد على الصور المتبقية ورسالة النجاح.
  /// English: Uses the remaining images and success message for equality.
  @override
  List<Object?> get props => [remainingImages, successMessage];
}

/// العربية: تمثل نجاح حذف عدة صور دفعة واحدة.
/// English: Represents a successful batch deletion of multiple images.
class MultipleImagesDeleted extends CityImagesState {
  /// العربية: عناصر المعرض المتبقية بعد الحذف الجماعي.
  /// English: The gallery items left after the batch deletion.
  final List<CityImage> remainingImages;

  /// العربية: عدد العناصر التي حُذفت في العملية.
  /// English: The number of items removed in the operation.
  final int deletedCount;

  /// العربية: نص التأكيد للحذف الجماعي.
  /// English: The confirmation text for the batch delete.
  final String successMessage;

  /// العربية: ينشئ حالة نجاح الحذف الجماعي.
  /// English: Creates the batch-delete success state.
  const MultipleImagesDeleted({
    required this.remainingImages,
    required this.deletedCount,
    this.successMessage = 'Images deleted successfully',
  });

  /// العربية: يعتمد على الصور المتبقية وعدد المحذوفات ورسالة النجاح.
  /// English: Uses the remaining images, deletion count, and success message for equality.
  @override
  List<Object?> get props => [remainingImages, deletedCount, successMessage];
}

/// العربية: تمثل حالة تعديل صورة واحدة مع إبقاء لقطة المعرض الحالية.
/// English: Represents updating one image while keeping the current gallery snapshot.
class CityImageUpdating extends CityImagesState {
  /// العربية: لقطة المعرض قبل تطبيق التحديث.
  /// English: The gallery snapshot before the update is applied.
  final List<CityImage> currentImages;

  /// العربية: معرّف الصورة الجاري تحديثها.
  /// English: The identifier of the image currently being updated.
  final String imageId;

  /// العربية: ينشئ حالة تحديث الصورة.
  /// English: Creates the image-updating state.
  const CityImageUpdating({
    required this.currentImages,
    required this.imageId,
  });

  /// العربية: يعتمد على لقطة المعرض ومعرّف الصورة المحدثة.
  /// English: Uses the gallery snapshot and image id for equality.
  @override
  List<Object?> get props => [currentImages, imageId];
}

/// العربية: تمثل نجاح تعديل صورة داخل المعرض.
/// English: Represents a successful update of an image in the gallery.
class CityImageUpdated extends CityImagesState {
  /// العربية: لقطة المعرض بعد اكتمال التحديث.
  /// English: The gallery snapshot after the update completes.
  final List<CityImage> updatedImages;

  /// العربية: نص التأكيد الذي يظهر بعد التحديث.
  /// English: The confirmation text shown after the update.
  final String successMessage;

  /// العربية: ينشئ حالة نجاح التحديث.
  /// English: Creates the image-update success state.
  const CityImageUpdated({
    required this.updatedImages,
    this.successMessage = 'Image updated successfully',
  });

  /// العربية: يعتمد على الصور المحدثة ورسالة النجاح.
  /// English: Uses the updated images and success message for equality.
  @override
  List<Object?> get props => [updatedImages, successMessage];
}

/// العربية: تمثل حالة إعادة ترتيب الصور أثناء حفظ الترتيب الجديد.
/// English: Represents the reordering state while the new order is being saved.
class ImagesReordering extends CityImagesState {
  /// العربية: لقطة المعرض أثناء حفظ الترتيب الجديد.
  /// English: The gallery snapshot while the new order is being saved.
  final List<CityImage> currentImages;

  /// العربية: ينشئ حالة إعادة الترتيب.
  /// English: Creates the reordering state.
  const ImagesReordering({required this.currentImages});

  /// العربية: يعتمد على لقطة المعرض الحالية.
  /// English: Uses the current gallery snapshot for equality.
  @override
  List<Object?> get props => [currentImages];
}

/// العربية: تمثل نجاح إعادة ترتيب صور المعرض.
/// English: Represents a successful reorder of gallery images.
class ImagesReordered extends CityImagesState {
  /// العربية: لقطة المعرض بعد تأكيد إعادة الترتيب.
  /// English: The gallery snapshot after the reorder is confirmed.
  final List<CityImage> reorderedImages;

  /// العربية: نص التأكيد لعملية إعادة الترتيب.
  /// English: The confirmation text for the reorder action.
  final String successMessage;

  /// العربية: ينشئ حالة نجاح إعادة الترتيب.
  /// English: Creates the reorder-success state.
  const ImagesReordered({
    required this.reorderedImages,
    this.successMessage = 'Images reordered successfully',
  });

  /// العربية: يعتمد على الصور المعاد ترتيبها ورسالة النجاح.
  /// English: Uses the reordered images and success message for equality.
  @override
  List<Object?> get props => [reorderedImages, successMessage];
}

/// العربية: تمثل نجاح تعيين صورة أساسية أو غلاف جديد للمدينة.
/// English: Represents a successful change of the city's primary or cover image.
class PrimaryImageSet extends CityImagesState {
  /// العربية: لقطة المعرض بعد تغيير الصورة الأساسية.
  /// English: The gallery snapshot after the primary image has been changed.
  final List<CityImage> updatedImages;

  /// العربية: معرّف الصورة التي أصبحت أساسية.
  /// English: The identifier of the image promoted to primary.
  final String primaryImageId;

  /// العربية: نص التأكيد لتغيير الصورة الأساسية.
  /// English: The confirmation text for the primary-image change.
  final String successMessage;

  /// العربية: ينشئ حالة تعيين الصورة الأساسية.
  /// English: Creates the primary-image success state.
  const PrimaryImageSet({
    required this.updatedImages,
    required this.primaryImageId,
    this.successMessage = 'Primary image set successfully',
  });

  /// العربية: يعتمد على الصور المحدثة ومعرّف الصورة الأساسية ورسالة النجاح.
  /// English: Uses the updated images, primary image id, and success message for equality.
  @override
  List<Object?> get props => [updatedImages, primaryImageId, successMessage];
}
