// // lib/core/theme/app_theme.dart

// import 'package:flutter/material.dart';

// /// 🎨 Unified Theme System - نظام ثيم موحد
// class AppTheme {
//   AppTheme._();

//   // Current theme mode
//   static ThemeMode _themeMode = ThemeMode.system;
//   static ThemeMode get themeMode => _themeMode;

//   // Track current brightness
//   static Brightness _brightness = Brightness.dark;
//   static Brightness get brightness => _brightness;

//   // Initialize theme based on system or manual setting
//   static void init(BuildContext context, {ThemeMode? mode}) {
//     _themeMode = mode ?? ThemeMode.system;
//     final systemBrightness = MediaQuery.of(context).platformBrightness;

//     if (_themeMode == ThemeMode.system) {
//       _brightness = systemBrightness;
//     } else if (_themeMode == ThemeMode.light) {
//       _brightness = Brightness.light;
//     } else {
//       _brightness = Brightness.dark;
//     }
//   }

//   // Helper method to check if dark mode
//   static bool get isDark => _brightness == Brightness.dark;

//   // 🎨 Primary Gradient Colors
//   static Color get primaryBlue => isDark ? const Color(0xFF4FACFE) : const Color(0xFF0066CC);
//   static Color get primaryPurple => isDark ? const Color(0xFF667EEA) : const Color(0xFF6366F1);
//   static Color get primaryViolet => isDark ? const Color(0xFF764BA2) : const Color(0xFF8B5CF6);
//   static Color get primaryCyan => isDark ? const Color(0xFF00F2FE) : const Color(0xFF0891B2);

//   // 🌟 Neon & Glow Colors
//   static Color get neonBlue => isDark ? const Color(0xFF00D4FF) : const Color(0xFF0EA5E9);
//   static Color get neonPurple => isDark ? const Color(0xFF9D50FF) : const Color(0xFFA855F7);
//   static Color get neonGreen => isDark ? const Color(0xFF00FF88) : const Color(0xFF10B981);
//   static Color get glowBlue => isDark ? const Color(0xFF4FACFE) : const Color(0xFF3B82F6);
//   static Color get glowWhite => isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFAFAFA);

//   // 🌙 Base Colors
//   static Color get darkBackground => isDark ? const Color(0xFF0A0E27) : const Color(0xFFFAFAFA);
//   static Color get darkBackground2 => isDark ? const Color(0xFF0F1629) : const Color(0xFFFAFAFA);
//   static Color get darkBackground3 => isDark ? const Color(0xFF1A0E3D) : const Color(0xFFFAFAFA);

//   // static Color get darkBackground => isDark ? const Color(0xFF0A0E27) : const Color(0xFFFAFBFF);
//   // static Color get darkBackground2 => isDark ? const Color(0xFF0D1332) : const Color(0xFFF5F7FE);
//   // static Color get darkBackground3 => isDark ? const Color(0xFF11183F) : const Color(0xFFF0F3FD);

//   // static Color get darkBackground => isDark ? const Color(0xFF0A0E27) : const Color(0xFFF0F4FF);
//   // static Color get darkBackground2 => isDark ? const Color(0xFF1A1547) : const Color(0xFFE8EFFF);
//   // static Color get darkBackground3 => isDark ? const Color(0xFF2D1B69) : const Color(0xFFE0E8FF);

//   static Color get darkSurface => isDark ? const Color(0xFF151930) : const Color(0xFFFFFFFF);
//   static Color get darkCard => isDark ? const Color(0xFF1E2341) : const Color(0xFFFFFFFF);
//   static Color get darkBorder => isDark ? const Color(0xFF2A3050) : const Color(0xFFE5E5E5);

//   // ☀️ Light Theme Base Colors
//   static Color get lightBackground => isDark ? const Color(0xFFF8FAFF) : const Color(0xFFF9FAFB);
//   static Color get lightSurface => isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);
//   static Color get lightCard => isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);
//   static Color get lightBorder => isDark ? const Color(0xFFE8ECFA) : const Color(0xFFE5E7EB);

