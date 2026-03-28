import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the brand logo in a reusable way across splash, auth, and shell
/// screens while allowing each caller to control size, fit, and visual
/// treatment.
/// يعرض شعار العلامة التجارية بصورة قابلة لإعادة الاستخدام في شاشات البداية
/// والمصادقة والهيكل الرئيسي، مع السماح للمستدعي بالتحكم في الحجم والتمدد
/// والمعالجة البصرية.
class AppLogoWidget extends StatelessWidget {
  /// Target width used by the logo container.
  /// العرض المستهدف الذي تُبنى عليه حاوية الشعار.
  final double width;

  /// Optional height override when the caller does not want a square footprint.
  /// ارتفاع اختياري عندما لا يرغب المستدعي في أن يكون الشعار مربع الأبعاد.
  final double? height;

  /// Controls how the SVG should fit inside its available box.
  /// يتحكم في كيفية تمدد ملف الـ SVG داخل المساحة المتاحة له.
  final BoxFit fit;

  /// Optional override that forces the light or dark asset variant regardless
  /// of the current theme.
  /// خيار اختياري لفرض النسخة الفاتحة أو الداكنة من الشعار بغض النظر عن الثيم
  /// الحالي.
  final bool? useLightVersion;

  /// Adds a themed background shell behind the logo when the design needs the
  /// mark to stand out on mixed surfaces.
  /// يضيف خلفية متكيفة مع الثيم خلف الشعار عندما يحتاج التصميم إلى إبراز
  /// العلامة فوق أسطح متعددة.
  final bool showAdaptiveBackground;

  /// Accessibility label forwarded to the underlying SVG widget.
  /// تسمية إمكانية الوصول التي تُمرر إلى عنصر الـ SVG الداخلي.
  final String? semanticsLabel;

  /// Creates a reusable brand-logo widget that can be embedded in different
  /// surfaces without duplicating asset-selection logic.
  /// ينشئ عنصر شعار قابلًا لإعادة الاستخدام في أكثر من سطح من دون تكرار منطق
  /// اختيار الأصل المناسب.
  const AppLogoWidget({
    super.key,
    required this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.useLightVersion,
    this.showAdaptiveBackground = false,
    this.semanticsLabel,
  });

  /// Selects the appropriate asset variant, applies theme-aware coloring, and
  /// optionally wraps the mark in an adaptive presentation shell.
  /// يختار نسخة الأصل المناسبة، ويطبق تلوينًا متوافقًا مع الثيم، ويمكنه
  /// تغليف الشعار ضمن حاوية عرض متكيفة عند الحاجة.
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool shouldUseLight = useLightVersion ?? isDarkMode;
    final String assetPath = shouldUseLight
        ? 'assets/images/app_logo_light.svg'
        : 'assets/images/app_logo.svg';
    final double targetHeight = height ?? width;
    final Color targetIconColor = shouldUseLight ? Colors.white : Colors.black;

    final Widget logo = SvgPicture.asset(
      assetPath,
      width: showAdaptiveBackground ? null : width,
      height: showAdaptiveBackground ? null : targetHeight,
      fit: fit,
      colorFilter: ColorFilter.mode(targetIconColor, BlendMode.srcIn),
      semanticsLabel: semanticsLabel,
    );

    if (!showAdaptiveBackground) {
      return logo;
    }

    final double inset = (targetHeight * 0.16).clamp(2.0, 12.0).toDouble();
    final double radius = (targetHeight * 0.28).clamp(6.0, 22.0).toDouble();

    return Container(
      width: width,
      height: targetHeight,
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? const [Color(0xFF1E2E52), Color(0xFF2A3B66)]
              : const [Color(0xFFFFFFFF), Color(0xFFE9F3FF)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDarkMode ? const Color(0x66A4C3FF) : const Color(0xFFB9CEE8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode ? const Color(0x55223866) : const Color(0x33486D9A),
            blurRadius: isDarkMode ? 16 : 12,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: logo,
    );
  }
}
