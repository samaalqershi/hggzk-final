// lib/core/enums/section_target.dart

/// يحدد نوع العناصر التي تستهدفها الأقسام: عقارات أو وحدات.
/// Defines which item type a section targets: properties or units.
enum SectionTarget {
  properties,
  units,
}

/// يربط القيمة المحلية بالتمثيل النصي الذي يتوقعه الخادم.
/// Maps the local enum value to the backend string token.
extension SectionTargetApi on SectionTarget {
  /// يعيد الاسم النصي المرسل إلى الخادم لكل نوع استهداف.
  /// Returns the backend string token for each target type.
  String get apiValue {
    switch (this) {
      case SectionTarget.properties:
        return 'Properties';
      case SectionTarget.units:
        return 'Units';
    }
  }

  /// يحاول تفسير النص الوارد من API إلى القيمة المحلية المقابلة.
  /// Attempts to parse a backend string into the matching local enum value.
  static SectionTarget? tryParse(String? value) {
    if (value == null) return null;
    final v = value.trim();
    switch (v) {
      case 'Properties':
        return SectionTarget.properties;
      case 'Units':
        return SectionTarget.units;
      default:
        return null;
    }
  }
}
