// lib/core/presentation/bloc/theme/theme_event.dart

import 'package:flutter/material.dart';

/// Common base for the commands that change how the app is rendered.
/// العربية: يمثل الأساس المشترك للأوامر التي تغيّر مظهر التطبيق.
abstract class ThemeEvent {
  /// Declares the shared event base used by the theme bloc.
  /// العربية: يعرّف الأساس المشترك لأحداث الثيم.
  const ThemeEvent();
}

/// Loads the persisted theme choice from local storage and applies it to the bloc.
/// العربية: يحمّل الثيم المحفوظ من التخزين المحلي ثم يطبقه داخل الكتلة.
class LoadThemeEvent extends ThemeEvent {
  /// Triggers the restoration flow for the saved theme mode.
  /// العربية: يطلق مسار استعادة وضع الثيم المحفوظ.
  const LoadThemeEvent();
}

/// Switches between light and dark mode when the user wants a quick flip.
/// العربية: يبدّل بين الوضع الفاتح والداكن عند طلب تبديل سريع.
class ToggleThemeEvent extends ThemeEvent {
  /// Carries the request to flip the current theme between light and dark.
  /// العربية: ينقل طلب قلب الثيم الحالي بين الفاتح والداكن.
  const ToggleThemeEvent();
}

/// Applies an explicit theme mode chosen by the user or a higher-level setting.
/// العربية: يطبّق وضع ثيم محدد من اختيار المستخدم أو من طبقة أعلى.
class SetThemeEvent extends ThemeEvent {
  /// Keeps the requested theme mode so the bloc can persist and apply it consistently.
  /// العربية: يحتفظ بوضع الثيم المطلوب ليُحفظ ويُطبّق بشكل متسق.
  final ThemeMode themeMode;

  /// Carries a concrete theme mode into the bloc.
  /// العربية: ينقل وضع الثيم المحدد إلى الكتلة.
  const SetThemeEvent({required this.themeMode});
}

/// Returns control back to the operating system so the app follows the device theme.
/// العربية: يعيد التحكم إلى النظام بحيث يتبع التطبيق ثيم الجهاز.
class SetSystemThemeEvent extends ThemeEvent {
  /// Requests that the bloc follow the system appearance.
  /// العربية: يطلب من الكتلة اتباع مظهر النظام.
  const SetSystemThemeEvent();
}