//   // 📝 Text Colors
//   static Color get textWhite => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111827);
//   static Color get textLight => isDark ? const Color(0xFFB8C4E6) : const Color(0xFF374151);
//   static Color get textMuted => isDark ? const Color(0xFF8B95B7) : const Color(0xFF6B7280);
//   static Color get textDark => isDark ? const Color(0xFF1A1F36) : const Color(0xFF030712);

//   // ✨ Glass & Blur Effects
//   static Color get glassDark => isDark ? const Color(0x1A000000) : const Color(0x08000000);
//   static Color get glassLight => isDark ? const Color(0x0DFFFFFF) : const Color(0x0F0066CC);
//   static Color get glassOverlay => isDark ? const Color(0x80151930) : const Color(0x66FFFFFF);
//   static Color get frostedGlass => isDark ? const Color(0x30FFFFFF) : const Color(0x99F9FAFB);

//   // 🚦 Status Colors
//   static Color get success => isDark ? const Color(0xFF00FF88) : const Color(0xFF059669);
//   static Color get warning => isDark ? const Color(0xFFFFB800) : const Color(0xFFF59E0B);
//   static Color get error => isDark ? const Color(0xFFFF3366) : const Color(0xFFDC2626);
//   static Color get info => isDark ? const Color(0xFF00D4FF) : const Color(0xFF0284C7);

//   // 🎭 Shadows & Overlays
//   static Color get shadowDark => isDark ? const Color(0x40000000) : const Color(0x0A000000);
//   static Color get shadowLight => isDark ? const Color(0x1A4FACFE) : const Color(0x050066CC);
//   static Color get overlayDark => isDark ? const Color(0xCC0A0E27) : const Color(0x0A111827);
//   static Color get overlayLight => isDark ? const Color(0x99FFFFFF) : const Color(0xE6FFFFFF);

//   // 🌈 Gradient Definitions
//   static LinearGradient get primaryGradient => LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primaryCyan, primaryBlue, primaryPurple, primaryViolet],
//     stops: const [0.0, 0.3, 0.6, 1.0],
//   );

//   static LinearGradient get darkGradient => isDark
//     ? const LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [Color(0xFF1A1F36), Color(0xFF0F1629)],
//       )
//     : const LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [Color(0xFFF9FAFB), Color(0xFFFAFAFA)],
//       );

//   static LinearGradient get cardGradient => isDark
//     ? const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Color(0x1A4FACFE),
//           Color(0x0D667EEA),
//           Color(0x1A764BA2),
//         ],
//       )
//     : const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Color(0x050066CC),
//           Color(0x036366F1),
//           Color(0x058B5CF6),
//         ],
//       );

//   static LinearGradient get neonGradient => LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [neonBlue, neonPurple, neonGreen],
//   );

//   static LinearGradient get glassGradient => isDark
//     ? const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Color(0x40FFFFFF),
//           Color(0x1AFFFFFF),
//           Color(0x40FFFFFF),
//         ],
//       )
//     : const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Color(0x0DFFFFFF),
//           Color(0x08FFFFFF),
//           Color(0x0DFFFFFF),
//         ],
//       );

//   static RadialGradient get glowGradient => isDark
//     ? const RadialGradient(
//         colors: [
//           Color(0x804FACFE),
//           Color(0x404FACFE),
//           Color(0x004FACFE),
//         ],
//       )
//     : const RadialGradient(
//         colors: [
//           Color(0x1A0066CC),
//           Color(0x0D0066CC),
//           Color(0x000066CC),
//         ],
//       );

