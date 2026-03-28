// lib/core/utils/responsive_utils.dart

import 'package:flutter/material.dart';

/// أدوات استجابة تساعد الواجهة على التكيف مع الهاتف واللوحي وسطح المكتب.
/// Responsive helpers that let the UI adapt to mobile, tablet, and desktop layouts.
class ResponsiveUtils {
  /// حد الهاتف الذي يفصل بين الشاشات الصغيرة وما فوقها.
  static const double mobileBreakpoint = 600;

  /// حد اللوحي الذي يفصل بين اللوحي وسطح المكتب.
  static const double tabletBreakpoint = 900;

  /// الحد الذي نبدأ بعده بتعامل سطح المكتب.
  static const double desktopBreakpoint = 1200;

  /// يحدد ما إذا كانت الشاشة الحالية تصنف كهاتف.
  /// Returns whether the current viewport should be treated as mobile.
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// يحدد ما إذا كانت الشاشة الحالية تصنف كلّوبيحيًا.
  /// Returns whether the current viewport should be treated as tablet.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// يحدد ما إذا كانت الشاشة الحالية تصنف كسطح مكتب.
  /// Returns whether the current viewport should be treated as desktop.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// يختار القيمة المناسبة بحسب حجم الشاشة الحالي.
  /// Picks the value that best matches the current screen size.
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// يحدد تباعدًا مناسبًا حسب نوع الجهاز.
  /// Returns padding tuned for the current device class.
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  /// يحدد عدد أعمدة الشبكة بحسب المساحة المتاحة.
  /// Returns the number of grid columns based on available width.
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  /// يحدد نسبة الأبعاد المناسبة لعناصر الشبكة.
  /// Returns an aspect ratio that fits the current grid layout.
  static double getGridAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 1.5;
    } else if (isTablet(context)) {
      return 1.3;
    } else {
      return 1.0;
    }
  }
}
