import 'package:flutter/material.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';

/// مجموعة أنماط نصية موحّدة تُستخدم لضمان اتساق العناوين والجسد والأزرار عبر الواجهة.
/// A shared text-style palette that keeps headings, body text, and actions visually consistent.
class AppTextStyles {
  /// Arabic: يمنع إنشاء مثيل لأن هذا الصف يجمع أنماط النص كقوالب ثابتة.
  /// English: Prevents instantiation because this class only exposes reusable text style tokens.
  AppTextStyles._();

  /// أنماط العناوين الكبيرة المستخدمة في الواجهات البارزة والعناوين الرئيسية.
  /// Large display styles for hero headings and prominent section titles.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.5,
  );

  /// Arabic: نمط عرض أقل حجمًا من العنوان الكبير ويستخدم في الأقسام البارزة.
  /// English: Medium display style used for prominent sections that need hierarchy without full hero size.
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -1.0,
  );

  /// Arabic: نمط عرض صغير يناسب البطاقات أو العناوين اللافتة دون مبالغة.
  /// English: Small display style for cards or standout labels that do not need full hero treatment.
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// أنماط العناوين الهرمية المستخدمة في الصفحات والبطاقات والحوارات.
  /// Hierarchical heading styles used by screens, cards, and dialogs.
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  /// Arabic: العنوان الثاني المستخدم في تقسيم الصفحات والأجزاء الفرعية.
  /// English: Secondary heading used for page sections and nested content blocks.
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// Arabic: العنوان الثالث المخصص للعناوين الفرعية أو رؤوس البطاقات.
  /// English: Tertiary heading used for subheadings and card titles.
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
  );

  /// أنماط الجسد المستخدمة للوصف والعناوين المساندة والمحتوى العام.
  /// Body styles used for descriptions, labels, and supporting content.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  /// Arabic: نمط الجسد القياسي للنصوص العامة والوصف المتوازن.
  /// English: Standard body style used for most general-purpose copy.
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.1,
  );

  /// Arabic: نمط الجسد الأصغر للنصوص المساعدة أو التوضيحية.
  /// English: Compact body style used for helper text or compact descriptions.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Arabic: نمط الأزرار الكبير المستخدم في الدعوات الأساسية لاتخاذ إجراء.
  /// English: Large button style used for primary calls to action.
  /// أنماط الأزرار والتسميات التفاعلية التي تحتاج وضوحًا بصريًا أعلى.
  /// Action labels used by buttons and interactive controls.
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Arabic: نمط الأزرار المتوسط المستخدم في الإجراءات القياسية.
  /// English: Medium button style used for standard action labels.
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.4,
  );

  /// Arabic: نمط الأزرار الصغير للواجهات المدمجة أو الأيقونات النصية.
  /// English: Small button style for compact controls or text-only icon actions.
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.3,
  );

  /// أنماط صغيرة للبيانات الوصفية والتلميحات والمعلومات الثانوية.
  /// Small helper styles for metadata, hints, and secondary information.
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.2,
  );

  /// Arabic: نمط علوي يُستخدم عادة للتسميات التنظيمية أو الوسوم الصغيرة.
  /// English: Uppercase-style token used for labels, categories, or small chips.
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 1.0,
  );

  /// أسلوب مخصص لعرض التقييمات في الشارات وملخصات المراجعات.
  /// Rating copy used in score badges and review summaries.
  static const TextStyle rating = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
  );

  /// Creates a text style that paints the glyphs with the portal gradient.
  /// ينشئ نمطًا نصيًا يرسم الحروف بتدرج الهوية البصرية للتطبيق.
  static TextStyle gradientText({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.2,
      foreground: Paint()
        ..shader = AppTheme.primaryGradient.createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  /// Builds a high-emphasis text style with glow shadows for accent surfaces.
  /// ينشئ نمطًا نصيًا عالي الظهور مع ظلال متوهجة يناسب المساحات البارزة.
  static TextStyle neonText({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    final Color resolvedColor = color ?? AppTheme.neonBlue;
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: resolvedColor,
      shadows: [
        Shadow(
          color: resolvedColor.withValues(alpha: 0.8),
          blurRadius: 10,
        ),
        Shadow(
          color: resolvedColor.withValues(alpha: 0.6),
          blurRadius: 20,
        ),
        Shadow(
          color: resolvedColor.withValues(alpha: 0.4),
          blurRadius: 30,
        ),
      ],
    );
  }

  /// Builds a readable white-on-glass style for translucent backgrounds.
  /// ينشئ نمطًا واضحًا للنص فوق الخلفيات الشفافة والزجاجية.
  static TextStyle glassText({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppTheme.textWhite.withValues(alpha: 0.9),
      shadows: const [
        Shadow(
          color: Colors.black26,
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }
}
