// lib/core/enums/section_ui_type.dart

/// يحدد نمط العرض الذي يستخدمه العميل عند رسم القسم.
/// Defines the section rendering style used by the client app.
enum SectionTypeEnum {
  grid,
  bigCards,
  list,
}

/// يربط نوع القسم المحلي بالقيم النصية والرقمية التي يستهلكها الخادم والواجهة.
/// Maps the local section type to the string and numeric values used by the backend and UI.
extension SectionUITypeExtension on SectionTypeEnum {
  /// يعيد القيمة النصية التي يرسلها الخادم ويعرضها العميل.
  /// Returns the string token exchanged with the API and UI.
  String get value {
    switch (this) {
      case SectionTypeEnum.grid:
        return 'grid';
      case SectionTypeEnum.bigCards:
        return 'bigCards';
      case SectionTypeEnum.list:
        return 'list';
    }
  }

  /// يعيد القيمة الرقمية التي يرسلها الخادم عند تمثيل هذا النمط.
  /// Returns the numeric backend value used for this section type.
  int get apiValue {
    switch (this) {
      case SectionTypeEnum.grid:
        return 0;
      case SectionTypeEnum.bigCards:
        return 1;
      case SectionTypeEnum.list:
        return 2;
    }
  }

  /// يعيد اسمًا عربيًا/إنجليزيًا مختصرًا يفيد في الواجهات وملفات السجل.
  /// Returns a compact Arabic/English display name for UI surfaces and logs.
  String get displayName {
    switch (this) {
      case SectionTypeEnum.grid:
        return 'شبكة (Grid)';
      case SectionTypeEnum.bigCards:
        return 'كروت كبيرة (Big Cards)';
      case SectionTypeEnum.list:
        return 'قائمة (List)';
    }
  }

  /// يحاول تحويل النص أو القيمة المختصرة إلى نوع القسم المحلي المقابل.
  /// Attempts to parse a string or shorthand into the matching local section type.
  static SectionTypeEnum? tryFromString(String? value) {
    if (value == null) return null;
    for (final type in SectionTypeEnum.values) {
      if (type.value == value) return type;
    }
    switch (value.toLowerCase()) {
      case '0':
      case 'grid':
        return SectionTypeEnum.grid;
      case '1':
      case 'bigcards':
        return SectionTypeEnum.bigCards;
      case '2':
      case 'list':
        return SectionTypeEnum.list;
    }
    return null;
  }
}
