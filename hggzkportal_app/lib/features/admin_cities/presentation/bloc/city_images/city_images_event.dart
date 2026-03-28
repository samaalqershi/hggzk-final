import 'package:equatable/equatable.dart';

/// العربية: يعرّف كل أحداث التفاعل مع معرض صور المدينة، من التحميل إلى الرفع والحذف وإعادة الترتيب.
/// English: Defines every interaction event for the city image gallery, from loading to upload, deletion, and reordering.
abstract class CityImagesEvent extends Equatable {
  /// العربية: ينشئ الأساس المشترك لجميع أحداث المعرض.
  /// English: Creates the shared base for all gallery events.
  const CityImagesEvent();

  /// العربية: لا توجد حقول مشتركة هنا، لذا تعتمد المساواة على الفئات الفرعية.
  /// English: No shared fields exist here, so equality is controlled by subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب تحميل صور مدينة واحدة سواء كانت مدينة محفوظة أو ما زالت في وضع المسودة.
/// English: Requests the gallery for one city, whether it is already saved or still a draft.
class LoadCityImagesEvent extends CityImagesEvent {
  /// العربية: معرّف المدينة المحفوظ عندما يتبع المعرض سجلًا موجودًا.
  /// English: The saved city id when the gallery belongs to an existing record.
  final String? cityId;

  /// العربية: مفتاح المسودة المؤقت عندما لا تكون المدينة محفوظة بعد.
  /// English: The temporary draft key used before the city exists.
  final String? tempKey;

  /// العربية: ينشئ طلب تحميل المعرض وفق سياق المدينة أو المسودة.
  /// English: Creates the gallery-load request for either a saved city or a draft context.
  const LoadCityImagesEvent({this.cityId, this.tempKey});

  /// العربية: يعتمد على معرّف المدينة أو مفتاح المسودة لتحديد الطلب نفسه.
  /// English: Uses the city id or draft key to identify the same request.
  @override
  List<Object?> get props => [cityId, tempKey];
}

/// العربية: يرفع صورة واحدة إلى معرض المدينة مع بياناتها الاختيارية.
/// English: Uploads a single image into the city gallery with optional metadata.
class UploadCityImageEvent extends CityImagesEvent {
  /// العربية: معرّف المدينة المحفوظ أو سياق الأصل للرفع.
  /// English: The saved city id or parent context used for the upload.
  final String? cityId;

  /// العربية: مفتاح المسودة المؤقت عندما تكون المدينة غير محفوظة بعد.
  /// English: The temporary draft key used when the city has not been persisted yet.
  final String? tempKey;

  /// العربية: المسار المحلي للملف الذي اختاره المسؤول للرفع.
  /// English: The local file path selected by the admin for upload.
  final String filePath;

  /// العربية: الفئة الاختيارية التي تُربط بالصورة المرفوعة.
  /// English: The optional category attached to the uploaded image.
  final String? category;

  /// العربية: نص بديل أو وصف اختياري يرافق الصورة.
  /// English: Optional alt text or caption that accompanies the image.
  final String? alt;

  /// العربية: يحدد ما إذا كانت الصورة الجديدة يجب أن تصبح الغلاف الأساسي.
  /// English: Indicates whether the new image should become the primary cover image.
  final bool isPrimary;

  /// العربية: ترتيب الصورة المطلوب داخل المعرض.
  /// English: The desired order position inside the gallery.
  final int? order;

  /// العربية: الوسوم الاختيارية التي يجب أن ترافق الوسائط المرفوعة.
  /// English: Optional tags that should accompany the uploaded media.
  final List<String>? tags;

  /// العربية: يجمع كل المدخلات اللازمة لرفع صورة واحدة.
  /// English: Packages all inputs required for a single-image upload.
  const UploadCityImageEvent({
    this.cityId,
    this.tempKey,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
  });

  /// العربية: يعتمد على سياق المدينة والملف والخصائص الوصفية للصورة.
  /// English: Uses the city context, file path, and image metadata for equality.
  @override
  List<Object?> get props =>
      [cityId, tempKey, filePath, category, alt, isPrimary, order, tags];
}

/// العربية: يرفع عدة صور دفعة واحدة مع الحفاظ على ترتيب الملفات والوسوم المشتركة.
/// English: Uploads multiple images in one batch while preserving file order and shared tags.
class UploadMultipleCityImagesEvent extends CityImagesEvent {
  /// العربية: معرّف المدينة المحفوظ أو سياق المسودة للدفعة.
  /// English: The saved city id or draft context for the batch upload.
  final String? cityId;

