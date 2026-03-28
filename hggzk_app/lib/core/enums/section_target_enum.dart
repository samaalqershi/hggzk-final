// lib/core/enums/section_target_enum.dart

/// Groups the allowed values for `SectionTarget` so the rest of the app stays type-safe.
/// العربية: يعرّف القيم المتاحة للنوع `SectionTarget`.
enum SectionTarget {
  properties,
  units,
}

/// العربية: يعرّف الامتداد `SectionTargetBackend`.
extension SectionTargetBackend on SectionTarget {
  /// Exposes the `backendName` value for callers that need it.
  /// العربية: يعيد القيمة `backendName`.
  String get backendName {
    switch (this) {
      case SectionTarget.properties:
        return 'Properties';
      case SectionTarget.units:
        return 'Units';
    }
  }

  /// Processes the `tryParse` flow and maps it into the app-level behavior.
  /// العربية: يعالج `tryParse`.
  static SectionTarget? tryParse(String? value) {
    if (value == null) return null;
    final v = value.trim().toLowerCase();
    if (v == 'properties') return SectionTarget.properties;
    if (v == 'units') return SectionTarget.units;
    return null;
  }
}
