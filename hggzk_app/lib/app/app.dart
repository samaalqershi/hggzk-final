import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hggzk/app/bloc/app_bloc.dart';
import 'package:hggzk/app/router/app_router.dart';
import 'package:hggzk/core/bloc/theme/theme_bloc.dart';
import 'package:hggzk/core/bloc/theme/theme_state.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'package:hggzk/features/chat/presentation/providers/typing_indicator_provider.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_state.dart';

/// نقطة التجميع العليا للتطبيق.
/// Root composition widget that binds routing, localization, and theming.
class HggzkApp extends StatelessWidget {
  /// يبني غلاف التطبيق الجذري دون أي حالة محلية.
  /// Builds the stateless root shell for the entire application used by this feature.
  const HggzkApp({super.key});

  /// يربط مزودي الحالة العامة قبل تسليم التطبيق إلى `MaterialApp.router`.
  /// Wires global providers before handing control to `MaterialApp.router`.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TypingIndicatorProvider(),
        ),
        ...AppBloc.providers,
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
        final locale = _localeFrom(settingsState);
        return BlocBuilder<ThemeBloc, ThemeState>(
          bloc: AppBloc.theme,
          builder: (context, themeState) {
            return MaterialApp.router(
              onGenerateTitle: (context) => context.tr('app.appName'),
              debugShowCheckedModeBanner: false,
              theme: _buildAppTheme(Brightness.light),
              darkTheme: _buildAppTheme(Brightness.dark),
              themeMode: themeState.themeMode,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: AppRouter.build(context),
              builder: (context, child) {
                AppTheme.init(context, mode: themeState.themeMode);
                final systemBrightness =
                    MediaQuery.of(context).platformBrightness;
                final effectiveBrightness =
                    themeState.themeMode == ThemeMode.system
                        ? systemBrightness
                        : (themeState.themeMode == ThemeMode.dark
                            ? Brightness.dark
                            : Brightness.light);

                final overlayStyle = SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      effectiveBrightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                  statusBarBrightness: effectiveBrightness == Brightness.dark
                      ? Brightness.dark
                      : Brightness.light,
                );

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  child: child!,
                );
              },
            );
          },
        );
      }),
    );
  }
}

/// يحول تفضيل اللغة المخزن إلى `Locale` فعلي يستخدمه `MaterialApp`.
/// Resolves the persisted language preference into the locale used by `MaterialApp`.
Locale _localeFrom(SettingsState state) {
  if (state is SettingsLoaded) {
    final code = state.settings.preferredLanguage;
    return Locale(code);
  }
  return const Locale('ar', 'YE');
}

/// يشتق إعدادات الثيم مع خطوط المشروع مع الحفاظ على نظام ألوان النظام.
/// Builds the themed Material configuration while keeping the app typography consistent.
ThemeData _buildAppTheme(Brightness brightness) {
  final base =
      brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

  final tajawal = GoogleFonts.tajawalTextTheme(base.textTheme);
  final cairo = GoogleFonts.cairoTextTheme(base.textTheme);

  final textTheme = tajawal.copyWith(
    displayLarge: cairo.displayLarge,
    displayMedium: cairo.displayMedium,
    displaySmall: cairo.displaySmall,
    headlineLarge: cairo.headlineLarge,
    headlineMedium: cairo.headlineMedium,
    headlineSmall: cairo.headlineSmall,
    titleLarge: cairo.titleLarge,
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  );
}
