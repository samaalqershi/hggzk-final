import 'package:flutter/material.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // 🎯 نظام أحجام شامل ومرن
  static const Map<String, double> fontSizes = {
    'display1': 56, // للعناوين الضخمة (الصفحة الرئيسية)
    'display2': 48, // للعناوين الكبيرة جداً
    'display3': 40, // للعناوين البارزة
    'display4': 36, // للعناوين الرئيسية
    'display5': 32, // للعناوين المتوسطة
    'h1': 28, // عنوان رئيسي
    'h2': 24, // عنوان ثانوي
    'h3': 22, // عنوان فرعي كبير
    'h4': 20, // عنوان فرعي
    'h5': 18, // عنوان صغير
    'h6': 16, // عنوان صغير جداً
    'body1': 16, // نص رئيسي
    'body2': 14, // نص عادي
    'body3': 13, // نص صغير
    'caption': 12, // نص توضيحي (الحد الأدنى)
    'button1': 16, // زر كبير
    'button2': 14, // زر متوسط
    'button3': 13, // زر صغير
  };

  // 🚀 Display Styles (للعناوين الكبيرة جداً)
  static const TextStyle displayXLarge = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    height: 1.05,
    letterSpacing: -2.0,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -1.0,
  );

  static const TextStyle displayXSmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.18,
    letterSpacing: -0.8,
  );

  // 📝 Heading Styles (6 مستويات كاملة)
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: -0.2,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.375,
    letterSpacing: 0,
  );

  // 📖 Body Styles (أحجام متدرجة)
  static const TextStyle bodyXLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.1,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyXSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.05,
  );

  // 🏷️ Label Styles (للتسميات)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
  );

  // 🔘 Button Styles
  static const TextStyle buttonXLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.6,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.4,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.3,
  );

  // 📝 Caption & Helper Text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.2,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 1.0,
  );

  static const TextStyle helperText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // 💰 أنماط خاصة للأسعار
  static const TextStyle priceXLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  // 🏆 أنماط خاصة للتقييمات
  static const TextStyle ratingLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle ratingMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle ratingSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // 🏷️ أنماط للشارات (Badges)
  static const TextStyle badgeLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: 0.3,
  );

  static const TextStyle badgeMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: 0.2,
  );

  static const TextStyle badgeSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0.1,
  );

  // 🔧 Helper Methods

  /// الحصول على نمط نص ديناميكي بناءً على الحجم
  static TextStyle dynamicStyle({
    required double fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) {
    // التأكد من الحد الأدنى
    final double validSize = fontSize < 12 ? 12 : fontSize;

    // تحديد الوزن بناءً على الحجم
    final FontWeight resolvedWeight =
        fontWeight ?? _getWeightForSize(validSize);

    // تحديد ارتفاع السطر بناءً على الحجم
    final double resolvedHeight = height ?? _getHeightForSize(validSize);

    // تحديد المسافة بين الأحرف
    final double resolvedSpacing =
        letterSpacing ?? _getSpacingForSize(validSize);

    return TextStyle(
      fontSize: validSize.toDouble(),
      fontWeight: resolvedWeight,
      height: resolvedHeight,
      letterSpacing: resolvedSpacing,
      fontFamily: fontFamily,
    );
  }

  /// تحديد الوزن المناسب للحجم
  static FontWeight _getWeightForSize(double size) {
    if (size >= 36) return FontWeight.w700;
    if (size >= 24) return FontWeight.w600;
    if (size >= 16) return FontWeight.w500;
    return FontWeight.w400;
  }

  /// تحديد ارتفاع السطر المناسب للحجم
  static double _getHeightForSize(double size) {
    if (size >= 36) return 1.1;
    if (size >= 24) return 1.25;
    if (size >= 16) return 1.4;
    return 1.5;
  }

  /// تحديد المسافة بين الأحرف
  static double _getSpacingForSize(double size) {
    if (size >= 36) return -1.0;
    if (size >= 24) return -0.3;
    if (size >= 16) return 0.1;
    return 0.2;
  }

  /// الحصول على حجم خط متجاوب
  static double responsive(
    BuildContext context,
    double baseSize, {
    double? minSize,
    double? maxSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / 375).clamp(0.85, 1.3);
    final scaledSize = baseSize * scaleFactor;

    // تطبيق الحدود
    final double min = minSize ?? 12;
    final double max = maxSize ?? baseSize * 1.5;

    return scaledSize.clamp(min, max);
  }

  // ✨ Special Effects

  /// نص بتدرج لوني
  static TextStyle gradient({
    required double fontSize,
    FontWeight? fontWeight,
    required Gradient gradient,
  }) {
    final validSize = fontSize < 12 ? 12 : fontSize;
    return dynamicStyle(
      fontSize: validSize.toDouble(),
      fontWeight: fontWeight,
    ).copyWith(
      foreground: Paint()
        ..shader = gradient.createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  /// نص نيون
  static TextStyle neon({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
    double glowIntensity = 1.0,
  }) {
    final validSize = fontSize < 12 ? 12 : fontSize;
    return dynamicStyle(
      fontSize: validSize.toDouble(),
      fontWeight: fontWeight ?? FontWeight.w700,
    ).copyWith(
      color: color,
      shadows: [
        Shadow(
          color: color.withOpacity(0.8 * glowIntensity),
          blurRadius: 10 * glowIntensity,
        ),
        Shadow(
          color: color.withOpacity(0.6 * glowIntensity),
          blurRadius: 20 * glowIntensity,
        ),
        Shadow(
          color: color.withOpacity(0.4 * glowIntensity),
          blurRadius: 30 * glowIntensity,
        ),
      ],
    );
  }

  /// نص زجاجي
  static TextStyle glass({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double opacity = 0.9,
  }) {
    final validSize = fontSize < 12 ? 12 : fontSize;
    return dynamicStyle(
      fontSize: validSize.toDouble(),
      fontWeight: fontWeight,
    ).copyWith(
      color: (color ?? AppTheme.textWhite).withOpacity(opacity),
      shadows: const [
        Shadow(
          color: Colors.black26,
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// نص بظل
  static TextStyle elevated({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    Color? shadowColor,
    double elevation = 4,
  }) {
    final validSize = fontSize < 12 ? 12 : fontSize;
    return dynamicStyle(
      fontSize: validSize.toDouble(),
      fontWeight: fontWeight,
    ).copyWith(
      color: color,
      shadows: [
        Shadow(
          color: (shadowColor ?? Colors.black).withOpacity(0.25),
          offset: Offset(0, elevation / 2),
          blurRadius: elevation,
        ),
      ],
    );
  }

  /// نص مخطط (Outlined)
  static TextStyle outlined({
    required double fontSize,
    FontWeight? fontWeight,
    Color? strokeColor,
    double strokeWidth = 1.0,
  }) {
    final validSize = fontSize < 12 ? 12 : fontSize;
    return dynamicStyle(
      fontSize: validSize.toDouble(),
      fontWeight: fontWeight,
    ).copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor ?? AppTheme.textWhite,
    );
  }
}

// 🎯 Extension Methods للسهولة
extension TextStyleX on TextStyle {
  /// التأكد من الحد الأدنى للحجم
  TextStyle get safe {
    if (fontSize == null || fontSize! >= 12) return this;
    return copyWith(fontSize: 12);
  }

  /// تطبيق تدرج
  TextStyle withGradient(Gradient gradient) {
    return copyWith(
      foreground: Paint()
        ..shader = gradient.createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  /// تطبيق نيون
  TextStyle withNeon(Color color, [double intensity = 1.0]) {
    return copyWith(
      color: color,
      shadows: [
        Shadow(
          color: color.withOpacity(0.8 * intensity),
          blurRadius: 10 * intensity,
        ),
        Shadow(
          color: color.withOpacity(0.6 * intensity),
          blurRadius: 20 * intensity,
        ),
      ],
    );
  }

  /// تطبيق شفافية
  TextStyle withOpacity(double opacity) {
    return copyWith(
      color: (color ?? Colors.white).withOpacity(opacity),
    );
  }

  /// تطبيق ارتفاع (elevation)
  TextStyle withElevation(double elevation, [Color? shadowColor]) {
    return copyWith(
      shadows: [
        Shadow(
          color: (shadowColor ?? Colors.black).withOpacity(0.25),
          offset: Offset(0, elevation / 2),
          blurRadius: elevation,
        ),
      ],
    );
  }

  /// الحصول على نسخة Bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// الحصول على نسخة SemiBold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// الحصول على نسخة Medium
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// الحصول على نسخة Light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
}

// 🎨 مجموعات أنماط جاهزة للاستخدام
class TextStylePresets {
  // للعناوين الرئيسية في الصفحات
  static TextStyle pageTitle = AppTextStyles.h1.bold;

  // للعناوين الفرعية
  static TextStyle sectionTitle = AppTextStyles.h3.semiBold;

  // للأسعار الكبيرة
  static TextStyle priceHero = AppTextStyles.priceXLarge.bold;

  // للأزرار الرئيسية
  static TextStyle primaryButton = AppTextStyles.buttonLarge.semiBold;

  // للنص الوصفي
  static TextStyle description = AppTextStyles.bodyMedium;

  // للتنبيهات
  static TextStyle alert = AppTextStyles.bodyMedium.semiBold;

  // للملاحظات الصغيرة
  static TextStyle hint = AppTextStyles.caption.withOpacity(0.7);
}
