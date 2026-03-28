// import 'package:flutter/material.dart';
import 'app_theme.dart';

// class AppColors {
//   AppColors._();

//   // 🎨 Primary Gradient Colors (من هويتك البصرية)
//   static const Color primaryBlue = Color(0xFF4FACFE);
//   static const Color primaryPurple = Color(0xFF667EEA);
//   static const Color primaryViolet = Color(0xFF764BA2);
//   static const Color primaryCyan = Color(0xFF00F2FE);

//   // 🌟 Neon & Glow Colors
//   static const Color neonBlue = Color(0xFF00D4FF);
//   static const Color neonPurple = Color(0xFF9D50FF);
//   static const Color neonGreen = Color(0xFF00FF88);
//   static const Color glowBlue = Color(0xFF4FACFE);
//   static const Color glowWhite = Color(0xFFFFFFFF);

//   // 🌙 Dark Theme Base Colors
//   static const Color darkBackground = Color(0xFF0A0E27);
//   static const Color darkBackground2 = Color(0xFF0F1629);    // اللون الثاني للتدرج
//   static const Color darkBackground3 = Color(0xFF1A0E3D);    // اللون الثالث للتدرج
//   static const Color darkSurface = Color(0xFF151930);

//   static const Color darkCard = Color(0xFF1E2341);
//   static const Color darkBorder = Color(0xFF2A3050);

//   // ☀️ Light Theme Base Colors
//   static const Color lightBackground = Color(0xFFF8FAFF);
//   static const Color lightSurface = Color(0xFFFFFFFF);
//   static const Color lightCard = Color(0xFFFFFFFF);
//   static const Color lightBorder = Color(0xFFE8ECFA);

//   // 📝 Text Colors
//   static const Color textWhite = Color(0xFFFFFFFF);
//   static const Color textLight = Color(0xFFB8C4E6);
//   static const Color textMuted = Color(0xFF8B95B7);
//   static const Color textDark = Color(0xFF1A1F36);

//   // ✨ Glass & Blur Effects
//   static const Color glassDark = Color(0x1A000000);
//   static const Color glassLight = Color(0x0DFFFFFF);
//   static const Color glassOverlay = Color(0x80151930);
//   static const Color frostedGlass = Color(0x30FFFFFF);

//   // 🚦 Status Colors
//   static const Color success = Color(0xFF00FF88);
//   static const Color warning = Color(0xFFFFB800);
//   static const Color error = Color(0xFFFF3366);
//   static const Color info = Color(0xFF00D4FF);

//   // 🎭 Shadows & Overlays
//   static const Color shadowDark = Color(0x40000000);
//   static const Color shadowLight = Color(0x1A4FACFE);
//   static const Color overlayDark = Color(0xCC0A0E27);
//   static const Color overlayLight = Color(0x99FFFFFF);

//   // 🌈 Gradient Definitions
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primaryCyan, primaryBlue, primaryPurple, primaryViolet],
//     stops: [0.0, 0.3, 0.6, 1.0],
//   );

//   static const LinearGradient darkGradient = LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [Color(0xFF1A1F36), AppColors.darkBackground2],
//   );

//   static const LinearGradient cardGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       Color(0x1A4FACFE),
//       Color(0x0D667EEA),
//       Color(0x1A764BA2),
//     ],
//   );

//   static const LinearGradient neonGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [neonBlue, neonPurple, neonGreen],
//   );

//   static const LinearGradient glassGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       Color(0x40FFFFFF),
//       Color(0x1AFFFFFF),
//       Color(0x40FFFFFF),
//     ],
//   );

//   static const RadialGradient glowGradient = RadialGradient(
//     colors: [
//       Color(0x804FACFE),
//       Color(0x404FACFE),
//       Color(0x004FACFE),
//     ],
//   );

//   // 🎯 Component Specific Colors
//   static const Color buttonPrimary = primaryBlue;
//   static const Color buttonSecondary = primaryPurple;
//   static const Color inputBackground = Color(0x0D4FACFE);
//   static const Color inputBorder = Color(0x334FACFE);
//   static const Color inputFocusBorder = primaryBlue;

