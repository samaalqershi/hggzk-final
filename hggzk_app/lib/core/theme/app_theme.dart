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
  /// Initializes the active theme mode and brightness without depending on
  /// inherited widgets from the caller context.
  /// العربية: يهيئ وضع السمة والسطوع النشطين دون الاعتماد على عناصر inherited.
  static void init({
    ThemeMode? mode,
    Brightness? systemBrightness,
  }) {
    _themeMode = mode ?? ThemeMode.system;
    final resolvedSystemBrightness = systemBrightness ?? Brightness.dark;

    if (_themeMode == ThemeMode.system) {
      _brightness = resolvedSystemBrightness;
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
  static Color get primaryBlue =>
      isDark ? const Color(0xFF38BDF8) : const Color(0xFF0EA5E9);

  /// Exposes the `primaryPurple` value for callers that need it.
  /// العربية: يعيد القيمة `primaryPurple`.
  static Color get primaryPurple =>
      isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488);

  /// Exposes the `primaryViolet` value for callers that need it.
  /// العربية: يعيد القيمة `primaryViolet`.
  static Color get primaryViolet =>
      isDark ? const Color(0xFF10B981) : const Color(0xFF059669);

  /// Exposes the `primaryCyan` value for callers that need it.
  /// العربية: يعيد القيمة `primaryCyan`.
  static Color get primaryCyan =>
      isDark ? const Color(0xFF22D3EE) : const Color(0xFF06B6D4);

  // 🌟 Neon & Glow Colors
  /// Exposes the `neonBlue` value for callers that need it.
  /// العربية: يعيد القيمة `neonBlue`.
  static Color get neonBlue =>
      isDark ? const Color(0xFF0EA5E9) : const Color(0xFF0369A1);

  /// Exposes the `neonPurple` value for callers that need it.
  /// العربية: يعيد القيمة `neonPurple`.
  static Color get neonPurple =>
      isDark ? const Color(0xFF2DD4BF) : const Color(0xFF14B8A6);

  /// Exposes the `neonGreen` value for callers that need it.
  /// العربية: يعيد القيمة `neonGreen`.
  static Color get neonGreen =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);

  /// Exposes the `glowBlue` value for callers that need it.
  /// العربية: يعيد القيمة `glowBlue`.
  static Color get glowBlue =>
      isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);

  /// Exposes the `glowWhite` value for callers that need it.
  /// العربية: يعيد القيمة `glowWhite`.
  static Color get glowWhite =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFAFAFA);

  // 🌙 Base Colors
  /// Exposes the `darkBackground` value for callers that need it.
  /// العربية: يعيد القيمة `darkBackground`.
  static Color get darkBackground =>
      isDark ? const Color(0xFF020617) : const Color(0xFFF9FAFB);

  /// Exposes the `darkBackground2` value for callers that need it.
  /// العربية: يعيد القيمة `darkBackground2`.
  static Color get darkBackground2 =>
      isDark ? const Color(0xFF020617) : const Color(0xFFF3F4F6);

  /// Exposes the `darkBackground3` value for callers that need it.
  /// العربية: يعيد القيمة `darkBackground3`.
  static Color get darkBackground3 =>
      isDark ? const Color(0xFF020617) : const Color(0xFFE5E7EB);

  /// Exposes the `darkSurface` value for callers that need it.
  /// العربية: يعيد القيمة `darkSurface`.
  static Color get darkSurface =>
      isDark ? const Color(0xFF020617) : const Color(0xFFFFFFFF);

  /// Exposes the `darkCard` value for callers that need it.
  /// العربية: يعيد القيمة `darkCard`.
  static Color get darkCard =>
      isDark ? const Color(0xFF020617) : const Color(0xFFFFFFFF);

  /// Exposes the `darkBorder` value for callers that need it.
  /// العربية: يعيد القيمة `darkBorder`.
  static Color get darkBorder =>
      isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E5EB);

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
      isDark ? const Color(0xFFF9FAFB) : const Color(0xFF020617);

  /// Exposes the `textLight` value for callers that need it.
  /// العربية: يعيد القيمة `textLight`.
  static Color get textLight =>
      isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151);

  /// Exposes the `textMuted` value for callers that need it.
  /// العربية: يعيد القيمة `textMuted`.
  static Color get textMuted =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  /// Exposes the `textDark` value for callers that need it.
  /// العربية: يعيد القيمة `textDark`.
  static Color get textDark =>
      isDark ? const Color(0xFF020617) : const Color(0xFF020617);

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
      isDark ? const Color(0xFF00D4FF) : const Color(0xFF0284C7);

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
        colors: [
          primaryBlue,
          primaryCyan,
          primaryCyan,
          primaryPurple,
        ],
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
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.1),
            primaryPurple.withOpacity(0.05),
            primaryViolet.withOpacity(0.1),
          ],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.02),
            primaryPurple.withOpacity(0.015),
            primaryViolet.withOpacity(0.02),
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
      ? RadialGradient(
          colors: [
            primaryBlue.withOpacity(0.5),
            primaryPurple.withOpacity(0.25),
            Colors.transparent,
          ],
        )
      : RadialGradient(
          colors: [
            primaryBlue.withOpacity(0.1),
            primaryPurple.withOpacity(0.05),
            Colors.transparent,
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