  /// العربية: مفتاح المسودة المؤقت عند التعامل مع مدينة جديدة.
  /// English: The temporary draft key used when the batch belongs to a new city.
  final String? tempKey;

  /// العربية: الملفات المختارة بنفس ترتيب الرفع المطلوب.
  /// English: The files chosen in the exact order they should be uploaded.
  final List<String> filePaths;

  /// العربية: الفئة الاختيارية المشتركة لكل ملفات الدفعة.
  /// English: The optional category shared by the entire batch.
  final String? category;

  /// العربية: الوسوم الاختيارية المشتركة لكل ملفات الدفعة.
  /// English: The optional tags shared by the entire batch.
  final List<String>? tags;

  /// العربية: يجمع طلب الرفع الجماعي لطبقة الـ BLoC.
  /// English: Packages the batch-upload request for the BLoC layer.
  const UploadMultipleCityImagesEvent({
    this.cityId,
    this.tempKey,
    required this.filePaths,
    this.category,
    this.tags,
  });

  /// العربية: يعتمد على سياق المدينة وقائمة الملفات والوسوم المشتركة.
  /// English: Uses the city context, file list, and shared tags for equality.
  @override
  List<Object?> get props => [cityId, tempKey, filePaths, category, tags];
}

/// العربية: يحدّث بيانات وصفية لصورة موجودة دون إعادة رفعها.
/// English: Updates metadata for an existing image without re-uploading it.
class UpdateCityImageEvent extends CityImagesEvent {
  /// العربية: معرّف الصورة التي سيتم تعديلها.
  /// English: The identifier of the image to patch.
  final String imageId;

  /// العربية: الحمولة الجزئية التي تحتوي الحقول المعدلة.
  /// English: The partial payload containing the edited fields.
  final Map<String, dynamic> data;

  /// العربية: يطلب تحديث بيانات وصفية لعنصر واحد في المعرض.
  /// English: Requests a metadata update for one gallery item.
  const UpdateCityImageEvent({
    required this.imageId,
    required this.data,
  });

  /// العربية: يعتمد على معرّف الصورة والحقول المعدلة.
  /// English: Uses the image id and edited payload for equality.
  @override
  List<Object?> get props => [imageId, data];
}

/// العربية: يحذف صورة واحدة من معرض المدينة.
/// English: Deletes a single image from the city gallery.
class DeleteCityImageEvent extends CityImagesEvent {
  /// العربية: معرّف الصورة المطلوب حذفها.
  /// English: The identifier of the image to delete.
  final String imageId;

  /// العربية: ينشئ أمر حذف لعنصر واحد في المعرض.
  /// English: Creates a delete command for one gallery item.
  const DeleteCityImageEvent({required this.imageId});

  /// العربية: يعتمد على معرّف الصورة فقط.
  /// English: Uses the image id only for equality.
  @override
  List<Object?> get props => [imageId];
}

/// العربية: يحذف عدة صور من المعرض في عملية واحدة.
/// English: Deletes multiple images from the gallery in one operation.
class DeleteMultipleCityImagesEvent extends CityImagesEvent {
  /// العربية: معرّفات العناصر المحددة للحذف.
  /// English: The identifiers of the gallery items selected for deletion.
  final List<String> imageIds;

  /// العربية: يطلب عملية حذف جماعي للصور المحددة.
  /// English: Requests a bulk delete operation for the selected images.
  const DeleteMultipleCityImagesEvent({required this.imageIds});

  /// العربية: يعتمد على قائمة معرّفات الصور المطلوب حذفها.
  /// English: Uses the selected image id list for equality.
  @override
  List<Object?> get props => [imageIds];
}

/// العربية: يعيد ترتيب صور المعرض وفق الترتيب الجديد الذي اختاره المستخدم.
/// English: Reorders gallery images according to the new order chosen by the admin user.
class ReorderCityImagesEvent extends CityImagesEvent {
  /// العربية: معرّف المدينة المحفوظ أو مفتاح المسودة لجهة إعادة الترتيب.
  /// English: The saved city id or draft key that owns the reorder target.
  final String? cityId;

  /// العربية: مفتاح المسودة المؤقت قبل حفظ المدينة.
  /// English: The temporary draft key used before the city is persisted.
  final String? tempKey;

  /// العربية: الترتيب الجديد للصور كما اختاره المسؤول.
  /// English: The new gallery order chosen by the admin user.
  final List<String> imageIds;

  /// العربية: يرسل الترتيب المطلوب إلى طبقة الـ BLoC.
  /// English: Sends the desired order back to the BLoC.
  const ReorderCityImagesEvent({
    this.cityId,
    this.tempKey,
    required this.imageIds,
  });

