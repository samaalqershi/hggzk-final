import 'property_type.dart';
import 'unit_type.dart';

/// يجمع أنواع العقارات مع أنواع الوحدات التابعة لها في حمولة واحدة حتى تبدأ
/// الصفحة الرئيسية ببيانات مترابطة من دون طلبين منفصلين.
/// Bundles property types together with their dependent unit types so the home
/// screen can start with coherent data instead of making two separate calls.
class PropertyTypesWithUnits {
  /// جميع أنواع العقارات المتاحة ضمن هذه الحمولة.
  /// All property types included in this payload.
  final List<PropertyType> propertyTypes;

  /// أنواع الوحدات مفهرسة حسب معرّف نوع العقار الأب لتسهيل قراءتها في الواجهة.
  /// Unit types keyed by parent property-type id so the UI can read them
  /// without extra grouping work.
  final Map<String, List<UnitType>> unitTypesByPropertyTypeId;

  /// ينشئ الحزمة الموحدة التي تحمل الأنواع الأساسية والأنواع التابعة لها معًا.
  /// Creates the combined payload that carries primary property types together
  /// with their dependent unit types.
  const PropertyTypesWithUnits({
    required this.propertyTypes,
    required this.unitTypesByPropertyTypeId,
  });
}
