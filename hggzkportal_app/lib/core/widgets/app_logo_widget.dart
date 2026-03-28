import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// عنصر شعار موحّد يختار نسخة SVG المناسبة ويضبطها لواجهات البداية والرؤوس والبطاقات.
/// Shared logo renderer that picks the right SVG variant and fits it into splash screens, headers, and cards.
class AppLogoWidget extends StatelessWidget {
  /// العرض المستهدف للشعار داخل الواجهة.
  /// Target width for the logo inside the current layout.
  final double width;

  /// ارتفاع اختياري عندما لا يكون الشعار مربعًا داخل السياق الحالي.
  /// Optional height when the logo should not use a square footprint.
  final double? height;

  /// طريقة ملاءمة الصورة داخل الإطار المخصص لها.
  /// How the SVG should fit inside its allotted box.
  final BoxFit fit;

  /// يفرض استخدام نسخة الشعار الفاتحة بدل الاعتماد على سطوع الثيم.
  /// Forces the light logo variant instead of deriving the choice from theme brightness.
  final bool? useLightVersion;

  /// يضيف خلفية متدرجة وحدودًا ناعمة عندما يحتاج الشعار إلى حضانة بصرية أوضح.
  /// Adds a branded background treatment when the logo needs more visual separation.
  final bool showAdaptiveBackground;

  /// وصف وصولي يقرأه قارئ الشاشة عندما يكون الشعار عنصرًا ذا معنى دلالي.
  /// Accessibility label announced by screen readers when the logo conveys meaning.
  final String? semanticsLabel;

  /// Creates a logo widget sized for splash screens, headers, and branded containers.
  /// ينشئ عنصر شعار مناسبًا لشاشات البداية والرؤوس والحاويات ذات الهوية البصرية.
  const AppLogoWidget({
    super.key,
    required this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.useLightVersion,
    this.showAdaptiveBackground = false,
    this.semanticsLabel,
  });

  /// Resolves the correct asset for the current theme and optionally wraps it in a branded frame.
  /// يحدد الملف المناسب للثيم الحالي ويمكن أن يحيطه بإطار بصري يحمل الهوية.
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
