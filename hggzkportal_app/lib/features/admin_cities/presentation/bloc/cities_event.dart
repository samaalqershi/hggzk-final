import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';

/// Base event for every user or system action that affects the city catalog.
///
/// الحد الأساسي لكل حدث مستخدم أو نظام يؤثر في دليل المدن.
abstract class CitiesEvent extends Equatable {
  /// Establishes the shared equality boundary for city events.
  ///
  /// يحدد حد المساواة المشترك لأحداث المدن.
  const CitiesEvent();

  /// Keeps the base event stateless so subclasses define meaningful equality.
  ///
  /// يبقي الحدث الأساسي بلا بيانات حتى تحدد الفئات الفرعية مساواةً ذات معنى.
  @override
  List<Object?> get props => [];
}

/// Requests the current city list with the selected filters and paging rules.
///
/// يطلب قائمة المدن الحالية مع عوامل التصفية والترقيم المختارة.
class LoadCitiesEvent extends CitiesEvent {
  /// Page number requested by the admin table.
  ///
  /// رقم الصفحة المطلوب لجدول الإدارة.
  final int? page;

  /// Maximum number of items to load per page.
  ///
  /// الحد الأقصى لعدد العناصر في كل صفحة.
  final int? limit;

  /// Free-text query that narrows the list by city name or country.
  ///
  /// نص البحث الحر الذي يضيّق القائمة بحسب اسم المدينة أو الدولة.
  final String? search;

  /// Country filter applied before the data reaches the UI.
  ///
  /// فلتر الدولة المطبق قبل وصول البيانات إلى الواجهة.
  final String? country;

  /// Optional active-state filter used by moderation and publishing flows.
  ///
  /// فلتر الحالة النشطة الاختياري لمسارات المراجعة والنشر.
  final bool? isActive;

  /// Bundles the grid query settings for the city catalog.
  ///
  /// يجمع إعدادات استعلام الشبكة الخاصة بدليل المدن.
  const LoadCitiesEvent({
    this.page,
    this.limit,
    this.search,
    this.country,
    this.isActive,
  });

  /// Uses paging and filter inputs to differentiate one load request from another.
  ///
  /// يعتمد على الترقيم والفلاتر لتمييز طلب تحميل عن آخر.
  @override
  List<Object?> get props => [page, limit, search, country, isActive];
}

/// Persists a full batch of city records after bulk editing.
///
/// يحفظ دفعة كاملة من سجلات المدن بعد التعديل الجماعي.
class SaveCitiesEvent extends CitiesEvent {
  /// City snapshot to be written back to the repository.
  ///
  /// لقطة المدن المطلوب إعادة حفظها في المستودع.
  final List<City> cities;

  /// Creates the bulk-save command for the current city snapshot.
  ///
  /// ينشئ أمر الحفظ الجماعي للّقطة الحالية من المدن.
  const SaveCitiesEvent({required this.cities});

  /// Uses the city collection so bulk-save requests compare by payload.
  ///
  /// يعتمد على مجموعة المدن حتى تتم مقارنة طلبات الحفظ الجماعي حسب الحمولة.
  @override
  List<Object?> get props => [cities];
}

/// Creates one new city entry from the form payload.
///
/// ينشئ مدينة جديدة من بيانات النموذج.
class CreateCityEvent extends CitiesEvent {
  /// City payload collected from the creation form.
  ///
  /// بيانات المدينة المجمعة من نموذج الإنشاء.
  final City city;

  /// Opens the create flow with a single immutable city payload.
  ///
  /// يفتح مسار الإنشاء بحمولة مدينة ثابتة واحدة.
  const CreateCityEvent({required this.city});

  /// Uses the city payload so create commands compare by content.
  ///
  /// يعتمد على حمولة المدينة حتى تقارن أوامر الإنشاء بحسب المحتوى.
  @override
  List<Object?> get props => [city];
}

/// Replaces an existing city record while keeping the old identifier explicit.
///
/// يستبدل سجل مدينة موجودًا مع إبقاء المعرف القديم واضحًا.
class UpdateCityEvent extends CitiesEvent {
  /// Previous city name used to locate the row before replacement.
  ///
  /// اسم المدينة السابق المستخدم للوصول إلى السطر قبل الاستبدال.
  final String oldName;

  /// Updated city payload that should be saved in its place.
  ///
  /// بيانات المدينة المحدثة التي يجب حفظها مكانه.
  final City city;

  /// Combines the lookup key and the replacement payload.
  ///
  /// يجمع مفتاح البحث والحمولة البديلة في حدث واحد.
  const UpdateCityEvent({required this.oldName, required this.city});
  @override
  List<Object?> get props => [oldName, city];
}

