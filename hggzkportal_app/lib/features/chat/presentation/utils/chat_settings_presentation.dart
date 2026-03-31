import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

double chatFontScale(String? fontSize) {
  switch ((fontSize ?? 'medium').trim().toLowerCase()) {
    case 'small':
      return 0.92;
    case 'large':
      return 1.08;
    case 'extra_large':
    case 'extra-large':
    case 'xlarge':
      return 1.16;
    default:
      return 1.0;
  }
}

String normalizeChatTheme(String? theme) {
  switch ((theme ?? 'default').trim().toLowerCase()) {
    case 'midnight':
    case 'aurora':
    case 'sunset':
    case 'default':
      return (theme ?? 'default').trim().toLowerCase();
    case 'auto':
    case 'light':
    case 'dark':
      return 'default';
    default:
      return 'default';
  }
}

List<Color> chatBackgroundGradient(String? theme) {
  switch (normalizeChatTheme(theme)) {
    case 'midnight':
      return const [
        Color(0xFF020617),
        Color(0xFF0F172A),
        Color(0xFF1E293B),
      ];
    case 'aurora':
      return const [
        Color(0xFF041C32),
        Color(0xFF064663),
        Color(0xFF0B6E4F),
      ];
    case 'sunset':
      return const [
        Color(0xFF2E1065),
        Color(0xFF7C2D12),
        Color(0xFF431407),
      ];
    default:
      return [
        AppTheme.darkBackground,
        AppTheme.darkBackground2,
        AppTheme.darkBackground3,
      ];
  }
}

Color chatAccentColor(String? theme) {
  switch (normalizeChatTheme(theme)) {
    case 'midnight':
      return const Color(0xFF60A5FA);
    case 'aurora':
      return const Color(0xFF2DD4BF);
    case 'sunset':
      return const Color(0xFFFB7185);
    default:
      return AppTheme.primaryBlue;
  }
}

String chatThemeLabelKey(String? theme) {
  switch (normalizeChatTheme(theme)) {
    case 'midnight':
      return 'chat.settings.theme.midnight';
    case 'aurora':
      return 'chat.settings.theme.aurora';
    case 'sunset':
      return 'chat.settings.theme.sunset';
    default:
      return 'chat.settings.theme.default';
  }
}

String chatFontSizeLabelKey(String? fontSize) {
  switch ((fontSize ?? 'medium').trim().toLowerCase()) {
    case 'small':
      return 'chat.settings.fontSizeSmall';
    case 'large':
      return 'chat.settings.fontSizeLarge';
    case 'extra_large':
    case 'extra-large':
    case 'xlarge':
      return 'chat.settings.fontSizeExtraLarge';
    default:
      return 'chat.settings.fontSizeMedium';
  }
}
