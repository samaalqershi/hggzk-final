import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogoWidget extends StatelessWidget {
  final double width;
  final double? height;
  final BoxFit fit;
  final bool? useLightVersion;
  final bool showAdaptiveBackground;
  final String? semanticsLabel;

  const AppLogoWidget({
    super.key,
    required this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.useLightVersion,
    this.showAdaptiveBackground = false,
    this.semanticsLabel,
  });

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
