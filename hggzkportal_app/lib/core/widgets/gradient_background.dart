// lib/core/widgets/gradient_background.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// خلفية متدرجة خفيفة تُستخدم لتوحيد مظهر الشاشات والأجزاء الرئيسة.
/// Lightweight gradient background used to unify the look of major screens and sections.
class GradientBackground extends StatelessWidget {
  /// الودجت الذي سيُعرض فوق الخلفية المتدرجة.
  /// Child widget rendered above the gradient surface.
  final Widget child;

  /// ألوان التدرج الاختيارية عندما يحتاج المستدعي إلى هوية مختلفة.
  /// Optional gradient colors when the caller needs a different visual identity.
  final List<Color>? colors;

  /// نقطة بدء التدرج.
  /// Gradient start alignment.
  final AlignmentGeometry? begin;

  /// نقطة نهاية التدرج.
  /// Gradient end alignment.
  final AlignmentGeometry? end;

  /// ينشئ خلفية متدرجة قابلة لإعادة الاستخدام للشاشات الزخرفية.
  /// Creates a reusable gradient backdrop for decorative screens.
  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
  });

  /// يبني الحاوية ذات التدرج ويحافظ على المحتوى الأصلي فوقها.
  /// Builds the gradient container while preserving the original child above it.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: colors ??
              [
                AppColors.background,
                AppColors.background.withValues(alpha: 0.95),
              ],
        ),
      ),
      child: child,
    );
  }
}
