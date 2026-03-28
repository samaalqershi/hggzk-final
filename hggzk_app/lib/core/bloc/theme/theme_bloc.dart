// lib/core/presentation/bloc/theme/theme_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// Coordinates the state and events for `ThemeBloc`.
/// العربية: ينسق الحالة والأحداث الخاصة بـ `ThemeBloc`.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// Keeps the `themeKey` value so this type can use it later.
  /// العربية: يخزن القيمة `themeKey`.
  static const String _themeKey = 'app_theme_mode';

  /// Keeps the `themeModeLight` value so this type can use it later.
  /// العربية: يخزن القيمة `themeModeLight`.
  static const String _themeModeLight = 'light';

  /// Keeps the `themeModeDark` value so this type can use it later.
  /// العربية: يخزن القيمة `themeModeDark`.
  static const String _themeModeDark = 'dark';

  /// Keeps the `themeModeSystem` value so this type can use it later.
  /// العربية: يخزن القيمة `themeModeSystem`.
  static const String _themeModeSystem = 'system';

  /// Keeps the `prefs` value so this type can use it later.
  /// العربية: يخزن القيمة `prefs`.
  final SharedPreferences _prefs;

  /// Builds the `ThemeBloc` instance used by this layer.
  /// العربية: ينشئ مثيلًا جديدًا من `ThemeBloc`.
  ThemeBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(ThemeState.initial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
    on<SetSystemThemeEvent>(_onSetSystemTheme);

    // Load saved theme on initialization
    add(const LoadThemeEvent());
  }

  /// Processes the `onLoadTheme` flow and maps it into the app-level behavior.
  /// العربية: يعالج `onLoadTheme`.
  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final savedTheme = _prefs.getString(_themeKey);

      ThemeMode themeMode;
      switch (savedTheme) {
        case _themeModeLight:
          themeMode = ThemeMode.light;
          break;
        case _themeModeDark:
          themeMode = ThemeMode.dark;
          break;
        case _themeModeSystem:
          themeMode = ThemeMode.system;
          break;
        default:
          themeMode = ThemeMode.dark; // Default to dark
      }

      emit(ThemeState(
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      // If error, default to dark theme
      emit(const ThemeState(
        themeMode: ThemeMode.dark,
        isLoading: false,
      ));
    }
  }

  /// Processes the `onToggleTheme` flow and maps it into the app-level behavior.
  /// العربية: يعالج `onToggleTheme`.
  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    await _saveThemeMode(newMode);
    emit(ThemeState(
      themeMode: newMode,
      isLoading: false,
    ));
  }

  /// Processes the `onSetTheme` flow and maps it into the app-level behavior.
  /// العربية: يعالج `onSetTheme`.
  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveThemeMode(event.themeMode);
    emit(ThemeState(
      themeMode: event.themeMode,
      isLoading: false,
    ));
  }

  /// Processes the `onSetSystemTheme` flow and maps it into the app-level behavior.
  /// العربية: يعالج `onSetSystemTheme`.
  Future<void> _onSetSystemTheme(
    SetSystemThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveThemeMode(ThemeMode.system);
    emit(const ThemeState(
      themeMode: ThemeMode.system,
      isLoading: false,
    ));
  }

  /// Saves the theme mode.
  /// العربية: يحفظ theme mode.
  Future<void> _saveThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = _themeModeLight;
        break;
      case ThemeMode.dark:
        value = _themeModeDark;
        break;
      case ThemeMode.system:
        value = _themeModeSystem;
        break;
    }
    await _prefs.setString(_themeKey, value);
  }
}
