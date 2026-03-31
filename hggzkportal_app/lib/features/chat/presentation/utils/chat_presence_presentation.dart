import 'package:flutter/widgets.dart';
import '../../../../core/localization/app_localizations.dart';

/// Centralizes chat presence copy so every surface renders the same online and
/// last-seen language.
class ChatPresencePresentation {
  /// Returns the shared online-now label.
  static String onlineNow(BuildContext context) {
    return context.tr('chat.participant.onlineNow');
  }

  /// Returns a shared presence label for chat users.
  static String? presenceLabel(
    BuildContext context, {
    required bool isOnline,
    DateTime? lastSeen,
    String? fallbackStatus,
  }) {
    if (isOnline) {
      return onlineNow(context);
    }

    if (lastSeen != null) {
      return context.tr(
        'chat.participant.lastSeen',
        params: {'value': relativeLastSeen(context, lastSeen)},
      );
    }

    final normalizedFallback = fallbackStatus?.trim();
    if (normalizedFallback == null || normalizedFallback.isEmpty) {
      return null;
    }

    return normalizedFallback;
  }

  /// Returns the shared relative last-seen fragment.
  static String relativeLastSeen(BuildContext context, DateTime lastSeen) {
    final localizedLastSeen = lastSeen.toLocal();
    final difference = DateTime.now().difference(localizedLastSeen);

    if (difference.inMinutes < 1) {
      return context.tr('chat.participant.now');
    }

    if (difference.inMinutes < 60) {
      return context.tr(
        'chat.participant.minuteAgo',
        params: {'value': difference.inMinutes},
      );
    }

    if (difference.inHours < 24) {
      return context.tr(
        'chat.participant.hourAgo',
        params: {'value': difference.inHours},
      );
    }

    if (difference.inDays == 1) {
      return context.tr('chat.thread.yesterday');
    }

    return context.tr(
      'chat.participant.dayAgo',
      params: {'value': difference.inDays},
    );
  }
}