//   // 💎 Special Effects
//   static Color shimmerBase = primaryBlue.withValues(alpha: 0.05);
//   static Color shimmerHighlight = primaryBlue.withValues(alpha: 0.2);
//   static Color holographic = primaryPurple.withValues(alpha: 0.3);

//   // 🔲 Booking Status (محدثة)
//   static const Color bookingPending = Color(0xFFFFB800);
//   static const Color bookingConfirmed = Color(0xFF00FF88);
//   static const Color bookingCancelled = Color(0xFFFF3366);
//   static const Color bookingCompleted = Color(0xFF00D4FF);

//   // 🔁 Backward-compatible aliases (for legacy references)
//   static const Color shadow = shadowDark; // Legacy: AppColors.shadow
//   static const Color primaryDark = AppColors.darkBackground2; // Legacy dark variant used in gradients
//   static const Color transparent = Colors.transparent; // Legacy: AppColors.transparent
//   static const Color gray200 = lightBorder; // Legacy neutral gray used in widgets
//   static const Color textDisabled = textMuted; // Legacy disabled text
//   static const Color shimmer = Color(0xFF2A3050); // Legacy shimmer base color
// }

import 'package:flutter/material.dart';

/// لوحة الألوان المرجعية التي تربط الهوية البصرية، الحالات، والتدرجات المستخدمة في البورتال.
/// Shared color palette for brand accents, states, overlays, and gradients used throughout the portal.
class AppColors {
  /// Arabic: يمنع إنشاء مثيل لأن هذا الصف يجمع ألوان الثيم كمصدر واحد مشترك.
  /// English: Prevents instantiation because this class is a shared color token holder.
  AppColors._();

  /// Arabic: اللون الأساسي المعتمد للعناصر الرئيسية وروابط الهوية.
  /// English: Primary brand blue used for emphasis, links, and key surfaces.
  static const Color primaryBlue = Color(0xFF0066CC);

  /// Arabic: اللون المساند المستخدم بجانب الأزرق في التدرجات والتمييز.
  /// English: Supporting purple used alongside blue in gradients and accents.
  static const Color primaryPurple = Color(0xFF6366F1);

  /// Arabic: اللون البنفسجي الأفتح المستخدم لإكمال التدرج البصري.
  /// English: Lighter violet used to complete the visual gradient range.
  static const Color primaryViolet = Color(0xFF8B5CF6);

  /// Arabic: اللون السماوي المستخدم لإبراز الطاقة والوضوح في التدرج.
  /// English: Cyan accent used to bring clarity and energy into gradients.
  static const Color primaryCyan = Color(0xFF0891B2);

  /// Arabic: الأزرق النيون المستخدم في اللمعان والتمييز المرئي.
  /// English: Neon blue used for glow effects and visual emphasis.
  static const Color neonBlue = Color(0xFF0EA5E9);

  /// Arabic: البنفسجي النيون المستخدم في عناصر التوهج الحديثة.
  /// English: Neon purple used in modern glow treatments.
  static const Color neonPurple = Color(0xFFA855F7);

  /// Arabic: الأخضر النيون المستخدم لعلامات النجاح أو اللمعان الحي.
  /// English: Neon green used for success cues and vivid glow accents.
  static const Color neonGreen = Color(0xFF10B981);

  /// Arabic: أزرق التوهج المستخدم في الظلال الخفيفة والإبرازات.
  /// English: Glow blue used for subtle shadows and highlights.
  static const Color glowBlue = Color(0xFF3B82F6);

  /// Arabic: أبيض التوهج المستخدم للنقاط اللامعة والأسطح الفاتحة.
  /// English: Glow white used for bright highlights and light surfaces.
  static const Color glowWhite = Color(0xFFFAFAFA);

  /// Arabic: الخلفية الأساسية المستخدمة عندما يحتاج الثيم إلى سطح فاتح جدًا.
  /// English: Base background token used for very light surfaces in the current theme.
  static const Color darkBackground = Color(0xFFFAFAFA);

