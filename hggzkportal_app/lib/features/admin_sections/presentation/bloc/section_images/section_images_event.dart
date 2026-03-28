// lib/features/admin_sections/presentation/bloc/section_images/section_images_event.dart

import 'package:equatable/equatable.dart';

abstract class SectionImagesEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `SectionImagesEvent`.
  const SectionImagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSectionImagesEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `sectionId`.
  final String? sectionId;

  final String? tempKey;

  const LoadSectionImagesEvent({this.sectionId, this.tempKey});

  @override
  List<Object?> get props => [sectionId, tempKey];
}

class UploadSectionImageEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `sectionId`.
  final String? sectionId;

  final String? tempKey;

  final String filePath;

  final String? category;

  final String? alt;

  final bool isPrimary;

  final int? order;

  final List<String>? tags;

  const UploadSectionImageEvent({
    this.sectionId,
    this.tempKey,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
  });

  @override
  List<Object?> get props =>
      [sectionId, tempKey, filePath, category, alt, isPrimary, order, tags];
}

class UploadMultipleSectionImagesEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `sectionId`.
  final String? sectionId;

  final String? tempKey;

  final List<String> filePaths;

  final String? category;

  final List<String>? tags;

  const UploadMultipleSectionImagesEvent({
    this.sectionId,
    this.tempKey,
    required this.filePaths,
    this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [sectionId, tempKey, filePaths, category, tags];
}

class UpdateSectionImageEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `imageId`.
  final String imageId;

  final Map<String, dynamic> data;

  const UpdateSectionImageEvent({
    required this.imageId,
    required this.data,
  });

  @override
  List<Object?> get props => [imageId, data];
}

class DeleteSectionImageEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `imageId`.
  final String imageId;

  const DeleteSectionImageEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class DeleteMultipleSectionImagesEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `imageIds`.
  final List<String> imageIds;

  const DeleteMultipleSectionImagesEvent({required this.imageIds});

  @override
  List<Object?> get props => [imageIds];
}

class ReorderSectionImagesEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `sectionId`.
  final String? sectionId;

  final String? tempKey;

  final List<String> imageIds;

  const ReorderSectionImagesEvent({
    this.sectionId,
    this.tempKey,
    required this.imageIds,
  });

  @override
  List<Object?> get props => [sectionId, tempKey, imageIds];
}

class SetPrimarySectionImageEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `sectionId`.
  final String? sectionId;

  final String? tempKey;

  final String imageId;

  const SetPrimarySectionImageEvent({
    this.sectionId,
    this.tempKey,
    required this.imageId,
  });

  @override
  List<Object?> get props => [sectionId, tempKey, imageId];
}

class ClearSectionImagesEvent extends SectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `ClearSectionImagesEvent`.
  const ClearSectionImagesEvent();
}

class RefreshSectionImagesEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `sectionId`.
  final String? sectionId;

  final String? tempKey;

  const RefreshSectionImagesEvent({this.sectionId, this.tempKey});

  @override
  List<Object?> get props => [sectionId, tempKey];
}

class ToggleSelectSectionImageEvent extends SectionImagesEvent {
  /// العربية: يخزن القيمة `imageId`.
  final String imageId;

  const ToggleSelectSectionImageEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class SelectAllSectionImagesEvent extends SectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `SelectAllSectionImagesEvent`.
  const SelectAllSectionImagesEvent();
}

class DeselectAllSectionImagesEvent extends SectionImagesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `DeselectAllSectionImagesEvent`.
  const DeselectAllSectionImagesEvent();
}
