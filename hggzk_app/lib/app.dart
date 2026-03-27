import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hggzk/core/bloc/theme/theme_bloc.dart';
import 'package:hggzk/core/bloc/theme/theme_state.dart';
import 'package:hggzk/features/chat/presentation/providers/typing_indicator_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_manager.dart';
import 'routes/app_router.dart';
import 'injection_container.dart' as di;
import 'core/bloc/app_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'core/theme/app_theme.dart';

class HggzkApp extends StatelessWidget {
  const HggzkApp({super.key});

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
              title: 'hggzk',
              debugShowCheckedModeBanner: false,
              theme: _buildAppTheme(Brightness.light),
              darkTheme: _buildAppTheme(Brightness.dark),
              themeMode: themeState.themeMode,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocaleManager.supportedLocales,
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

ThemeMode _themeModeFrom(SettingsState state) {
  if (state is SettingsLoaded) {
    return state.settings.darkMode ? ThemeMode.dark : ThemeMode.light;
  }
  return ThemeMode.system;
}

Locale _localeFrom(SettingsState state) {
  if (state is SettingsLoaded) {
    final code = state.settings.preferredLanguage;
    return Locale(code);
  }
  return const Locale('ar', 'YE');
}

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