  /// Arabic: الخلفية الثانوية المستخدمة في التدرجات والأسطح المتدرجة.
  /// English: Secondary background token used in layered gradients and surfaces.
  static const Color darkBackground2 = Color(0xFFFAFAFA);

  /// Arabic: الخلفية الثالثة المستخدمة لتفادي التكرار في التدرج.
  /// English: Third background token used to avoid repetition in gradient sets.
  static const Color darkBackground3 = Color(0xFFFAFAFA);

  /// Arabic: لون السطح الرئيسي للبطاقات والحاويات.
  /// English: Primary surface color for cards and containers.
  static const Color darkSurface = Color(0xFFFFFFFF);

  /// Arabic: لون البطاقة الأساسي المستخدم في الواجهات الهادئة.
  /// English: Default card color used across calm light surfaces.
  static const Color darkCard = Color(0xFFFFFFFF);

  /// Arabic: لون الحدود الفاتحة حول الأسطح والعناصر.
  /// English: Light border color around surfaces and components.
  static const Color darkBorder = Color(0xFFE5E5E5);

  /// Arabic: الخلفية المخصصة للوضع الفاتح العام.
  /// English: Main background used for the light theme.
  static const Color lightBackground = Color(0xFFF9FAFB);

  /// Arabic: السطح الفاتح المستخدم في الحاويات والصفحات.
  /// English: Light surface color used in containers and pages.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Arabic: لون البطاقة في الوضع الفاتح.
  /// English: Card color used in the light theme.
  static const Color lightCard = Color(0xFFFFFFFF);

  /// Arabic: لون الحدود في الوضع الفاتح.
  /// English: Border color used in the light theme.
  static const Color lightBorder = Color(0xFFE5E7EB);

  /// Arabic: اللون المستخدم للنصوص الفاتحة فوق الأسطح الداكنة أو البارزة.
  /// English: Light text color used over darker or more prominent surfaces.
  static const Color textWhite = Color(0xFF111827);

  /// Arabic: اللون المستخدم للنصوص الثانوية أو العناوين الأقل بروزًا.
  /// English: Secondary text color used for softer headings and labels.
  static const Color textLight = Color(0xFF374151);

  /// Arabic: اللون المستخدم للنصوص المساندة أو الوصفية.
  /// English: Muted text color used for descriptions and supporting copy.
  static const Color textMuted = Color(0xFF6B7280);

  /// Arabic: اللون الداكن جدًا المستخدم للنصوص الأساسية في الوضع الفاتح.
  /// English: Very dark text color used for primary copy in the light theme.
  static const Color textDark = Color(0xFF030712);

  /// Arabic: طبقة زجاجية داكنة خفيفة للتمرير فوق الخلفيات الفاتحة.
  /// English: Soft dark glass layer for overlays on light backgrounds.
  static const Color glassDark = Color(0x08000000);

  /// Arabic: طبقة زجاجية ملونة بخفة لتأكيد الهوية البصرية.
  /// English: Subtle colored glass layer that carries the brand accent.
  static const Color glassLight = Color(0x0F0066CC);

  /// Arabic: طبقة تغطية شفافة تُستخدم فوق الصور أو النوافذ.
  /// English: Transparent overlay used above images and floating surfaces.
  static const Color glassOverlay = Color(0x66FFFFFF);

  /// Arabic: لون الزجاج المصنفر المستخدم في اللوحات العائمة.
  /// English: Frosted glass tone used in floating panels and cards.
  static const Color frostedGlass = Color(0x99F9FAFB);

  /// Arabic: لون النجاح المستخدم للعمليات المكتملة والتنبيهات الإيجابية.
  /// English: Success color used for completed actions and positive feedback.
  static const Color success = Color(0xFF059669);

  /// Arabic: لون التحذير المستخدم قبل الأخطاء أو عند الحاجة إلى الانتباه.
  /// English: Warning color used before errors or when attention is needed.
  static const Color warning = Color(0xFFF59E0B);

