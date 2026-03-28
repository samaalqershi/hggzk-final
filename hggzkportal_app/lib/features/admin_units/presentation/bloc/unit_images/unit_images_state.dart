// lib/features/admin_units/presentation/bloc/unit_images/unit_images_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/unit_image.dart';

/// يمثل هذا الكلاس المجرد UnitImagesState العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitImagesState in the admin unit workflow.
abstract class UnitImagesState extends Equatable {
  /// This constructor creates a new UnitImagesState instance.
  /// ينشئ مثيلًا جديدًا من UnitImagesState.
  const UnitImagesState();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس UnitImagesInitial البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImagesInitial in the admin unit workflow.
class UnitImagesInitial extends UnitImagesState {
  /// This constructor creates a new UnitImagesInitial instance.
  /// ينشئ مثيلًا جديدًا من UnitImagesInitial.
  const UnitImagesInitial();
}

/// يمثل هذا الكلاس UnitImagesLoading البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImagesLoading in the admin unit workflow.
class UnitImagesLoading extends UnitImagesState {
  /// This field keeps the message value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة message التي يعتمد عليها مسار إدارة الوحدات.
  final String? message;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImagesLoading.
  /// This constructor creates an instance of UnitImagesLoading.
  const UnitImagesLoading({this.message});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [message];
}

/// يمثل هذا الكلاس UnitImagesLoaded البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImagesLoaded in the admin unit workflow.
class UnitImagesLoaded extends UnitImagesState {
  /// This field keeps the images value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة images التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> images;

  /// يحتفظ هذا الحقل بقيمة selectedImageIds التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the selectedImageIds value used by the admin unit workflow.
  final Set<String> selectedImageIds;

  /// يحتفظ هذا الحقل بقيمة currentUnitId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the currentUnitId value used by the admin unit workflow.
  final String? currentUnitId;

  /// يحتفظ هذا الحقل بقيمة isSelectionMode التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isSelectionMode value used by the admin unit workflow.
  final bool isSelectionMode;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImagesLoaded.
  /// This constructor creates an instance of UnitImagesLoaded.
  const UnitImagesLoaded({
    required this.images,
    this.selectedImageIds = const {},
    this.currentUnitId,
    this.isSelectionMode = false,
  });

