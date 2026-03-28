// lib/core/presentation/bloc/theme/theme_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// يدير قراءة وتبديل وحفظ ثيم البورتال كي تبقى الواجهة متسقة عبر الجلسات.
/// Loads, toggles, and persists the portal theme so the interface stays consistent across sessions.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// مفتاح التخزين المستخدم لحفظ تفضيل الثيم محليًا.
  /// Storage key used to persist the selected theme mode locally.
  static const String _themeKey = 'app_theme_mode';

  /// تمثيل نصي لوضع الثيم الفاتح داخل SharedPreferences.
  /// String token for the light theme stored in SharedPreferences.
  static const String _themeModeLight = 'light';

  /// تمثيل نصي لوضع الثيم الداكن داخل SharedPreferences.
  /// String token for the dark theme stored in SharedPreferences.
  static const String _themeModeDark = 'dark';

  /// تمثيل نصي لوضع الثيم الذي يتبع إعدادات النظام.
  /// String token for the system-following theme mode.
  static const String _themeModeSystem = 'system';

  /// طبقة التخزين المحلية المستخدمة لقراءة وحفظ التفضيل.
  /// Local storage handle used to read and persist the preference.
  final SharedPreferences _prefs;

  /// Builds the theme bloc with its storage dependency and kicks off theme
  /// restoration immediately.
  /// ينشئ bloc الثيم مع اعتماد التخزين الخاص به ثم يبدأ استعادة الثيم
  /// مباشرة.
  ThemeBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(ThemeState.initial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
    on<SetSystemThemeEvent>(_onSetSystemTheme);

    // Restore the saved choice immediately so the first build uses the right colors.
    add(const LoadThemeEvent());
  }

  /// Restores the saved theme token and maps it back to a ThemeMode.
  /// يعيد قراءة الثيم المخزن ويحوّله إلى ThemeMode مناسب قبل عرض الواجهة.
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
          themeMode = ThemeMode.dark;
      }

      emit(ThemeState(
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      // Fallback to dark theme if persistence fails or the value is invalid.
      emit(const ThemeState(
        themeMode: ThemeMode.dark,
        isLoading: false,
      ));
    }
  }

  /// Switches between light and dark while keeping the choice persisted.
  /// يبدل بين الفاتح والداكن مع حفظ الاختيار في التخزين المحلي.
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

  /// Applies an explicit theme mode coming from settings or system controls.
  /// يطبق ثيمًا محددًا واردًا من إعدادات المستخدم أو منطق النظام.
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

  /// Restores system-following behavior so the device controls the appearance.
  /// يعيد سلوك اتباع النظام حتى يتحكم الجهاز في المظهر.
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

  /// Persists the symbolic theme token that matches the selected ThemeMode.
  /// يحفظ الرمز النصي المطابق لـ ThemeMode المختار.
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
