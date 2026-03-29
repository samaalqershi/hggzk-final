import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';
import 'package:hggzk/core/theme/app_text_styles.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_event.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_state.dart';

/// Compact reusable language switcher used on entry and account screens.
class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({
    super.key,
    this.size = 36,
    this.showLabel = true,
  });

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          current is SettingsLoaded ||
          current is SettingsUpdated ||
          current is SettingsUpdating ||
          current is SettingsError,
      builder: (context, state) {
        String currentLanguage;
        if (state is SettingsLoaded) {
          currentLanguage = state.settings.preferredLanguage;
        } else if (state is SettingsUpdated) {
          currentLanguage = state.settings.preferredLanguage;
        } else if (state is SettingsUpdating) {
          currentLanguage = state.currentSettings.preferredLanguage;
        } else if (state is SettingsError && state.lastKnownSettings != null) {
          currentLanguage = state.lastKnownSettings!.preferredLanguage;
        } else {
          currentLanguage =
              LocaleManager.getCurrentLocale(context).languageCode;
        }

        final currentLabel = currentLanguage == 'ar' ? 'AR' : 'EN';

        return PopupMenuButton<String>(
          tooltip: context.tr('common.language'),
          offset: const Offset(0, 44),
          onSelected: (languageCode) {
            if (languageCode == currentLanguage) {
              return;
            }

            HapticFeedback.selectionClick();
            context.read<SettingsBloc>().add(UpdateLanguageEvent(languageCode));
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppTheme.darkSurface.withOpacity(0.96),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'ar',
              child: Text(
                context.tr('settings.item.languageArabic'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Text(
                context.tr('settings.item.languageEnglish'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ],
          child: Container(
            height: size,
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? 10 : 0,
            ),
            constraints: BoxConstraints(
              minWidth: size,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.4),
                  AppTheme.darkCard.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: AppTheme.textWhite.withOpacity(0.8),
                      size: size * 0.42,
                    ),
                    if (showLabel) ...[
                      const SizedBox(width: 6),
                      Text(
                        currentLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textWhite.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
