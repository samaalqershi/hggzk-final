import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// يحتفظ باللغة النشطة التي يجب أن تعكسها الواجهة فورًا.
/// Holds the active locale so the UI can react immediately to language changes.
class LocaleCubit extends Cubit<Locale> {
  /// Builds the locale cubit with the initial app locale.
  /// ينشئ cubit اللغة مع اللغة الابتدائية للتطبيق.
  LocaleCubit(super.initialLocale) : super();

  /// Emits a new locale for the app shell and its dependent widgets.
  /// يصدر لغة جديدة لغلاف التطبيق والواجهات المعتمدة عليه.
  void setLocale(Locale locale) => emit(locale);
}