  /// Arabic: لون الخطأ المستخدم للحالات الفاشلة أو التحقق غير الصحيح.
  /// English: Error color used for failed operations or invalid states.
  static const Color error = Color(0xFFDC2626);

  /// Arabic: لون المعلومات المستخدم للتلميحات والرسائل الإرشادية.
  /// English: Info color used for guidance and neutral informational messages.
  static const Color info = Color(0xFF0284C7);

  /// Arabic: ظل داكن ناعم يستخدم لإعطاء العمق دون ثقل بصري.
  /// English: Soft dark shadow used to create depth without visual heaviness.
  static const Color shadowDark = Color(0x0A000000);

  /// Arabic: ظل ملون خفيف ينسجم مع الأزرق الأساسي.
  /// English: Soft colored shadow that matches the primary blue accent.
  static const Color shadowLight = Color(0x050066CC);

  /// Arabic: طبقة تغطية داكنة خفيفة لزيادة التباين فوق الخلفيات الفاتحة.
  /// English: Light dark overlay used to increase contrast on bright backgrounds.
  static const Color overlayDark = Color(0x0A111827);

  /// Arabic: طبقة تغطية بيضاء شبه معتمة للأسطح والحوارات.
  /// English: Nearly opaque white overlay used for surfaces and dialogs.
  static const Color overlayLight = Color(0xE6FFFFFF);