//   // 🎯 Component Specific Colors
//   static Color get buttonPrimary => primaryBlue;
//   static Color get buttonSecondary => primaryPurple;
//   static Color get inputBackground => isDark ? const Color(0x0D4FACFE) : const Color(0xFFD1D5DB);
//   static Color get inputBorder => isDark ? const Color(0x334FACFE) : const Color(0xFFD1D5DB);
//   static Color get inputFocusBorder => primaryBlue;

//   // 💎 Special Effects
//   static Color get shimmerBase => primaryBlue.withValues(alpha: isDark ? 0.05 : 0.03);
//   static Color get shimmerHighlight => primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08);
//   static Color get holographic => primaryPurple.withValues(alpha: isDark ? 0.3 : 0.1);

//   // 🔲 Booking Status
//   static Color get bookingPending => isDark ? const Color(0xFFFFB800) : const Color(0xFFF59E0B);
//   static Color get bookingConfirmed => isDark ? const Color(0xFF00FF88) : const Color(0xFF059669);
//   static Color get bookingCancelled => isDark ? const Color(0xFFFF3366) : const Color(0xFFDC2626);
//   static Color get bookingCompleted => isDark ? const Color(0xFF00D4FF) : const Color(0xFF0284C7);

//   // 🔁 Backward-compatible aliases
//   static Color get shadow => shadowDark;
//   static Color get primaryDark => isDark ? const Color(0xFF0F1629) : const Color(0xFF003D7A);
//   static const Color transparent = Colors.transparent;
//   static Color get gray200 => lightBorder;
//   static Color get textDisabled => textMuted;
//   static Color get shimmer => isDark ? const Color(0xFF2A3050) : const Color(0xFFF3F4F6);
// }
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// 🎨 Unified Theme System - نظام ثيم موحد
class AppTheme {
  /// Arabic: يمنع إنشاء مثيل لأن هذا الصف يدير القيم الثابتة والمتغيرة للثيم فقط.
  /// English: Prevents instantiation because this class only manages shared theme state and tokens.
  AppTheme._();

  /// Arabic: نمط الثيم الحالي المستخدم في التطبيق.
  /// English: Current theme mode used by the application.
  static ThemeMode _themeMode = ThemeMode.system;

  /// Arabic: يعيد نمط الثيم الحالي كما هو مخزن داخليًا.
  /// English: Returns the currently stored theme mode.
  static ThemeMode get themeMode => _themeMode;

  /// Arabic: درجة السطوع الحالية التي تعتمد عليها الألوان المشتقة.
  /// English: Current brightness used to resolve theme-dependent colors.
  static Brightness _brightness = Brightness.dark;

  /// Arabic: يعيد السطوع الحالي بعد تهيئة الثيم أو مطابقته للنظام.
  /// English: Returns the active brightness after theme initialization or system sync.
  static Brightness get brightness => _brightness;

  /// Arabic: يهيئ الثيم وفق النمط المطلوب أو وفق سطوع النظام عند اختيار الوضع التلقائي.
  /// English: Initializes the theme using the requested mode or the system brightness when automatic mode is selected.
  static void init(BuildContext context, {ThemeMode? mode}) {
    _themeMode = mode ?? ThemeMode.system;
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    if (_themeMode == ThemeMode.system) {
      _brightness = systemBrightness;
    } else if (_themeMode == ThemeMode.light) {
      _brightness = Brightness.light;
    } else {
      _brightness = Brightness.dark;
    }
  }

  /// Arabic: يحدد ما إذا كان الثيم الحالي يعمل في وضع داكن.
  /// English: Checks whether the active theme should be treated as dark.
  static bool get isDark => _brightness == Brightness.dark;

  /// Arabic: اللون الأساسي للأزرار والتأكيدات والروابط البارزة.
  /// English: Primary blue used for buttons, links, and key emphasis.
  static Color get primaryBlue =>
      isDark ? const Color(0xFF5B8DEE) : const Color(0xFF3260CC);

