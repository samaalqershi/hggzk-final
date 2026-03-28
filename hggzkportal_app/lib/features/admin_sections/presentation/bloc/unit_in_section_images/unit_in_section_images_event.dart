// lib/features/admin_sections/presentation/bloc/unit_in_section_images/unit_in_section_images_event.dart

import 'package:equatable/equatable.dart';

abstract class UnitInSectionImagesEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `UnitInSectionImagesEvent`.
  const UnitInSectionImagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `unitInSectionId`.
  final String? unitInSectionId;

  final String? tempKey;

  final int? page;

  final int? limit;

  const LoadUnitInSectionImagesEvent({
    this.unitInSectionId,
    this.tempKey,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [unitInSectionId, tempKey, page, limit];
}

class UploadUnitInSectionImageEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `unitInSectionId`.
  final String? unitInSectionId;

  final String? tempKey;

  final String filePath;

  final String? category;

  final String? alt;

  final bool isPrimary;

  final int? order;

  final List<String>? tags;

  const UploadUnitInSectionImageEvent({
    this.unitInSectionId,
    this.tempKey,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
  });

  @override
  List<Object?> get props => [
        unitInSectionId,
        tempKey,
        filePath,
        category,
        alt,
        isPrimary,
        order,
        tags
      ];
}

class UploadMultipleUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `unitInSectionId`.
  final String? unitInSectionId;

  final String? tempKey;

  final List<String> filePaths;

  final String? category;

  final List<String>? tags;

  const UploadMultipleUnitInSectionImagesEvent({
    this.unitInSectionId,
    this.tempKey,
    required this.filePaths,
    this.category,
    this.tags,
  });

  @override
  List<Object?> get props =>
      [unitInSectionId, tempKey, filePaths, category, tags];
}

class UpdateUnitInSectionImageEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `imageId`.
  final String imageId;

  final Map<String, dynamic> data;

  const UpdateUnitInSectionImageEvent({
    required this.imageId,
    required this.data,
  });

  @override
  List<Object?> get props => [imageId, data];
}

class DeleteUnitInSectionImageEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `imageId`.
  final String imageId;

  final bool permanent;

  const DeleteUnitInSectionImageEvent({
    required this.imageId,
    this.permanent = false,
  });

  @override
  List<Object?> get props => [imageId, permanent];
}

class DeleteMultipleUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `imageIds`.
  final List<String> imageIds;

  const DeleteMultipleUnitInSectionImagesEvent({required this.imageIds});

  @override
  List<Object?> get props => [imageIds];
}

class ReorderUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `unitInSectionId`.
  final String? unitInSectionId;

  final String? tempKey;

  final List<String> imageIds;

  const ReorderUnitInSectionImagesEvent({
    this.unitInSectionId,
    this.tempKey,
    required this.imageIds,
  });

  @override
  List<Object?> get props => [unitInSectionId, tempKey, imageIds];
}

class SetPrimaryUnitInSectionImageEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `unitInSectionId`.
  final String? unitInSectionId;

  final String? tempKey;

  final String imageId;

  const SetPrimaryUnitInSectionImageEvent({
    this.unitInSectionId,
    this.tempKey,
    required this.imageId,
  });

  @override
  List<Object?> get props => [unitInSectionId, tempKey, imageId];
}

class ClearUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `ClearUnitInSectionImagesEvent`.
  const ClearUnitInSectionImagesEvent();
}

class RefreshUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `unitInSectionId`.
  final String? unitInSectionId;

  final String? tempKey;

  const RefreshUnitInSectionImagesEvent({
    this.unitInSectionId,
    this.tempKey,
  });

  @override
  List<Object?> get props => [unitInSectionId, tempKey];
}

class ToggleSelectUnitInSectionImageEvent extends UnitInSectionImagesEvent {
  /// العربية: يخزن القيمة `imageId`.
  final String imageId;

  const ToggleSelectUnitInSectionImageEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class SelectAllUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `SelectAllUnitInSectionImagesEvent`.
  const SelectAllUnitInSectionImagesEvent();
}

class ClearUnitInSectionSelectionEvent extends UnitInSectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `ClearUnitInSectionSelectionEvent`.
  const ClearUnitInSectionSelectionEvent();
}

class DeselectAllUnitInSectionImagesEvent extends UnitInSectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `DeselectAllUnitInSectionImagesEvent`.
  const DeselectAllUnitInSectionImagesEvent();
}