  /// Arabic: التدرج الأساسي الذي يجمع ألوان الهوية الرئيسية للعناصر البارزة.
  /// English: Primary gradient that combines the core brand colors for
  /// emphasized surfaces.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCyan, primaryBlue, primaryPurple, primaryViolet],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  /// Arabic: تدرج خلفية هادئ يستخدم للأسطح الكبيرة والخلفيات الرصينة.
  /// English: Calm background gradient used for large surfaces and restrained
  /// page backgrounds.
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FAFB), Color(0xFFFAFAFA)],
  );

  /// Arabic: تدرج بطاقات خفيف يضيف عمقًا بصريًا من دون تشويش المحتوى.
  /// English: Soft card gradient that adds visual depth without distracting
  /// from content.
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x050066CC), // أزرق شفاف جداً
      Color(0x036366F1), // بنفسجي شفاف جداً
      Color(0x058B5CF6), // violet شفاف جداً
    ],
  );

  /// Arabic: تدرج حيوي مخصص للعناصر اللامعة أو الواجهات التي تحتاج طاقة أعلى.
  /// English: Vivid gradient intended for glowing elements or higher-energy
  /// UI treatments.
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, neonPurple, neonGreen],
  );

  /// Arabic: تدرج زجاجي شبه شفاف يستخدم في الحوارات والأسطح الضبابية.
  /// English: Semi-transparent glass gradient used in blurred surfaces and
  /// dialog treatments.
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0DFFFFFF), // أبيض شفاف
      Color(0x08FFFFFF), // أبيض شفاف جداً
      Color(0x0DFFFFFF), // أبيض شفاف
    ],
  );

  /// Arabic: تدرج شعاعي ناعم يمنح تأثير توهج مركزي حول العناصر البارزة.
  /// English: Soft radial gradient that creates a centered glow around
  /// highlighted elements.
  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x1A0066CC), // مركز أزرق خفيف
      Color(0x0D0066CC), // وسط
      Color(0x000066CC), // حافة شفافة
    ],
  );

  /// Arabic: لون الزر الرئيسي في الواجهة.
  /// English: Primary button color used throughout the interface.
  static const Color buttonPrimary = primaryBlue; // زر أساسي
  /// Arabic: لون الزر الثانوي الذي يدعم الإجراء الرئيسي.
  /// English: Secondary button color used to support the primary action.
  static const Color buttonSecondary = primaryPurple;

  /// Arabic: لون خلفية حقول الإدخال.
  /// English: Background color used for input fields.
  static const Color inputBackground = Color(0xFFF3F4F6);

  /// Arabic: لون حدود حقول الإدخال في وضعها العادي.
  /// English: Border color used by input fields in their default state.
  static const Color inputBorder = Color(0xFFD1D5DB);

  /// Arabic: لون حدود حقول الإدخال عند التركيز.
  /// English: Border color used by input fields when focused.
  static const Color inputFocusBorder = primaryBlue;

  /// Arabic: اللون الأساسي المستخدم لبناء تأثيرات اللمعان التدريجي.
  /// English: Base color used to build shimmer effects.
  static Color shimmerBase = primaryBlue.withValues(alpha: 0.03);

  /// Arabic: اللون الأفتح داخل حركة اللمعان لإبراز التمرير.
  /// English: Brighter shimmer highlight color used during the sweep.
  static Color shimmerHighlight = primaryBlue.withValues(alpha: 0.08);

  /// Arabic: لون خفيف يدعم تأثير الهولوجرام والطبقات الشفافة.
  /// English: Light holographic tint used for translucent layered effects.
  static Color holographic = primaryPurple.withValues(alpha: 0.1);

  /// Arabic: لون حالة الحجز المعلّق قبل التأكيد النهائي.
  /// English: Booking status color for pending reservations.
  static const Color bookingPending = Color(0xFFF59E0B);

  /// Arabic: لون حالة الحجز المؤكد.
  /// English: Booking status color for confirmed reservations.
  static const Color bookingConfirmed = Color(0xFF059669);

  /// Arabic: لون حالة الحجز الملغى.
  /// English: Booking status color for cancelled reservations.
  static const Color bookingCancelled = Color(0xFFDC2626);

  /// Arabic: لون حالة الحجز المكتمل.
  /// English: Booking status color for completed reservations.
  static const Color bookingCompleted = Color(0xFF0284C7);

  /// Arabic: اسم قديم ما زلنا نحافظ عليه للرجوع التوافقي.
  /// English: Legacy alias kept for backward compatibility.
  static const Color shadow = shadowDark;

  /// Arabic: النسخة الداكنة القديمة من اللون الأساسي.
  /// English: Legacy darker variant of the primary color.
  static const Color primaryDark = Color(0xFF003D7A);

  /// Arabic: الاسم القديم للشفافية الكاملة.
  /// English: Legacy alias for full transparency.
  static const Color transparent = Colors.transparent;

  /// Arabic: اسم قديم يشير إلى درجة الرمادي الفاتحة المستخدمة في الواجهات.
  /// English: Legacy alias for the light neutral gray used in widgets.
  static const Color gray200 = lightBorder;

  /// Arabic: اسم قديم للنص المعطل.
  /// English: Legacy alias for disabled text color.
  static const Color textDisabled = textMuted;

  /// Arabic: قاعدة اللمعان القديمة المستخدمة في النسخ الأقدم من الواجهة.
  /// English: Legacy shimmer base color kept for old widget references.
  static const Color shimmer = Color(0xFFF3F4F6);

  /// Arabic: اللون الأساسي المشتق من `AppTheme` للاستخدامات العامة.
  /// English: Primary color derived from `AppTheme` for general use.
  static Color get primary => AppTheme.primaryBlue;

  /// Arabic: لون السطح العام وفق وضع الثيم الحالي.
  /// English: Current theme surface color resolved from `AppTheme`.
  static Color get surface =>
      AppTheme.isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

  /// Arabic: لون الخلفية العام وفق وضع الثيم الحالي.
  /// English: Current theme background color resolved from `AppTheme`.
  static Color get background =>
      AppTheme.isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

  /// Arabic: لون النص العام وفق وضع الثيم الحالي.
  /// English: Current theme text color resolved from `AppTheme`.
  static Color get text =>
      AppTheme.isDark ? AppTheme.textWhite : AppTheme.textDark;

  /// Arabic: لون النص المساند المستمد من الثيم.
  /// English: Supporting text color derived from the active theme.
  static Color get textSecondary => AppTheme.textMuted;

  /// Arabic: لون التمييز المستمد من لون السيان الأساسي.
  /// English: Accent color derived from the primary cyan token.
  static Color get accent => AppTheme.primaryCyan;
}
