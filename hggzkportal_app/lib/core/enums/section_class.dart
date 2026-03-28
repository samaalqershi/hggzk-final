// lib/core/enums/section_class.dart

/// يحدد الفئة التصنيفية للقسم وفق القيمة المتوقعة من الخادم.
/// Defines the classification bucket used for a section in backend payloads.
enum SectionClass {
  classA,
  classB,
  classC,
  classD,
}

/// يربط الفئة المحلية بالرمز النصي المعتمد في الـ API.
/// Maps the local section class to the API string token.
extension SectionClassApi on SectionClass {
  /// يعيد الاسم النصي الذي يفهمه الخادم لهذه الفئة.
  /// Returns the backend string token for the current class.
  String get apiValue {
    switch (this) {
      case SectionClass.classA:
        return 'ClassA';
      case SectionClass.classB:
        return 'ClassB';
      case SectionClass.classC:
        return 'ClassC';
      case SectionClass.classD:
        return 'ClassD';
    }
  }

  /// يحاول قراءة نص الخادم وتحويله إلى الفئة المحلية المناسبة.
  /// Attempts to parse a backend string into the matching local class.
  static SectionClass? tryParse(String? value) {
    if (value == null) return null;
    switch (value.trim()) {
      case 'ClassA':
        return SectionClass.classA;
      case 'ClassB':
        return SectionClass.classB;
      case 'ClassC':
        return SectionClass.classC;
      case 'ClassD':
        return SectionClass.classD;
      default:
        return null;
    }
  }
}