  /// ينفذ هذا الأسلوب عملية copyWith ضمن مسار إدارة الوحدات.
  /// This method performs the copyWith operation in the admin unit workflow.
  UnitImagesLoaded copyWith({
    List<UnitImage>? images,
    Set<String>? selectedImageIds,
    String? currentUnitId,
    bool? isSelectionMode,
  }) {
    return UnitImagesLoaded(
      images: images ?? this.images,
      selectedImageIds: selectedImageIds ?? this.selectedImageIds,
      currentUnitId: currentUnitId ?? this.currentUnitId,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props =>
      [images, selectedImageIds, currentUnitId, isSelectionMode];
}

/// يمثل هذا الكلاس UnitImagesError البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImagesError in the admin unit workflow.
class UnitImagesError extends UnitImagesState {
  /// This field keeps the message value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة message التي يعتمد عليها مسار إدارة الوحدات.
  final String message;

  /// يحتفظ هذا الحقل بقيمة previousImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the previousImages value used by the admin unit workflow.
  final List<UnitImage>? previousImages;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImagesError.
  /// This constructor creates an instance of UnitImagesError.
  const UnitImagesError({
    required this.message,
    this.previousImages,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [message, previousImages];
}

/// يمثل هذا الكلاس UnitImageUploading البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageUploading in the admin unit workflow.
class UnitImageUploading extends UnitImagesState {
  /// This field keeps the currentImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة currentImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> currentImages;

  /// يحتفظ هذا الحقل بقيمة uploadProgress التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the uploadProgress value used by the admin unit workflow.
  final double? uploadProgress;

  /// يحتفظ هذا الحقل بقيمة uploadingFileName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the uploadingFileName value used by the admin unit workflow.
  final String? uploadingFileName;

  /// يحتفظ هذا الحقل بقيمة currentFileIndex التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the currentFileIndex value used by the admin unit workflow.
  final int? currentFileIndex;

  /// يحتفظ هذا الحقل بقيمة totalFiles التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the totalFiles value used by the admin unit workflow.
  final int? totalFiles;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageUploading.
  /// This constructor creates an instance of UnitImageUploading.
  const UnitImageUploading({
    required this.currentImages,
    this.uploadProgress,
    this.uploadingFileName,
    this.currentFileIndex,
    this.totalFiles,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        currentImages,
        uploadProgress,
        uploadingFileName,
        currentFileIndex,
        totalFiles,
      ];
}

/// يمثل هذا الكلاس UnitImageUploaded البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageUploaded in the admin unit workflow.
class UnitImageUploaded extends UnitImagesState {
  /// This field keeps the uploadedImage value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة uploadedImage التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImage uploadedImage;

  /// يحتفظ هذا الحقل بقيمة allImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the allImages value used by the admin unit workflow.
  final List<UnitImage> allImages;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageUploaded.
  /// This constructor creates an instance of UnitImageUploaded.
  const UnitImageUploaded({
    required this.uploadedImage,
    required this.allImages,
    this.successMessage = 'Image uploaded successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [uploadedImage, allImages, successMessage];
}

/// يمثل هذا الكلاس MultipleImagesUploaded البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for MultipleImagesUploaded in the admin unit workflow.
class MultipleImagesUploaded extends UnitImagesState {
  /// This field keeps the uploadedImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة uploadedImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> uploadedImages;

  /// يحتفظ هذا الحقل بقيمة allImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the allImages value used by the admin unit workflow.
  final List<UnitImage> allImages;

  /// يحتفظ هذا الحقل بقيمة successCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successCount value used by the admin unit workflow.
  final int successCount;

  /// يحتفظ هذا الحقل بقيمة failedCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the failedCount value used by the admin unit workflow.
  final int failedCount;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من MultipleImagesUploaded.
  /// This constructor creates an instance of MultipleImagesUploaded.
  const MultipleImagesUploaded({
    required this.uploadedImages,
    required this.allImages,
    required this.successCount,
    this.failedCount = 0,
    this.successMessage = 'Images uploaded successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        uploadedImages,
        allImages,
        successCount,
        failedCount,
        successMessage,
      ];
}

/// يمثل هذا الكلاس UnitImageDeleting البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageDeleting in the admin unit workflow.
class UnitImageDeleting extends UnitImagesState {
  /// This field keeps the currentImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة currentImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> currentImages;

  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the imageId value used by the admin unit workflow.
  final String imageId;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageDeleting.
  /// This constructor creates an instance of UnitImageDeleting.
  const UnitImageDeleting({
    required this.currentImages,
    required this.imageId,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [currentImages, imageId];
}

/// يمثل هذا الكلاس UnitImageDeleted البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageDeleted in the admin unit workflow.
class UnitImageDeleted extends UnitImagesState {
  /// This field keeps the remainingImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة remainingImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> remainingImages;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageDeleted.
  /// This constructor creates an instance of UnitImageDeleted.
  const UnitImageDeleted({
    required this.remainingImages,
    this.successMessage = 'Image deleted successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [remainingImages, successMessage];
}

/// يمثل هذا الكلاس MultipleImagesDeleted البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for MultipleImagesDeleted in the admin unit workflow.
class MultipleImagesDeleted extends UnitImagesState {
  /// This field keeps the remainingImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة remainingImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> remainingImages;

  /// يحتفظ هذا الحقل بقيمة deletedCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the deletedCount value used by the admin unit workflow.
  final int deletedCount;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من MultipleImagesDeleted.
  /// This constructor creates an instance of MultipleImagesDeleted.
  const MultipleImagesDeleted({
    required this.remainingImages,
    required this.deletedCount,
    this.successMessage = 'Images deleted successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [remainingImages, deletedCount, successMessage];
}

/// يمثل هذا الكلاس UnitImageUpdating البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageUpdating in the admin unit workflow.
class UnitImageUpdating extends UnitImagesState {
  /// This field keeps the currentImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة currentImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> currentImages;

  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the imageId value used by the admin unit workflow.
  final String imageId;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageUpdating.
  /// This constructor creates an instance of UnitImageUpdating.
  const UnitImageUpdating({
    required this.currentImages,
    required this.imageId,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [currentImages, imageId];
}

/// يمثل هذا الكلاس UnitImageUpdated البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageUpdated in the admin unit workflow.
class UnitImageUpdated extends UnitImagesState {
  /// This field keeps the updatedImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة updatedImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> updatedImages;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageUpdated.
  /// This constructor creates an instance of UnitImageUpdated.
  const UnitImageUpdated({
    required this.updatedImages,
    this.successMessage = 'Image updated successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [updatedImages, successMessage];
}

/// يمثل هذا الكلاس ImagesReordering البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ImagesReordering in the admin unit workflow.
class ImagesReordering extends UnitImagesState {
  /// This field keeps the currentImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة currentImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> currentImages;

  /// ينشئ هذا المُنشئ مثيلاً من ImagesReordering.
  /// This constructor creates an instance of ImagesReordering.
  const ImagesReordering({required this.currentImages});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [currentImages];
}

/// يمثل هذا الكلاس ImagesReordered البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ImagesReordered in the admin unit workflow.
class ImagesReordered extends UnitImagesState {
  /// This field keeps the reorderedImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة reorderedImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> reorderedImages;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من ImagesReordered.
  /// This constructor creates an instance of ImagesReordered.
  const ImagesReordered({
    required this.reorderedImages,
    this.successMessage = 'Images reordered successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [reorderedImages, successMessage];
}

/// يمثل هذا الكلاس PrimaryImageSet البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for PrimaryImageSet in the admin unit workflow.
class PrimaryImageSet extends UnitImagesState {
  /// This field keeps the updatedImages value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة updatedImages التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitImage> updatedImages;

  /// يحتفظ هذا الحقل بقيمة primaryImageId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the primaryImageId value used by the admin unit workflow.
  final String primaryImageId;

  /// يحتفظ هذا الحقل بقيمة successMessage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the successMessage value used by the admin unit workflow.
  final String successMessage;

  /// ينشئ هذا المُنشئ مثيلاً من PrimaryImageSet.
  /// This constructor creates an instance of PrimaryImageSet.
  const PrimaryImageSet({
    required this.updatedImages,
    required this.primaryImageId,
    this.successMessage = 'Primary image set successfully',
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [updatedImages, primaryImageId, successMessage];
}
