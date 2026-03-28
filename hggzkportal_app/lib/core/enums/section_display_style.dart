// lib/core/enums/section_display_style.dart

/// يحدد أسلوب عرض القسم داخل الواجهة مثل الشبكة أو القائمة أو الخريطة.
/// Defines how a section is presented in the UI such as grid, list, or map.
enum SectionDisplayStyle {
  grid,
  list,
  carousel,
  map,
}

/// يربط نمط العرض المحلي بقيمة الخادم النصية المقابلة.
/// Maps the local display style to the backend string token.
extension SectionDisplayStyleApi on SectionDisplayStyle {
  /// يعيد النص الذي يتوقعه الخادم لهذا النمط.
  /// Returns the backend string expected for the current display style.
  String get apiValue {
    switch (this) {
      case SectionDisplayStyle.grid:
        return 'Grid';
      case SectionDisplayStyle.list:
        return 'List';
      case SectionDisplayStyle.carousel:
        return 'Carousel';
      case SectionDisplayStyle.map:
        return 'Map';
    }
  }

  /// يحاول تفسير النص الوارد من API إلى نمط العرض المحلي.
  /// Attempts to parse a backend string into the matching local display style.
  static SectionDisplayStyle? tryParse(String? value) {
    if (value == null) return null;
    final v = value.trim();
    switch (v) {
      case 'Grid':
        return SectionDisplayStyle.grid;
      case 'List':
        return SectionDisplayStyle.list;
      case 'Carousel':
        return SectionDisplayStyle.carousel;
      case 'Map':
        return SectionDisplayStyle.map;
      default:
        return null;
    }
  }
}
