// lib/core/presentation/bloc/theme/theme_event.dart

import 'package:flutter/material.dart';

/// Theme events that restore, toggle, or explicitly apply the selected mode.
/// أحداث الثيم التي تستعيد النمط أو تبدّله أو تفرضه بشكل صريح.
abstract class ThemeEvent {
  /// Base constructor shared by all theme events.
  /// المُنشئ الأساسي المشترك بين جميع أحداث الثيم.
  const ThemeEvent();
}

/// يطلب من الـ bloc قراءة الثيم المحفوظ وتطبيقه عند بدء التطبيق.
/// Asks the bloc to read the saved theme and apply it during startup.
class LoadThemeEvent extends ThemeEvent {
  /// Requests loading the persisted theme at app startup.
  /// يطلب تحميل الثيم المخزن عند بدء التطبيق.
  const LoadThemeEvent();
}

/// يبدل مباشرة بين الوضع الفاتح والوضع الداكن.
/// Switches directly between light and dark modes.
class ToggleThemeEvent extends ThemeEvent {
  /// Requests a direct flip between light and dark modes.
  /// يطلب تبديلًا مباشرًا بين الوضع الفاتح والداكن.
  const ToggleThemeEvent();
}

/// يفرض ثيمًا محددًا بدل الاعتماد على سلوك التبديل.
/// Forces a specific theme mode instead of using toggle behavior.
class SetThemeEvent extends ThemeEvent {
  /// الثيم المطلوب تطبيقه على مستوى التطبيق كله.
  /// The theme mode that should be applied across the whole app.
  final ThemeMode themeMode;

  /// Forces the bloc to apply the provided theme mode.
  /// يطلب من الـ bloc تطبيق نمط الثيم الممرر.
  const SetThemeEvent({required this.themeMode});
}

/// يعيد الثيم إلى إعداد النظام بحيث يتبع التطبيق تفضيل الجهاز.
/// Returns theme control to the system so device preference wins again.
class SetSystemThemeEvent extends ThemeEvent {
  /// Requests system-controlled theme behavior.
  /// يطلب سلوك الثيم المتحكم به من النظام.
  const SetSystemThemeEvent();
}
