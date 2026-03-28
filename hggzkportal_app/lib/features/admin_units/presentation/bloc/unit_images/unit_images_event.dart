// lib/features/admin_units/presentation/bloc/unit_images/unit_images_event.dart

import 'package:equatable/equatable.dart';

/// يمثل هذا الكلاس المجرد UnitImagesEvent العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitImagesEvent in the admin unit workflow.
abstract class UnitImagesEvent extends Equatable {
  /// This constructor creates a new UnitImagesEvent instance.
  /// ينشئ مثيلًا جديدًا من UnitImagesEvent.
  const UnitImagesEvent();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس LoadUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for LoadUnitImagesEvent in the admin unit workflow.
class LoadUnitImagesEvent extends UnitImagesEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// ينشئ هذا المُنشئ مثيلاً من LoadUnitImagesEvent.
  /// This constructor creates an instance of LoadUnitImagesEvent.
  const LoadUnitImagesEvent({this.unitId, this.tempKey});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, tempKey];
}

/// يمثل هذا الكلاس UploadUnitImageEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UploadUnitImageEvent in the admin unit workflow.
class UploadUnitImageEvent extends UnitImagesEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة filePath التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the filePath value used by the admin unit workflow.
  final String filePath;

  /// يحتفظ هذا الحقل بقيمة category التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the category value used by the admin unit workflow.
  final String? category;

  /// يحتفظ هذا الحقل بقيمة alt التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the alt value used by the admin unit workflow.
  final String? alt;

  /// يحتفظ هذا الحقل بقيمة isPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimary value used by the admin unit workflow.
  final bool isPrimary;

  /// يحتفظ هذا الحقل بقيمة order التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the order value used by the admin unit workflow.
  final int? order;

  /// يحتفظ هذا الحقل بقيمة tags التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tags value used by the admin unit workflow.
  final List<String>? tags;

  /// ينشئ هذا المُنشئ مثيلاً من UploadUnitImageEvent.
  /// This constructor creates an instance of UploadUnitImageEvent.
  const UploadUnitImageEvent({
    this.unitId,
    this.tempKey,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props =>
      [unitId, tempKey, filePath, category, alt, isPrimary, order, tags];
}

/// يمثل هذا الكلاس UploadMultipleUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UploadMultipleUnitImagesEvent in the admin unit workflow.
class UploadMultipleUnitImagesEvent extends UnitImagesEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة filePaths التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the filePaths value used by the admin unit workflow.
  final List<String> filePaths;

  /// يحتفظ هذا الحقل بقيمة category التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the category value used by the admin unit workflow.
  final String? category;

  /// يحتفظ هذا الحقل بقيمة tags التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tags value used by the admin unit workflow.
  final List<String>? tags;

  /// ينشئ هذا المُنشئ مثيلاً من UploadMultipleUnitImagesEvent.
  /// This constructor creates an instance of UploadMultipleUnitImagesEvent.
  const UploadMultipleUnitImagesEvent({
    this.unitId,
    this.tempKey,
    required this.filePaths,
    this.category,
    this.tags,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, tempKey, filePaths, category, tags];
}

/// يمثل هذا الكلاس UpdateUnitImageEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateUnitImageEvent in the admin unit workflow.
class UpdateUnitImageEvent extends UnitImagesEvent {
  /// This field keeps the imageId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  final String imageId;

  /// يحتفظ هذا الحقل بقيمة data التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the data value used by the admin unit workflow.
  final Map<String, dynamic> data;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateUnitImageEvent.
  /// This constructor creates an instance of UpdateUnitImageEvent.
  const UpdateUnitImageEvent({
    required this.imageId,
    required this.data,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [imageId, data];
}

/// يمثل هذا الكلاس DeleteUnitImageEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeleteUnitImageEvent in the admin unit workflow.
class DeleteUnitImageEvent extends UnitImagesEvent {
  /// This field keeps the imageId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  final String imageId;

  /// ينشئ هذا المُنشئ مثيلاً من DeleteUnitImageEvent.
  /// This constructor creates an instance of DeleteUnitImageEvent.
  const DeleteUnitImageEvent({required this.imageId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [imageId];
}

/// يمثل هذا الكلاس DeleteMultipleUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeleteMultipleUnitImagesEvent in the admin unit workflow.
class DeleteMultipleUnitImagesEvent extends UnitImagesEvent {
  /// This field keeps the imageIds value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة imageIds التي يعتمد عليها مسار إدارة الوحدات.
  final List<String> imageIds;

  /// ينشئ هذا المُنشئ مثيلاً من DeleteMultipleUnitImagesEvent.
  /// This constructor creates an instance of DeleteMultipleUnitImagesEvent.
  const DeleteMultipleUnitImagesEvent({required this.imageIds});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [imageIds];
}

/// يمثل هذا الكلاس ReorderUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ReorderUnitImagesEvent in the admin unit workflow.
class ReorderUnitImagesEvent extends UnitImagesEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة imageIds التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the imageIds value used by the admin unit workflow.
  final List<String> imageIds;

  /// ينشئ هذا المُنشئ مثيلاً من ReorderUnitImagesEvent.
  /// This constructor creates an instance of ReorderUnitImagesEvent.
  const ReorderUnitImagesEvent({
    this.unitId,
    this.tempKey,
    required this.imageIds,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, tempKey, imageIds];
}

/// يمثل هذا الكلاس SetPrimaryUnitImageEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SetPrimaryUnitImageEvent in the admin unit workflow.
class SetPrimaryUnitImageEvent extends UnitImagesEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the imageId value used by the admin unit workflow.
  final String imageId;

  /// ينشئ هذا المُنشئ مثيلاً من SetPrimaryUnitImageEvent.
  /// This constructor creates an instance of SetPrimaryUnitImageEvent.
  const SetPrimaryUnitImageEvent({
    this.unitId,
    this.tempKey,
    required this.imageId,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, tempKey, imageId];
}

/// يمثل هذا الكلاس ClearUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ClearUnitImagesEvent in the admin unit workflow.
class ClearUnitImagesEvent extends UnitImagesEvent {
  /// This constructor creates a new ClearUnitImagesEvent instance.
  /// ينشئ مثيلًا جديدًا من ClearUnitImagesEvent.
  const ClearUnitImagesEvent();
}

/// يمثل هذا الكلاس RefreshUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for RefreshUnitImagesEvent in the admin unit workflow.
class RefreshUnitImagesEvent extends UnitImagesEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// ينشئ هذا المُنشئ مثيلاً من RefreshUnitImagesEvent.
  /// This constructor creates an instance of RefreshUnitImagesEvent.
  const RefreshUnitImagesEvent({this.unitId, this.tempKey});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, tempKey];
}

/// يمثل هذا الكلاس ToggleUnitImageSelectionEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ToggleUnitImageSelectionEvent in the admin unit workflow.
class ToggleUnitImageSelectionEvent extends UnitImagesEvent {
  /// This field keeps the imageId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة imageId التي يعتمد عليها مسار إدارة الوحدات.
  final String imageId;

  /// ينشئ هذا المُنشئ مثيلاً من ToggleUnitImageSelectionEvent.
  /// This constructor creates an instance of ToggleUnitImageSelectionEvent.
  const ToggleUnitImageSelectionEvent({required this.imageId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [imageId];
}

/// يمثل هذا الكلاس SelectAllUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SelectAllUnitImagesEvent in the admin unit workflow.
class SelectAllUnitImagesEvent extends UnitImagesEvent {
  /// This constructor creates a new SelectAllUnitImagesEvent instance.
  /// ينشئ مثيلًا جديدًا من SelectAllUnitImagesEvent.
  const SelectAllUnitImagesEvent();
}

/// يمثل هذا الكلاس DeselectAllUnitImagesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeselectAllUnitImagesEvent in the admin unit workflow.
class DeselectAllUnitImagesEvent extends UnitImagesEvent {
  /// This constructor creates a new DeselectAllUnitImagesEvent instance.
  /// ينشئ مثيلًا جديدًا من DeselectAllUnitImagesEvent.
  const DeselectAllUnitImagesEvent();
}
