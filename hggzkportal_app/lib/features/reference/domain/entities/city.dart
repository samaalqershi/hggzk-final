/// يمثل هذا الكيان مدينة مرجعية يمكن ربطها ببيانات البحث أو
/// اختيار الموقع.
/// Represents a reference city that can be used in search or
/// location selection flows.
class City {
  /// الاسم المعروض للمدينة.
  /// Display name of the city.
  final String name;

  /// البلد الذي تنتمي إليه المدينة.
  /// Country the city belongs to.
  final String country;

  /// الصور المساعدة التي تعرض المدينة للمستخدم إن كانت متاحة.
  /// Supporting images shown to the user when available.
  final List<String> images;

  /// ينشئ المدينة مع صور اختيارية حتى تبقى البيانات قابلة
  /// للاستخدام حتى لو لم تُملأ كل الحقول.
  /// Builds the city with optional images so the data stays usable
  /// even when not every field is populated.
  const City({
    required this.name,
    required this.country,
    this.images = const <String>[],
  });
}