  /// العربية: يعتمد على سياق المدينة وقائمة الترتيب الجديدة.
  /// English: Uses the city context and the new order list for equality.
  @override
  List<Object?> get props => [cityId, tempKey, imageIds];
}

/// العربية: يحدد صورة واحدة لتصبح الصورة الأساسية أو غلاف المدينة.
/// English: Sets one image as the primary cover image for the city.
class SetPrimaryCityImageEvent extends CityImagesEvent {
  /// العربية: معرّف المدينة المحفوظ أو سياق المسودة لعملية الصورة الأساسية.
  /// English: The saved city id or draft context used for the primary-image action.
  final String? cityId;

  /// العربية: مفتاح المسودة المؤقت أثناء تعديل مدينة جديدة.
  /// English: The temporary draft key used while editing a new city.
  final String? tempKey;

  /// العربية: معرّف الصورة التي يجب أن تصبح الغلاف الجديد.
  /// English: The identifier of the image that should become the new cover.
  final String imageId;

  /// العربية: يبدّل علم الصورة الأساسية للعنصر المحدد.
  /// English: Switches the primary flag for the selected gallery item.
  const SetPrimaryCityImageEvent({
    this.cityId,
    this.tempKey,
    required this.imageId,
  });

  /// العربية: يعتمد على سياق المدينة ومعرّف الصورة المستهدفة.
  /// English: Uses the city context and target image id for equality.
  @override
  List<Object?> get props => [cityId, tempKey, imageId];
}

/// العربية: يمسح حالة المعرض والاختيار عند مغادرة الشاشة أو تبديل المدينة.
/// English: Clears gallery and selection state when leaving the screen or switching city context.
class ClearCityImagesEvent extends CityImagesEvent {
  /// العربية: يعيد ضبط حالة المعرض من دون مدخلات إضافية.
  /// English: Resets the gallery state with no additional inputs.
  const ClearCityImagesEvent();
}

/// العربية: يطلب إعادة تحميل صور المدينة من دون إظهار شاشة تحميل كاملة.
/// English: Requests a silent reload of the city gallery without forcing a full loading screen.
class RefreshCityImagesEvent extends CityImagesEvent {
  /// العربية: معرّف المدينة المحفوظ أو مفتاح المسودة لإعادة التحميل الصامت.
  /// English: The saved city id or draft key used for the silent refresh.
  final String? cityId;

  /// العربية: مفتاح المسودة المؤقت عندما لا يكون المعرض مرتبطًا بمدينة بعد.
  /// English: The temporary draft key used when the gallery is not yet attached to a city.
  final String? tempKey;

  /// العربية: يحدّث المعرض من دون إظهار شاشة التحميل.
  /// English: Refreshes the gallery without forcing the loading placeholder.
  const RefreshCityImagesEvent({this.cityId, this.tempKey});

  /// العربية: يعتمد على سياق المدينة أو مفتاح المسودة لإعادة التحميل.
  /// English: Uses the city context or draft key for the silent refresh.
  @override
  List<Object?> get props => [cityId, tempKey];
}

/// العربية: يبدّل حالة تحديد صورة واحدة داخل المعرض.
/// English: Toggles the selected state for one image in the gallery.
class ToggleCityImageSelectionEvent extends CityImagesEvent {
  /// العربية: معرّف الصورة التي يجب تبديل حالتها المختارة.
  /// English: The identifier of the image whose selected state should flip.
  final String imageId;

  /// العربية: يبدّل حالة الاختيار لعنصر واحد في المعرض.
  /// English: Flips the selected state for one gallery item.
  const ToggleCityImageSelectionEvent({required this.imageId});

  /// العربية: يعتمد على معرّف الصورة فقط.
  /// English: Uses the image id only for equality.
  @override
  List<Object?> get props => [imageId];
}

/// العربية: يحدد كل الصور الظاهرة لتمكين عمليات الدفعة.
/// English: Selects every visible image so batch actions can be applied.
class SelectAllCityImagesEvent extends CityImagesEvent {
  /// العربية: يحدد كل صورة ظاهرة كمحددة لعمليات الدفعة.
  /// English: Marks every visible image as selected for batch actions.
  const SelectAllCityImagesEvent();
}

/// العربية: يزيل جميع الصور من حالة الاختيار الحالية.
/// English: Clears every image from the current gallery selection.
class DeselectAllCityImagesEvent extends CityImagesEvent {
  /// العربية: يمسح حالة الاختيار الحالية للمعرض.
  /// English: Clears the current gallery selection state.
  const DeselectAllCityImagesEvent();
}
