// lib/core/presentation/bloc/theme/theme_state.dart

import 'package:flutter/material.dart';

/// Describes the `ThemeState` state that keeps this feature coordinated.
/// العربية: يمثل الحالة الخاصة بـ `ThemeState`.
class ThemeState {
  /// Keeps the `themeMode` value so this type can use it later.
  /// العربية: يخزن القيمة `themeMode`.
  final ThemeMode themeMode;

  /// Indicates whether `isLoading` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isLoading` مفعلة.
  final bool isLoading;

  /// Builds the `ThemeState` instance used by this layer.
  /// العربية: ينشئ مثيلًا جديدًا من `ThemeState`.
  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  /// Creates a copy of this object with the provided overrides.
  /// العربية: ينشئ نسخة من هذا الكائن مع استبدال القيم المحددة.
  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Builds the `ThemeState.initial` instance used by this layer.
  /// العربية: ينشئ مثيلًا جديدًا من `ThemeState.initial`.
  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: ThemeMode.dark,
      isLoading: true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isLoading == isLoading;
  }

  /// Exposes the `hashCode` value for callers that need it.
  /// العربية: يعيد القيمة `hashCode`.
  @override
  int get hashCode => themeMode.hashCode ^ isLoading.hashCode;
}
