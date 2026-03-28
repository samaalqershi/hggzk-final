// lib/core/enums/section_content_type.dart

/// يحدد نوع المحتوى الذي يمكن أن يحتويه القسم: عقارات أو وحدات أو مزيج.
/// Defines which content a section can hold: properties, units, mixed, or none.
enum SectionContentType {
  properties,
  units,
  mixed,
  none,
}

/// يترجم القيمة المحلية إلى رمز الخادم ويعيد تفسير النص الوارد منه.
/// Translates the local enum to backend tokens and parses server responses back.
extension SectionContentTypeApi on SectionContentType {
  /// يعيد الاسم النصي المرسل إلى الخادم.
  /// Returns the backend token for the current content type.
  String get apiValue {
    switch (this) {
      case SectionContentType.properties:
        return 'Properties';
      case SectionContentType.units:
        return 'Units';
      case SectionContentType.mixed:
        return 'Mixed';
      case SectionContentType.none:
        return 'None';
    }
  }

  /// يحاول تحويل النص الوارد من الخادم إلى النوع المحلي المناسب.
  /// Attempts to parse a backend string into the matching local enum value.
  static SectionContentType? tryParse(String? value) {
    if (value == null) return null;
    final v = value.trim();
    switch (v) {
      case 'Properties':
        return SectionContentType.properties;
      case 'Units':
        return SectionContentType.units;
      case 'Mixed':
        return SectionContentType.mixed;
      case 'None':
        return SectionContentType.none;
      default:
        return null;
    }
  }
}
