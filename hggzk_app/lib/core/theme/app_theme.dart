// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// 🎨 Unified Theme System - نظام ثيم موحد
class AppTheme {
  /// Builds the `AppTheme._` instance used by this layer.
  /// العربية: ينشئ مثيلًا جديدًا من `AppTheme._`.
  AppTheme._();

  // Current theme mode
  /// Keeps the `themeMode` value so this type can use it later.
  /// العربية: يخزن القيمة `themeMode`.
  static ThemeMode _themeMode = ThemeMode.system;

  /// Exposes the `themeMode` value for callers that need it.
  /// العربية: يعيد القيمة `themeMode`.
  static ThemeMode get themeMode => _themeMode;

  // Track current brightness
  /// Keeps the `brightness` value so this type can use it later.
  /// العربية: يخزن القيمة `brightness`.
  static Brightness _brightness = Brightness.dark;

  /// Exposes the `brightness` value for callers that need it.
  /// العربية: يعيد القيمة `brightness`.
  static Brightness get brightness => _brightness;

  // Initialize theme based on system or manual setting
  /// Initializes the active theme mode and brightness for the current context.
  /// العربية: يهيئ وضع السمة والسطوع النشطين للسياق الحالي.
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

  // Helper method to check if dark mode
  /// Exposes the `isDark` value for callers that need it.
  /// العربية: يعيد القيمة `isDark`.
  static bool get isDark => _brightness == Brightness.dark;

  // 🎨 Primary Gradient Colors
  /// Exposes the `primaryBlue` value for callers that need it.
  /// العربية: يعيد القيمة `primaryBlue`.
  static Color get primaryBlue => isDark
      ? const Color.fromARGB(255, 79, 169, 254)
      : const Color(0xFF0066CC);

  /// Exposes the `primaryPurple` value for callers that need it.
  /// العربية: يعيد القيمة `primaryPurple`.
  static Color get primaryPurple =>
      isDark ? const Color(0xFF667EEA) : const Color(0xFF6366F1);

  /// Exposes the `primaryViolet` value for callers that need it.
  /// العربية: يعيد القيمة `primaryViolet`.
  static Color get primaryViolet =>
      isDark ? const Color(0xFF764BA2) : const Color(0xFF8B5CF6);

  /// Exposes the `primaryCyan` value for callers that need it.
  /// العربية: يعيد القيمة `primaryCyan`.
  static Color get primaryCyan =>
      isDark ? const Color.fromARGB(255, 0, 161, 254) : const Color(0xFF0891B2);

  // 🌟 Neon & Glow Colors
  /// Exposes the `neonBlue` value for callers that need it.
  /// العربية: يعيد القيمة `neonBlue`.
  static Color get neonBlue =>
      isDark ? const Color.fromARGB(255, 0, 174, 255) : const Color(0xFF0EA5E9);

  /// Exposes the `neonPurple` value for callers that need it.
  /// العربية: يعيد القيمة `neonPurple`.
  static Color get neonPurple =>
      isDark ? const Color(0xFF9D50FF) : const Color(0xFFA855F7);

  /// Exposes the `neonGreen` value for callers that need it.
  /// العربية: يعيد القيمة `neonGreen`.
  static Color get neonGreen =>
      isDark ? const Color(0xFF00FF88) : const Color(0xFF10B981);

  /// Exposes the `glowBlue` value for callers that need it.
  /// العربية: يعيد القيمة `glowBlue`.
  static Color get glowBlue =>
      isDark ? const Color(0xFF4FACFE) : const Color(0xFF3B82F6);

