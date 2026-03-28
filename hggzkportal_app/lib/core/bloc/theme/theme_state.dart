// lib/core/presentation/bloc/theme/theme_state.dart

import 'package:flutter/material.dart';

/// حالة الثيم التي تحمل الوضع الحالي وإشارة التحميل أثناء استرجاع التفضيل.
/// Theme state that carries the active mode and the loading flag during restoration.
class ThemeState {
  /// نمط الثيم المطبق حاليًا داخل التطبيق.
  /// The theme mode currently applied by the app.
  final ThemeMode themeMode;

  /// يوضح ما إذا كان الـ bloc ما يزال يستعيد الثيم المخزن عند الإقلاع.
  /// Indicates whether the bloc is still restoring the saved theme during startup.
  final bool isLoading;

  /// Builds a theme state snapshot for the current app appearance.
  /// ينشئ لقطة حالة لثيم المظهر الحالي في التطبيق.
  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  /// ينشئ نسخة معدلة حتى تقتصر التغييرات على الحقول التي تغيرت فعلًا.
  /// Creates a modified copy so listeners react only to the fields that changed.
  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Creates the initial loading state before the saved preference is read.
  /// ينشئ حالة بدء تحميل قبل قراءة التفضيل المحفوظ.
  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: ThemeMode.dark,
      isLoading: true,
    );
  }

  /// Theme states are equal when the active mode and loading flag match.
  /// تتساوى حالات الثيم عندما يتطابق النمط الفعلي وعلم التحميل.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isLoading == isLoading;
  }

  /// Hashes the mode/loading pair so the state can be used reliably in sets
  /// and maps.
  /// يهبّش زوج النمط/التحميل حتى يمكن استخدام الحالة بأمان في المجموعات
  /// والخرائط.
  @override
  int get hashCode => themeMode.hashCode ^ isLoading.hashCode;
}
