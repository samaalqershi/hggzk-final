import 'package:flutter/material.dart';

/// Central palette for the application theme, including brand colors, status
/// colors, glass effects, and gradients reused across the UI system.
/// اللوحة اللونية المركزية للتطبيق، وتشمل ألوان الهوية والحالات والتأثيرات
/// الزجاجية والتدرجات المعاد استخدامها عبر نظام الواجهة.
class AppColors {
  /// Private constructor because this class only exposes shared constants and
  /// computed color helpers.
  /// مُنشئ خاص لأن هذا الصنف يقدّم ثوابت مشتركة ودوال لونية مشتقة فقط.
  AppColors._();

  // 🎨 Primary Gradient Colors (ألوان متدرجة احترافية)
  static const Color primaryBlue = Color(0xFF0066CC); // أزرق IBM احترافي
  static const Color primaryPurple = Color(0xFF6366F1); // بنفسجي Indigo 500
  static const Color primaryViolet = Color(0xFF8B5CF6); // بنفسجي Violet 500
  static const Color primaryCyan = Color(0xFF0891B2); // سماوي Cyan 600

  // 🌟 Neon & Glow Colors (ألوان نابضة بالحياة)
  static const Color neonBlue = Color(0xFF0EA5E9); // Sky 500
  static const Color neonPurple = Color(0xFFA855F7); // Purple 500
  static const Color neonGreen = Color(0xFF10B981); // Emerald 500
  static const Color glowBlue = Color(0xFF3B82F6); // Blue 500
  static const Color glowWhite = Color(0xFFFAFAFA); // Neutral 50

  // 🌙 Dark Theme Base Colors (محولة للوضع الفاتح)
  static const Color darkBackground = Color(0xFFFAFAFA); // خلفية Neutral 50
  static const Color darkBackground2 = Color(0xFFFAFAFA); // اللون الثاني للتدرج
  static const Color darkBackground3 = Color(0xFFFAFAFA); // اللون الثالث للتدرج
  static const Color darkSurface = Color(0xFFFFFFFF); // سطح أبيض نقي
  static const Color darkCard = Color(0xFFFFFFFF); // كارد أبيض
  static const Color darkBorder = Color(0xFFE5E5E5); // Neutral 200

  // ☀️ Light Theme Base Colors
  static const Color lightBackground = Color(0xFFF9FAFB); // Gray 50
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightCard = Color(0xFFFFFFFF); // White
  static const Color lightBorder = Color(0xFFE5E7EB); // Gray 200

  // 📝 Text Colors (نظام نصوص احترافي)
  static const Color textWhite = Color(0xFF111827); // Gray 900
  static const Color textLight = Color(0xFF374151); // Gray 700
  static const Color textMuted = Color(0xFF6B7280); // Gray 500
  static const Color textDark = Color(0xFF030712); // Gray 950

  // ✨ Glass & Blur Effects (تأثيرات زجاجية عصرية)
  static const Color glassDark = Color(0x08000000); // شفافية خفيفة جداً
  static const Color glassLight = Color(0x0F0066CC); // زجاج أزرق خفيف
  static const Color glassOverlay = Color(0x66FFFFFF); // طبقة بيضاء
  static const Color frostedGlass = Color(0x99F9FAFB); // زجاج مصنفر

  // 🚦 Status Colors (ألوان حالة Material 3)
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color info = Color(0xFF0284C7); // Sky 600

  // 🎭 Shadows & Overlays (ظلال احترافية ناعمة)
  static const Color shadowDark = Color(0x0A000000); // 4% أسود
  static const Color shadowLight = Color(0x050066CC); // ظل أزرق خفيف جداً
  static const Color overlayDark = Color(0x0A111827); // طبقة داكنة خفيفة
  static const Color overlayLight = Color(0xE6FFFFFF); // طبقة بيضاء

  // 🌈 Gradient Definitions (تدرجات احترافية)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCyan, primaryBlue, primaryPurple, primaryViolet],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FAFB), Color(0xFFFAFAFA)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x050066CC), // أزرق شفاف جداً
      Color(0x036366F1), // بنفسجي شفاف جداً
      Color(0x058B5CF6), // violet شفاف جداً
    ],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, neonPurple, neonGreen],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0DFFFFFF), // أبيض شفاف
      Color(0x08FFFFFF), // أبيض شفاف جداً
      Color(0x0DFFFFFF), // أبيض شفاف
    ],
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x1A0066CC), // مركز أزرق خفيف
      Color(0x0D0066CC), // وسط
      Color(0x000066CC), // حافة شفافة
    ],
  );

  // 🎯 Component Specific Colors
  static const Color buttonPrimary = primaryBlue; // زر أساسي
  static const Color buttonSecondary = primaryPurple; // زر ثانوي
  static const Color inputBackground = Color(0xFFF3F4F6); // Gray 100
  static const Color inputBorder = Color(0xFFD1D5DB); // Gray 300
  static const Color inputFocusBorder = primaryBlue; // حدود التركيز

  // 💎 Special Effects
  static Color shimmerBase = primaryBlue.withOpacity(0.03); // قاعدة التلألؤ
  static Color shimmerHighlight =
      primaryBlue.withOpacity(0.08); // إضاءة التلألؤ
  static Color holographic = primaryPurple.withOpacity(0.1); // تأثير هولوجرام

  // 🔲 Booking Status (ألوان حالات الحجز)
  static const Color bookingPending = Color(0xFFF59E0B); // Amber 500
  static const Color bookingConfirmed = Color(0xFF059669); // Emerald 600
  static const Color bookingCancelled = Color(0xFFDC2626); // Red 600
  static const Color bookingCompleted = Color(0xFF0284C7); // Sky 600

  // 🔁 Backward-compatible aliases (for legacy references)
  static const Color shadow = shadowDark; // Legacy: AppColors.shadow
  static const Color primaryDark = Color(0xFF003D7A); // نسخة داكنة من الأساسي
  static const Color transparent =
      Colors.transparent; // Legacy: AppColors.transparent
  static const Color gray200 = lightBorder; // Legacy neutral gray
  static const Color textDisabled = textMuted; // Legacy disabled text
  static const Color shimmer = Color(0xFFF3F4F6); // Legacy shimmer base
}