/// Removes a city from the administration list.
///
/// يحذف مدينة من قائمة الإدارة.
class DeleteCityEvent extends CitiesEvent {
  /// City name used to target the deletion request.
  ///
  /// اسم المدينة المستخدم لتوجيه طلب الحذف.
  final String name;

  /// Creates a delete command for the selected city.
  ///
  /// ينشئ أمر حذف للمدينة المحددة.
  const DeleteCityEvent({required this.name});
  @override
  List<Object?> get props => [name];
}

/// Applies a text search to the in-memory or remote city list.
///
/// يطبّق بحثًا نصيًا على قائمة المدن في الذاكرة أو على الخادم.
class SearchCitiesEvent extends CitiesEvent {
  /// Free-text query entered by the admin user.
  ///
  /// نص البحث الذي أدخله مستخدم الإدارة.
  final String query;

  /// Requests a search refresh using the provided text.
  ///
  /// يطلب تحديث البحث باستخدام النص المعطى.
  const SearchCitiesEvent({required this.query});
  @override
  List<Object?> get props => [query];
}

/// Triggers a refresh of the dashboard statistics for cities.
///
/// يطلق تحديث إحصائيات لوحة المدن.
class LoadCitiesStatisticsEvent extends CitiesEvent {}

/// Uploads a media file that should belong to a city profile.
///
/// يرفع ملف وسائط يجب أن يرتبط بملف المدينة.
class UploadCityImageEvent extends CitiesEvent {
  /// Target city name that receives the uploaded image.
  ///
  /// اسم المدينة المستهدفة التي تستقبل الصورة المرفوعة.
  final String cityName;

  /// Local file path selected from the device.
  ///
  /// مسار الملف المحلي المختار من الجهاز.
  final String imagePath;

  /// Builds the upload request for one city image.
  ///
  /// ينشئ طلب الرفع لصورة مدينة واحدة.
  const UploadCityImageEvent({required this.cityName, required this.imagePath});
  @override
  List<Object?> get props => [cityName, imagePath];
}

/// Removes one image from a city gallery.
///
/// يحذف صورة واحدة من معرض المدينة.
class DeleteCityImageEvent extends CitiesEvent {
  /// City name used for audit context and UI refresh.
  ///
  /// اسم المدينة المستخدم لسياق التتبع وتحديث الواجهة.
  final String cityName;

  /// Public image reference to remove.
  ///
  /// المرجع العام للصورة المراد حذفها.
  final String imageUrl;

  /// Packages the city and image reference into one delete command.
  ///
  /// يجمع المدينة ورابط الصورة في أمر حذف واحد.
  const DeleteCityImageEvent({required this.cityName, required this.imageUrl});
  @override
  List<Object?> get props => [cityName, imageUrl];
}

/// Forces the list to reload without changing the current screen context.
///
/// يفرض إعادة تحميل القائمة من دون تغيير سياق الشاشة الحالية.
class RefreshCitiesEvent extends CitiesEvent {
  /// Reissues the current catalog request.
  ///
  /// يعيد إصدار طلب الدليل الحالي.
  const RefreshCitiesEvent();
  @override
  List<Object?> get props => [];
}

/// Switches the visible admin table page.
///
/// يبدّل صفحة جدول الإدارة الظاهرة.
class ChangeCitiesPageEvent extends CitiesEvent {
  /// Desired page index for the current catalog slice.
  ///
  /// فهرس الصفحة المطلوب للشريحة الحالية من الدليل.
  final int page;

  /// Creates a simple page-navigation command.
  ///
  /// ينشئ أمر تنقّل بسيط بين الصفحات.
  const ChangeCitiesPageEvent(this.page);
  @override
  List<Object?> get props => [page];
}

// Internal event for upload progress within the feature library.
class CityImageProgressInternalEvent extends CitiesEvent {
  /// City name tied to the active upload.
  ///
  /// اسم المدينة المرتبط بعملية الرفع النشطة.
  final String cityName;

  /// Upload ratio reported by the media pipeline.
  ///
  /// نسبة التقدم المبلغة من خط معالجة الوسائط.
  final double progress;

  /// Emits granular progress updates without exposing them to the UI layer.
  ///
  /// يبث تحديثات تقدم دقيقة من دون كشفها مباشرة لطبقة الواجهة.
  const CityImageProgressInternalEvent(this.cityName, this.progress);
  @override
  List<Object?> get props => [cityName, progress];
}
