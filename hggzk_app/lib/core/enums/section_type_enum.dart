// lib/core/enums/section_type_enum.dart

/// Groups the allowed values for `SectionType` so the rest of the app stays type-safe.
/// العربية: يعرّف القيم المتاحة للنوع `SectionType`.
enum SectionType {
  grid,
  bigCards,
  list,
}

/// العربية: يعرّف الامتداد `SectionTypeExtension`.
extension SectionTypeExtension on SectionType {
  /// Exposes the `value` value for callers that need it.
  /// العربية: يعيد القيمة `value`.
  String get value {
    switch (this) {
      case SectionType.grid:
        return 'grid';
      case SectionType.bigCards:
        return 'bigCards';
      case SectionType.list:
        return 'list';
    }
  }

  /// Processes the `tryFromString` flow and maps it into the app-level behavior.
  /// العربية: يعالج `tryFromString`.
  static SectionType? tryFromString(String value) {
    for (final type in SectionType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