  /// Exposes the `glowWhite` value for callers that need it.
  /// العربية: يعيد القيمة `glowWhite`.
  static Color get glowWhite =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFAFAFA);

  // 🌙 Base Colors
  /// Exposes the `darkBackground` value for callers that need it.
  /// العربية: يعيد القيمة `darkBackground`.
  static Color get darkBackground =>
      isDark ? const Color(0xFF0A0E27) : const Color(0xFFFAFAFA);

  /// Exposes the `darkBackground2` value for callers that need it.
  /// العربية: يعيد القيمة `darkBackground2`.
  static Color get darkBackground2 =>
      isDark ? const Color(0xFF0F1629) : const Color(0xFFFAFAFA);

  /// Exposes the `darkBackground3` value for callers that need it.
  /// العربية: يعيد القيمة `darkBackground3`.
  static Color get darkBackground3 =>
      isDark ? const Color(0xFF1A0E3D) : const Color(0xFFFAFAFA);

  // static Color get darkBackground => isDark ? const Color(0xFF0A0E27) : const Color(0xFFFAFBFF);
  // static Color get darkBackground2 => isDark ? const Color(0xFF0D1332) : const Color(0xFFF5F7FE);
  // static Color get darkBackground3 => isDark ? const Color(0xFF11183F) : const Color(0xFFF0F3FD);

  // static Color get darkBackground => isDark ? const Color(0xFF0A0E27) : const Color(0xFFF0F4FF);
  // static Color get darkBackground2 => isDark ? const Color(0xFF1A1547) : const Color(0xFFE8EFFF);
  // static Color get darkBackground3 => isDark ? const Color(0xFF2D1B69) : const Color(0xFFE0E8FF);

  /// Exposes the `darkSurface` value for callers that need it.
  /// العربية: يعيد القيمة `darkSurface`.
  static Color get darkSurface =>
      isDark ? const Color(0xFF151930) : const Color(0xFFFFFFFF);

  /// Exposes the `darkCard` value for callers that need it.
  /// العربية: يعيد القيمة `darkCard`.
  static Color get darkCard =>
      isDark ? const Color(0xFF1E2341) : const Color(0xFFFFFFFF);

  /// Exposes the `darkBorder` value for callers that need it.
  /// العربية: يعيد القيمة `darkBorder`.
  static Color get darkBorder =>
      isDark ? const Color(0xFF2A3050) : const Color(0xFFE5E5E5);

  // ☀️ Light Theme Base Colors
  /// Exposes the `lightBackground` value for callers that need it.
  /// العربية: يعيد القيمة `lightBackground`.
  static Color get lightBackground =>
      isDark ? const Color(0xFFF8FAFF) : const Color(0xFFF9FAFB);

  /// Exposes the `lightSurface` value for callers that need it.
  /// العربية: يعيد القيمة `lightSurface`.
  static Color get lightSurface =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  /// Exposes the `lightCard` value for callers that need it.
  /// العربية: يعيد القيمة `lightCard`.
  static Color get lightCard =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  /// Exposes the `lightBorder` value for callers that need it.
  /// العربية: يعيد القيمة `lightBorder`.
  static Color get lightBorder =>
      isDark ? const Color(0xFFE8ECFA) : const Color(0xFFE5E7EB);

  // 📝 Text Colors
  /// Exposes the `textWhite` value for callers that need it.
  /// العربية: يعيد القيمة `textWhite`.
  static Color get textWhite =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111827);

  /// Exposes the `textLight` value for callers that need it.
  /// العربية: يعيد القيمة `textLight`.
  static Color get textLight =>
      isDark ? const Color(0xFFB8C4E6) : const Color(0xFF374151);

  /// Exposes the `textMuted` value for callers that need it.
  /// العربية: يعيد القيمة `textMuted`.
  static Color get textMuted =>
      isDark ? const Color(0xFF8B95B7) : const Color(0xFF6B7280);

  /// Exposes the `textDark` value for callers that need it.
  /// العربية: يعيد القيمة `textDark`.
  static Color get textDark =>
      isDark ? const Color(0xFF1A1F36) : const Color(0xFF030712);

  // ✨ Glass & Blur Effects
  /// Exposes the `glassDark` value for callers that need it.
  /// العربية: يعيد القيمة `glassDark`.
  static Color get glassDark =>
      isDark ? const Color(0x1A000000) : const Color(0x08000000);

  /// Exposes the `glassLight` value for callers that need it.
  /// العربية: يعيد القيمة `glassLight`.
  static Color get glassLight =>
      isDark ? const Color(0x0DFFFFFF) : const Color(0x0F0066CC);

  /// Exposes the `glassOverlay` value for callers that need it.
  /// العربية: يعيد القيمة `glassOverlay`.
  static Color get glassOverlay =>
      isDark ? const Color(0x80151930) : const Color(0x66FFFFFF);

  /// Exposes the `frostedGlass` value for callers that need it.
  /// العربية: يعيد القيمة `frostedGlass`.
  static Color get frostedGlass =>
      isDark ? const Color(0x30FFFFFF) : const Color(0x99F9FAFB);

  // 🚦 Status Colors
  /// Exposes the `success` value for callers that need it.
  /// العربية: يعيد القيمة `success`.
  static Color get success =>
      isDark ? const Color(0xFF00FF88) : const Color(0xFF059669);

  /// Exposes the `warning` value for callers that need it.
  /// العربية: يعيد القيمة `warning`.
  static Color get warning =>
      isDark ? const Color(0xFFFFB800) : const Color(0xFFF59E0B);

  /// Exposes the `error` value for callers that need it.
  /// العربية: يعيد القيمة `error`.
  static Color get error =>
      isDark ? const Color(0xFFFF3366) : const Color(0xFFDC2626);

  /// Exposes the `info` value for callers that need it.
  /// العربية: يعيد القيمة `info`.
  static Color get info =>
      isDark ? const Color.fromARGB(255, 0, 183, 255) : const Color(0xFF0284C7);

  // 🎭 Shadows & Overlays
  /// Exposes the `shadowDark` value for callers that need it.
  /// العربية: يعيد القيمة `shadowDark`.
  static Color get shadowDark =>
      isDark ? const Color(0x40000000) : const Color(0x0A000000);

  /// Exposes the `shadowLight` value for callers that need it.
  /// العربية: يعيد القيمة `shadowLight`.
  static Color get shadowLight =>
      isDark ? const Color(0x1A4FACFE) : const Color(0x050066CC);

  /// Exposes the `overlayDark` value for callers that need it.
  /// العربية: يعيد القيمة `overlayDark`.
  static Color get overlayDark =>
      isDark ? const Color(0xCC0A0E27) : const Color(0x0A111827);

  /// Exposes the `overlayLight` value for callers that need it.
  /// العربية: يعيد القيمة `overlayLight`.
  static Color get overlayLight =>
      isDark ? const Color(0x99FFFFFF) : const Color(0xE6FFFFFF);

  // 🌈 Gradient Definitions
  /// Exposes the `primaryGradient` value for callers that need it.
  /// العربية: يعيد القيمة `primaryGradient`.
  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryCyan, primaryBlue, primaryPurple, primaryViolet],
        stops: const [0.0, 0.3, 0.6, 1.0],
      );

  /// Exposes the `darkGradient` value for callers that need it.
  /// العربية: يعيد القيمة `darkGradient`.
  static LinearGradient get darkGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F36), Color(0xFF0F1629)],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FAFB), Color(0xFFFAFAFA)],
        );

  /// Exposes the `cardGradient` value for callers that need it.
  /// العربية: يعيد القيمة `cardGradient`.
  static LinearGradient get cardGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1A4FACFE),
            Color(0x0D667EEA),
            Color(0x1A764BA2),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x050066CC),
            Color(0x036366F1),
            Color(0x058B5CF6),
          ],
        );

  /// Exposes the `neonGradient` value for callers that need it.
  /// العربية: يعيد القيمة `neonGradient`.
  static LinearGradient get neonGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [neonBlue, neonPurple, neonGreen],
      );

  /// Exposes the `glassGradient` value for callers that need it.
  /// العربية: يعيد القيمة `glassGradient`.
  static LinearGradient get glassGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x40FFFFFF),
            Color(0x1AFFFFFF),
            Color(0x40FFFFFF),
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

  /// Exposes the `glowGradient` value for callers that need it.
  /// العربية: يعيد القيمة `glowGradient`.
  static RadialGradient get glowGradient => isDark
      ? const RadialGradient(
          colors: [
            Color(0x804FACFE),
            Color(0x404FACFE),
            Color(0x004FACFE),
          ],
        )
      : const RadialGradient(
          colors: [
            Color(0x1A0066CC),
            Color(0x0D0066CC),
            Color(0x000066CC),
          ],
        );

  // 🎯 Component Specific Colors
  /// Exposes the `buttonPrimary` value for callers that need it.
  /// العربية: يعيد القيمة `buttonPrimary`.
  static Color get buttonPrimary => primaryBlue;

  /// Exposes the `buttonSecondary` value for callers that need it.
  /// العربية: يعيد القيمة `buttonSecondary`.
  static Color get buttonSecondary => primaryPurple;

  /// Exposes the `inputBackground` value for callers that need it.
  /// العربية: يعيد القيمة `inputBackground`.
  static Color get inputBackground =>
      isDark ? const Color(0x0D4FACFE) : const Color(0xFFF3F4F6);

  /// Exposes the `inputBorder` value for callers that need it.
  /// العربية: يعيد القيمة `inputBorder`.
  static Color get inputBorder =>
      isDark ? const Color(0x334FACFE) : const Color(0xFFD1D5DB);

  /// Exposes the `inputFocusBorder` value for callers that need it.
  /// العربية: يعيد القيمة `inputFocusBorder`.
  static Color get inputFocusBorder => primaryBlue;

  // 💎 Special Effects
  /// Exposes the `shimmerBase` value for callers that need it.
  /// العربية: يعيد القيمة `shimmerBase`.
  static Color get shimmerBase => primaryBlue.withOpacity(isDark ? 0.05 : 0.03);

  /// Exposes the `shimmerHighlight` value for callers that need it.
  /// العربية: يعيد القيمة `shimmerHighlight`.
  static Color get shimmerHighlight =>
      primaryBlue.withOpacity(isDark ? 0.2 : 0.08);

  /// Exposes the `holographic` value for callers that need it.
  /// العربية: يعيد القيمة `holographic`.
  static Color get holographic => primaryPurple.withOpacity(isDark ? 0.3 : 0.1);

  // 🔲 Booking Status
  /// Exposes the `bookingPending` value for callers that need it.
  /// العربية: يعيد القيمة `bookingPending`.
  static Color get bookingPending =>
      isDark ? const Color(0xFFFFB800) : const Color(0xFFF59E0B);

  /// Exposes the `bookingConfirmed` value for callers that need it.
  /// العربية: يعيد القيمة `bookingConfirmed`.
  static Color get bookingConfirmed =>
      isDark ? const Color(0xFF00FF88) : const Color(0xFF059669);

  /// Exposes the `bookingCancelled` value for callers that need it.
  /// العربية: يعيد القيمة `bookingCancelled`.
  static Color get bookingCancelled =>
      isDark ? const Color(0xFFFF3366) : const Color(0xFFDC2626);

  /// Exposes the `bookingCompleted` value for callers that need it.
  /// العربية: يعيد القيمة `bookingCompleted`.
  static Color get bookingCompleted =>
      isDark ? const Color(0xFF00D4FF) : const Color(0xFF0284C7);

  // 🔁 Backward-compatible aliases
  /// Exposes the `shadow` value for callers that need it.
  /// العربية: يعيد القيمة `shadow`.
  static Color get shadow => shadowDark;

  /// Exposes the `primaryDark` value for callers that need it.
  /// العربية: يعيد القيمة `primaryDark`.
  static Color get primaryDark =>
      isDark ? const Color(0xFF0F1629) : const Color(0xFF003D7A);

  /// Keeps the `transparent` value so this type can use it later.
  /// العربية: يخزن القيمة `transparent`.
  static const Color transparent = Colors.transparent;

  /// Exposes the `gray200` value for callers that need it.
  /// العربية: يعيد القيمة `gray200`.
  static Color get gray200 => lightBorder;

  /// Exposes the `textDisabled` value for callers that need it.
  /// العربية: يعيد القيمة `textDisabled`.
  static Color get textDisabled => textMuted;

  /// Exposes the `shimmer` value for callers that need it.
  /// العربية: يعيد القيمة `shimmer`.
  static Color get shimmer =>
      isDark ? const Color(0xFF2A3050) : const Color(0xFFF3F4F6);
}
