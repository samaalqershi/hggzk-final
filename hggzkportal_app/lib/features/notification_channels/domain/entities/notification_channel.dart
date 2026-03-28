import 'package:equatable/equatable.dart';

/// للحقل حتى تبقى طبقات المجال والبيانات متفقة على نفس اللغة.
/// channels feature.
/// the domain and data layers speak the same language.
class NotificationChannel extends Equatable {
  final String id;
  final String name;

  /// topics.
  final String identifier;

  /// it should be enabled or disabled.
  final String? description;

  /// recognize visually.
  final String? icon;
  final String? color;

  /// and subscribing.
  final bool isActive;
  final bool isPrivate;
  final bool isDeletable;

  /// administration.
  final String type; // SYSTEM, CUSTOM, ROLE_BASED, EVENT_BASED
  final List<String> allowedRoles;
  final int subscribersCount;
  final int notificationsSentCount;
  final DateTime? lastNotificationAt;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// populated records.
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.identifier,
    this.description,
    this.icon,
    this.color,
    this.isActive = true,
    this.isPrivate = false,
    this.isDeletable = true,
    this.type = 'CUSTOM',
    this.allowedRoles = const [],
    this.subscribersCount = 0,
    this.notificationsSentCount = 0,
    this.lastNotificationAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// القناة نفسها وليس مجرد تمثيلها.
  /// changes the channel’s identity, not just its representation.
  @override
  List<Object?> get props => [
        id,
        name,
        identifier,
        description,
        icon,
        color,
        isActive,
        isPrivate,
        isDeletable,
        type,
        allowedRoles,
        subscribersCount,
        notificationsSentCount,
        lastNotificationAt,
        createdBy,
        createdAt,
        updatedAt,
      ];

  /// دفع مشابهة.
  /// similar push delivery layer.
  String get fcmTopic => 'channel_$identifier';

  /// من الخادم.
  /// does not provide a custom one.
  String get displayColor => color ?? '#1E88E5';

  /// هناك أيقونة مخصصة.
  /// no custom icon is available.
  String get displayIcon => icon ?? '📢';

  /// أنشأها المشرف.
  /// by admins.
  bool get isSystem => type == 'SYSTEM';

  /// بطاقات الإدارة والتقارير.
  /// reads clearly in admin cards and reports.
  String get typeLabel {
    switch (type) {
      case 'SYSTEM':
        return 'قناة نظام';
      case 'CUSTOM':
        return 'قناة مخصصة';
      case 'ROLE_BASED':
        return 'قناة حسب الدور';
      case 'EVENT_BASED':
        return 'قناة حسب الحدث';
      default:
        return 'قناة';
    }
  }
}

/// نشطًا أم لا.
/// and whether the subscription is still active.
class UserChannelSubscription extends Equatable {
  final String id;
  final String userId;
  final String channelId;

  /// immediately.
  final NotificationChannel? channel;
  final String? userName;

  /// screens.
  final String? userEmail;
  final bool isActive;
  final bool isMuted;
  final DateTime subscribedAt;
  final DateTime? unsubscribedAt;

  /// channel.
  final int notificationsReceivedCount;
  final DateTime? lastNotificationReceivedAt;
  final String? notes;

  /// يرسل الخادم كل البيانات.
  /// object consistent when the backend omits some fields.
  const UserChannelSubscription({
    required this.id,
    required this.userId,
    required this.channelId,
    this.channel,
    this.userName,
    this.userEmail,
    this.isActive = true,
    this.isMuted = false,
    required this.subscribedAt,
    this.unsubscribedAt,
    this.notificationsReceivedCount = 0,
    this.lastNotificationReceivedAt,
    this.notes,
  });

  /// يصف سجلًا مختلفًا.
  /// change describes a different record.
  @override
  List<Object?> get props => [
        id,
        userId,
        channelId,
        channel,
        userName,
        userEmail,
        isActive,
        isMuted,
        subscribedAt,
        unsubscribedAt,
        notificationsReceivedCount,
        lastNotificationReceivedAt,
        notes,
      ];
}

/// successful the delivery was.
class ChannelNotificationHistory extends Equatable {
  final String id;
  final String channelId;

  /// another service.
  final String? notificationId;
  final String title;
  final String content;
  final String type;
  final int recipientsCount;
  final int successfulDeliveries;
  final int failedDeliveries;
  final String? senderId;
  final String? senderName;
  final DateTime sentAt;

  /// الجزئي أو الردود الناقصة.
  /// queries or incomplete responses.
  const ChannelNotificationHistory({
    required this.id,
    required this.channelId,
    this.notificationId,
    required this.title,
    required this.content,
    this.type = 'INFO',
    this.recipientsCount = 0,
    this.successfulDeliveries = 0,
    this.failedDeliveries = 0,
    this.senderId,
    this.senderName,
    required this.sentAt,
  });

  /// محددًا لا يتكرر.
  /// entry represents one specific send event.
  @override
  List<Object?> get props => [
        id,
        channelId,
        notificationId,
        title,
        content,
        type,
        recipientsCount,
        successfulDeliveries,
        failedDeliveries,
        senderId,
        senderName,
        sentAt,
      ];

  /// reports.
  double get successRate {
    if (recipientsCount == 0) return 0;
    return (successfulDeliveries / recipientsCount) * 100;
  }

  /// UI.
  String get typeLabel {
    switch (type) {
      case 'INFO':
        return 'معلومات';
      case 'WARNING':
        return 'تحذير';
      case 'ERROR':
        return 'خطأ';
      case 'SUCCESS':
        return 'نجاح';
      case 'URGENT':
        return 'عاجل';
      default:
        return type;
    }
  }
}

/// القنوات.
/// understand channel health.
class ChannelStatistics extends Equatable {
  final int totalChannels;
  final int activeChannels;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int totalNotificationsSent;
  final Map<String, int> channelsByType;
  final List<ChannelSummary> topActiveChannels;

  /// directly.
  const ChannelStatistics({
    required this.totalChannels,
    required this.activeChannels,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.totalNotificationsSent,
    required this.channelsByType,
    required this.topActiveChannels,
  });
  @override
  List<Object?> get props => [
        totalChannels,
        activeChannels,
        totalSubscriptions,
        activeSubscriptions,
        totalNotificationsSent,
        channelsByType,
        topActiveChannels,
      ];
}

class ChannelSummary extends Equatable {
  final String id;
  final String name;
  final int notificationsSentCount;
  final int subscribersCount;

  /// لوحة الإدارة.
  /// dashboard card.
  const ChannelSummary({
    required this.id,
    required this.name,
    required this.notificationsSentCount,
    required this.subscribersCount,
  });

  /// indicators.
  @override
  List<Object?> get props =>
      [id, name, notificationsSentCount, subscribersCount];
}