  /// Arabic: اللون الثانوي المستخدم في التدرجات والتمييز البصري.
  /// English: Secondary purple used in gradients and visual accents.
  static Color get primaryPurple =>
      isDark ? const Color(0xFF7C6FD8) : const Color(0xFF5E52B8);

  /// Arabic: اللون البنفسجي المضيء الذي يكمل تدرج الهوية.
  /// English: Highlight violet used to complete the brand gradient.
  static Color get primaryViolet =>
      isDark ? const Color(0xFF9D7FE8) : const Color(0xFF7B5FCF);

  /// Arabic: اللون السماوي الأساسي المستخدم في التدرجات الاحترافية.
  /// English: Core cyan accent used in the primary gradient palette.
  static Color get primaryCyan =>
      isDark ? const Color(0xFF4A9FFF) : const Color(0xFF2E7DD4);

  /// Arabic: الأزرق النيون المستخدم في لمسات التوهج.
  /// English: Neon blue used for glow highlights.
  static Color get neonBlue =>
      isDark ? const Color(0xFF6BB6FF) : const Color(0xFF4A9FFF);

  /// Arabic: البنفسجي النيون المستخدم في المساحات البارزة.
  /// English: Neon purple used for prominent glowing accents.
  static Color get neonPurple =>
      isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B6FE3);

  /// Arabic: الأخضر النيون المستخدم لعلامات النجاح الحية.
  /// English: Neon green used for vivid success cues.
  static Color get neonGreen =>
      isDark ? const Color(0xFF5EEAD4) : const Color(0xFF14B8A6);

  /// Arabic: لون التوهج الأزرق المستخدم في الإشارات والإبرازات.
  /// English: Blue glow color used for highlights and signals.
  static Color get glowBlue =>
      isDark ? const Color(0xFF5B8DEE) : const Color(0xFF4A7FDB);

  /// Arabic: اللون الأبيض اللامع المستخدم للألواح والنصوص المضيئة.
  /// English: Bright white used for glowing text and luminous surfaces.
  static Color get glowWhite =>
      isDark ? const Color(0xFFF0F5FF) : const Color(0xFFFFFFFF);

  /// Arabic: الخلفية الرئيسية التي تستقبل بقية طبقات التصميم.
  /// English: Primary background color that anchors the rest of the layout.
  static Color get darkBackground =>
      isDark ? const Color(0xFF0B1929) : const Color(0xFFF7FAFF);

  /// Arabic: الخلفية الثانوية المستخدمة لخلق عمق بصري.
  /// English: Secondary background used to create visual depth.
  static Color get darkBackground2 =>
      isDark ? const Color(0xFF0E1E33) : const Color(0xFFF0F5FF);

  /// Arabic: الخلفية الثالثة المستخدمة في التدرجات الكبيرة.
  /// English: Third background tone used in larger gradients.
  static Color get darkBackground3 =>
      isDark ? const Color(0xFF112240) : const Color(0xFFE8F0FF);

  /// Arabic: لون سطح البطاقات والحاويات الرئيسية.
  /// English: Main surface color for cards and containers.
  static Color get darkSurface =>
      isDark ? const Color(0xFF152642) : const Color(0xFFFFFFFF);

  /// Arabic: لون البطاقة الأساسي في الثيم الحالي.
  /// English: Default card color in the active theme.
  static Color get darkCard =>
      isDark ? const Color(0xFF1A2F4E) : const Color(0xFFFFFFFF);

  /// Arabic: لون الحدود المستخدمة حول الأسطح والعناصر.
  /// English: Border color used around surfaces and components.
  static Color get darkBorder =>
      isDark ? const Color(0xFF253859) : const Color(0xFFD4E0F5);

  /// Arabic: خلفية فاتحة مخصصة للاستخدام العام في الوضع الحالي.
  /// English: Light background token used for general surfaces in the current theme.
  static Color get lightBackground =>
      isDark ? const Color(0xFFF7FAFF) : const Color(0xFFF9FBFF);

  /// Arabic: سطح فاتح نظيف للحاويات الداخلية.
  /// English: Clean light surface for inner containers.
  static Color get lightSurface =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  /// Arabic: لون البطاقة الفاتح.
  /// English: Light card color.
  static Color get lightCard =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  /// Arabic: حدود فاتحة أكثر هدوءًا للعناصر في الوضع الحالي.
  /// English: Softer light border used by the active theme.
  static Color get lightBorder =>
      isDark ? const Color(0xFFE2ECFF) : const Color(0xFFD9E3F5);

  /// Arabic: نص أبيض ثابت للاستخدامات التي تحتاج نفس اللون في كلا الوضعين.
  /// English: Always-light text color used when the foreground must remain unchanged.
  static Color get textWhiteAlways =>
      isDark ? const Color(0xFFF0F5FF) : const Color(0xFFF0F5FF);

  /// Arabic: لون النص الأساسي وفق الثيم الحالي.
  /// English: Primary text color resolved from the active theme.
  static Color get textWhite =>
      isDark ? const Color(0xFFF0F5FF) : const Color(0xFF0F172A);

  /// Arabic: لون النص المساند أو الثانوي.
  /// English: Supporting text color used for secondary copy.
  static Color get textLight =>
      isDark ? const Color(0xFFB4C6E0) : const Color(0xFF334155);

  /// Arabic: لون النص المخفف أو الوصفي.
  /// English: Muted text color used for descriptions and captions.
  static Color get textMuted =>
      isDark ? const Color(0xFF8094B3) : const Color(0xFF64748B);

  /// Arabic: لون النص الداكن المخصص للعناصر عالية التباين.
  /// English: Dark text color used for high-contrast foreground content.
  static Color get textDark =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFF020617);

  /// Arabic: لون الزجاج الداكن الخفيف للطبقات العلوية.
  /// English: Soft dark glass tone for elevated layers.
  static Color get glassDark =>
      isDark ? const Color(0x1A0B1929) : const Color(0x08000000);

  /// Arabic: لون زجاجي ملون بخفة للحواف أو الخلفيات الشفافة.
  /// English: Slightly tinted glass tone for translucent backgrounds and edges.
  static Color get glassLight =>
      isDark ? const Color(0x0DF0F5FF) : const Color(0x0F3260CC);

  /// Arabic: طبقة زجاجية شبه شفافة فوق المحتوى.
  /// English: Semi-transparent glass overlay placed above content.
  static Color get glassOverlay =>
      isDark ? const Color(0x80152642) : const Color(0x66FFFFFF);

  /// Arabic: زجاج مصنفر يمنح اللوحات مظهرًا أكثر فخامة.
  /// English: Frosted glass tone that gives panels a premium look.
  static Color get frostedGlass =>
      isDark ? const Color(0x30F0F5FF) : const Color(0x99F9FBFF);

  /// Arabic: لون النجاح المتوافق مع وضع الثيم الحالي.
  /// English: Success color adapted to the active theme.
  static Color get success =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

  /// Arabic: لون التحذير المتوافق مع وضع الثيم الحالي.
  /// English: Warning color adapted to the active theme.
  static Color get warning =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

  /// Arabic: لون الخطأ المتوافق مع وضع الثيم الحالي.
  /// English: Error color adapted to the active theme.
  static Color get error =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  /// Arabic: لون المعلومات المتوافق مع وضع الثيم الحالي.
  /// English: Information color adapted to the active theme.
  static Color get info =>
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

  /// Arabic: الظل الداكن المستخدم للعمق والارتفاع.
  /// English: Dark shadow used to communicate depth and elevation.
  static Color get shadowDark =>
      isDark ? const Color(0x40000000) : const Color(0x0A000000);

  /// Arabic: الظل الملون الخفيف المتوافق مع الهوية البصرية.
  /// English: Light colored shadow aligned with the brand palette.
  static Color get shadowLight =>
      isDark ? const Color(0x1A5B8DEE) : const Color(0x053260CC);

  /// Arabic: طبقة التعتيم الداكنة المستخدمة فوق الخلفيات.
  /// English: Dark overlay used above backgrounds for contrast.
  static Color get overlayDark =>
      isDark ? const Color(0xCC0B1929) : const Color(0x0A0F172A);

  /// Arabic: طبقة التعتيم الفاتحة المستخدمة فوق الصور أو المحتوى.
  /// English: Light overlay used above images or content.
  static Color get overlayLight =>
      isDark ? const Color(0x99F0F5FF) : const Color(0xE6FFFFFF);

  /// Arabic: التدرج الأساسي المستعمل في الخلفيات والشعارات والبطاقات المميزة.
  /// English: Primary gradient used in backgrounds, logos, and featured surfaces.
  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF4A9FFF), // أزرق فاتح
                const Color(0xFF5B8DEE), // أزرق متوسط
                const Color(0xFF7C6FD8), // بنفسجي متوسط
                const Color(0xFF9D7FE8), // بنفسجي فاتح
              ]
            : [
                const Color(0xFF2E7DD4),
                const Color(0xFF3260CC),
                const Color(0xFF5E52B8),
                const Color(0xFF7B5FCF),
              ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      );

  /// Arabic: تدرج الخلفية الرئيسي الذي يحدد المزاج العام للشاشة.
  /// English: Main background gradient that defines the overall page mood.
  static LinearGradient get darkGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1929), // أزرق غامق جداً
            Color(0xFF0E1E33), // أزرق غامق
            Color(0xFF112240), // أزرق متوسط غامق
          ],
          stops: [0.0, 0.5, 1.0],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FAFF),
            Color(0xFFF0F5FF),
            Color(0xFFE8F0FF),
          ],
          stops: [0.0, 0.5, 1.0],
        );

  /// Arabic: تدرج البطاقات الذي يمنح الأسطح لمسة لونية شفافة.
  /// English: Card gradient that gives surfaces a translucent color wash.
  static LinearGradient get cardGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1A5B8DEE), // أزرق شفاف
            Color(0x0D7C6FD8), // بنفسجي شفاف
            Color(0x1A9D7FE8), // بنفسجي فاتح شفاف
          ],
          stops: [0.0, 0.5, 1.0],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x053260CC),
            Color(0x035E52B8),
            Color(0x057B5FCF),
          ],
          stops: [0.0, 0.5, 1.0],
        );

  /// Arabic: تدرج النيون المستخدم في العناصر اللافتة.
  /// English: Neon gradient used for standout visual elements.
  static LinearGradient get neonGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF6BB6FF), // أزرق نيون
                const Color(0xFFA78BFA), // بنفسجي نيون
                const Color(0xFF5EEAD4), // أخضر مائي نيون
              ]
            : [
                const Color(0xFF4A9FFF),
                const Color(0xFF8B6FE3),
                const Color(0xFF14B8A6),
              ],
      );

  /// Arabic: تدرج الزجاج المستخدم في الطبقات الشفافة.
  /// English: Glass gradient used for translucent layers.
  static LinearGradient get glassGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x40F0F5FF), // أبيض شفاف
            Color(0x1AF0F5FF),
            Color(0x40F0F5FF),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x0DFFFFFF),
            Color(0x08FFFFFF),
            Color(0x0DFFFFFF),
          ],
        );

  /// Arabic: تدرج التوهج المستخدم حول النقاط أو الأيقونات المهمة.
  /// English: Glow gradient used around important points or icons.
  static RadialGradient get glowGradient => isDark
      ? const RadialGradient(
          colors: [
            Color(0x805B8DEE), // مركز التوهج
            Color(0x405B8DEE), // وسط التوهج
            Color(0x005B8DEE), // حافة التوهج
          ],
        )
      : const RadialGradient(
          colors: [
            Color(0x1A3260CC),
            Color(0x0D3260CC),
            Color(0x003260CC),
          ],
        );

  /// Arabic: لون الزر الأساسي المشتق من اللون الرئيسي.
  /// English: Primary button color derived from the main brand tone.
  static Color get buttonPrimary => primaryBlue;

  /// Arabic: لون الزر الثانوي المشتق من اللون البنفسجي الرئيسي.
  /// English: Secondary button color derived from the main purple tone.
  static Color get buttonSecondary => primaryPurple;

  /// Arabic: لون خلفية حقول الإدخال حسب وضع الثيم.
  /// English: Input field background color resolved from the current theme.
  static Color get inputBackground =>
      isDark ? const Color(0x0D5B8DEE) : const Color(0xFFE8F0FF);

  /// Arabic: لون حدود حقول الإدخال في الوضع الحالي.
  /// English: Input border color resolved from the current theme.
  static Color get inputBorder =>
      isDark ? const Color(0x335B8DEE) : const Color(0xFFD4E0F5);

  /// Arabic: لون حدود الحقول عند التركيز.
  /// English: Focus border color for input fields.
  static Color get inputFocusBorder => primaryBlue;

  /// Arabic: قاعدة تأثير اللمعان المستخدمة في العناصر المادية والخفيفة.
  /// English: Base shimmer color used in loading and polish effects.
  static Color get shimmerBase =>
      primaryBlue.withValues(alpha: isDark ? 0.08 : 0.04);

  /// Arabic: طبقة اللمعان الأوضح أثناء حركة الشيمر.
  /// English: Brighter shimmer layer used during the sweep animation.
  static Color get shimmerHighlight =>
      primaryBlue.withValues(alpha: isDark ? 0.25 : 0.10);

  /// Arabic: لون التأثير الهولوجرافي الخفيف في الأسطح المميزة.
  /// English: Soft holographic tint used on featured surfaces.
  static Color get holographic =>
      primaryPurple.withValues(alpha: isDark ? 0.35 : 0.12);

  /// Arabic: لون حالة الحجز المعلّق.
  /// English: Pending booking color.
  static Color get bookingPending =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

  /// Arabic: لون حالة الحجز المؤكد.
  /// English: Confirmed booking color.
  static Color get bookingConfirmed =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

  /// Arabic: لون حالة الحجز الملغى.
  /// English: Cancelled booking color.
  static Color get bookingCancelled =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  /// Arabic: لون حالة الحجز المكتمل.
  /// English: Completed booking color.
  static Color get bookingCompleted =>
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

  /// Arabic: اسم قديم متوافق يشير إلى ظل الثيم.
  /// English: Backward-compatible alias for the theme shadow color.
  static Color get shadow => shadowDark;

  /// Arabic: اللون الداكن القديم الأساسي المستخدم في بعض الأجزاء القديمة.
  /// English: Legacy primary-dark color retained for older references.
  static Color get primaryDark =>
      isDark ? const Color(0xFF0E1E33) : const Color(0xFF1E3A8A);

  /// Arabic: لون شفاف كامل متوافق مع استدعاءات سابقة.
  /// English: Fully transparent color kept for older call sites.
  static const Color transparent = Colors.transparent;

  /// Arabic: اسم قديم لرمادي فاتح يُستخدم في حدود وواجهات قديمة.
  /// English: Legacy light gray alias used by older widgets.
  static Color get gray200 => lightBorder;

  /// Arabic: اسم قديم للنص المعطل.
  /// English: Legacy alias for disabled text color.
  static Color get textDisabled => textMuted;

  /// Arabic: اسم قديم لقاعدة اللمعان.
  /// English: Legacy alias for shimmer base color.
  static Color get shimmer =>
      isDark ? const Color(0xFF253859) : const Color(0xFFF3F6FB);
}
