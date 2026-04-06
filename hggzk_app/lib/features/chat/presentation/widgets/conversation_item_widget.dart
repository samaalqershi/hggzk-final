// lib/features/chat/presentation/widgets/conversation_item_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/conversation.dart';
import 'online_status_indicator.dart';

/// Row item used in the conversation inbox to show identity, last message,
/// unread state, and typing hints.
/// صف عنصر يستخدم في صندوق المحادثات لعرض الهوية وآخر رسالة وحالة غير
/// المقروء ومؤشر الكتابة.
class ConversationItemWidget extends StatelessWidget {
  /// Conversation data shown in the inbox row.
  /// بيانات المحادثة المعروضة في صف الصندوق الوارد.
  final Conversation conversation;

  /// Current user id used to resolve the other participant and ownership.
  /// معرّف المستخدم الحالي المستخدم لتحديد الطرف الآخر وملكية الرسائل.
  final String currentUserId;

  /// Users currently typing in this conversation.
  /// المستخدمون الذين يكتبون الآن داخل هذه المحادثة.
  final List<String> typingUserIds;

  /// Opens the conversation when the row is selected.
  /// يفتح المحادثة عند اختيار الصف.
  final VoidCallback onTap;

  /// Opens contextual actions for the conversation when available.
  /// يفتح إجراءات سياقية للمحادثة عندما تكون متاحة.
  final VoidCallback? onLongPress;

  /// Builds one inbox row for a conversation thread.
  /// ينشئ صفًا واحدًا للمحادثة داخل الصندوق الوارد.
  const ConversationItemWidget({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.typingUserIds = const [],
    required this.onTap,
    this.onLongPress,
  });

  /// Renders the inbox row with avatar, status, preview, and timestamps.
  /// يرسم صف الصندوق الوارد مع الصورة والحالة والمعاينة والوقت.
  @override
  Widget build(BuildContext context) {
    final otherParticipant = conversation.isDirectChat
        ? conversation.getOtherParticipant(currentUserId)
        : null;

    final displayName = conversation.isDirectChat &&
            (otherParticipant?.name.trim().isNotEmpty == true)
        ? otherParticipant!.name.trim()
        : (conversation.title?.trim().isNotEmpty == true
            ? conversation.title!.trim()
            : otherParticipant?.name ??
                context.tr('chat.message.conversationFallback'));

    final displayImage = conversation.avatar ?? otherParticipant?.profileImage;

    final isTyping = typingUserIds.isNotEmpty;
    final subtitleText = _buildConversationSubtitle(
      context: context,
      otherParticipant: otherParticipant,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.lightImpact();
                onLongPress!();
              }
            : null,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: conversation.hasUnreadMessages
                  ? [
                      Colors.white.withOpacity(0.075),
                      AppTheme.primaryBlue.withOpacity(0.035),
                    ]
                  : [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: conversation.hasUnreadMessages
                  ? AppTheme.primaryBlue.withOpacity(0.12)
                  : AppTheme.darkBorder.withOpacity(0.07),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: conversation.hasUnreadMessages
                    ? AppTheme.primaryBlue.withOpacity(0.06)
                    : Colors.black.withOpacity(0.06),
                blurRadius: conversation.hasUnreadMessages ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (conversation.hasUnreadMessages)
                PositionedDirectional(
                  start: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildUltraMinimalAvatar(displayImage, displayName),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: conversation.hasUnreadMessages
                                          ? FontWeight.w800
                                          : FontWeight.w700,
                                      fontSize: 14,
                                      color: AppTheme.textWhite.withOpacity(
                                        conversation.hasUnreadMessages
                                            ? 0.94
                                            : 0.84,
                                      ),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitleText,
                                    style: AppTextStyles.caption.copyWith(
                                      color:
                                          AppTheme.textMuted.withOpacity(0.42),
                                      fontSize: 9.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (conversation.isMuted)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, right: 6),
                                child: Icon(
                                  Icons.notifications_off_rounded,
                                  size: 12,
                                  color: AppTheme.textMuted.withOpacity(0.4),
                                ),
                              ),
                            Text(
                              _formatTime(
                                context,
                                conversation.lastMessage?.createdAt ??
                                    conversation.updatedAt,
                              ),
                              style: AppTextStyles.caption.copyWith(
                                color: conversation.hasUnreadMessages
                                    ? AppTheme.primaryBlue.withOpacity(0.82)
                                    : AppTheme.textMuted.withOpacity(0.5),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (conversation.lastMessage != null &&
                                conversation.lastMessage!.senderId ==
                                    currentUserId)
                              _buildUltraMinimalStatus(
                                conversation.lastMessage!.status,
                              ),
                            Expanded(
                              child: isTyping
                                  ? _buildUltraMinimalTyping(context)
                                  : _buildUltraMinimalLastMessage(context),
                            ),
                            if (conversation.hasUnreadMessages) ...[
                              const SizedBox(width: 8),
                              _buildUltraMinimalBadge(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the compact avatar and presence badge for the thread.
  /// ينشئ الصورة المدمجة وشارة الحضور الخاصة بالسلسلة.
  Widget _buildUltraMinimalAvatar(String? imageUrl, String name) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: conversation.hasUnreadMessages
                  ? [
                      AppTheme.primaryBlue.withOpacity(0.18),
                      AppTheme.primaryPurple.withOpacity(0.1),
                    ]
                  : [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.03),
                    ],
            ),
            border: Border.all(
              color: conversation.hasUnreadMessages
                  ? AppTheme.primaryBlue.withOpacity(0.16)
                  : AppTheme.darkBorder.withOpacity(0.07),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: conversation.hasUnreadMessages
                    ? AppTheme.primaryBlue.withOpacity(0.09)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: hasImage
                ? CachedImageWidget(
                    imageUrl: imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      _getInitials(name),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: conversation.hasUnreadMessages
                            ? AppTheme.primaryBlue.withOpacity(0.92)
                            : AppTheme.textMuted.withOpacity(0.72),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ),
        if (conversation.isDirectChat &&
            conversation.getOtherParticipant(currentUserId)?.isOnline == true)
          Positioned(
            bottom: 1,
            right: 1,
            child: const OnlineStatusIndicator(
              isOnline: true,
              size: 10,
              showBorder: true,
              animate: true,
            ),
          ),
      ],
    );
  }

  /// العربية: يبني ultra minimal status.
  Widget _buildUltraMinimalStatus(String status) {
    IconData icon;
    Color color;
    double size = 12;

    switch (status) {
      case 'sent':
        icon = Icons.check;
        color = AppTheme.textMuted.withOpacity(0.3);
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = AppTheme.textMuted.withOpacity(0.3);
        break;
      case 'read':
        icon = Icons.done_all;
        color = AppTheme.primaryBlue.withOpacity(0.6);
        break;
      case 'failed':
        icon = Icons.error_outline;
        color = AppTheme.error.withOpacity(0.6);
        size = 11;
        break;
      default:
        icon = Icons.schedule;
        color = AppTheme.textMuted.withOpacity(0.2);
        size = 11;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  /// العربية: يبني ultra minimal last message.
  Widget _buildUltraMinimalLastMessage(BuildContext context) {
    if (conversation.lastMessage == null) {
      return Text(
        context.tr('chat.thread.start'),
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withOpacity(0.3),
          fontStyle: FontStyle.italic,
          fontSize: 11,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    String messageText = '';
    Widget? prefix;

    switch (conversation.lastMessage!.messageType) {
      case 'text':
        messageText = conversation.lastMessage!.content ?? '';
        break;
      case 'image':
        prefix = Icon(Icons.image,
            size: 12, color: AppTheme.textMuted.withOpacity(0.3));
        messageText = context.tr('chat.message.image');
        break;
      case 'video':
        prefix = Icon(Icons.videocam,
            size: 12, color: AppTheme.textMuted.withOpacity(0.3));
        messageText = context.tr('chat.message.video');
        break;
      case 'audio':
        prefix = Icon(Icons.mic,
            size: 12, color: AppTheme.textMuted.withOpacity(0.3));
        messageText = context.tr('chat.message.audio');
        break;
      case 'document':
        prefix = Icon(Icons.attach_file,
            size: 12, color: AppTheme.textMuted.withOpacity(0.3));
        messageText = context.tr('chat.message.document');
        break;
      case 'location':
        prefix = Icon(Icons.location_on,
            size: 12, color: AppTheme.textMuted.withOpacity(0.3));
        messageText = context.tr('chat.message.location');
        break;
    }

    return Row(
      children: [
        if (prefix != null) ...[
          prefix,
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            messageText,
            style: AppTextStyles.caption.copyWith(
              color: conversation.hasUnreadMessages
                  ? AppTheme.textWhite.withOpacity(0.76)
                  : AppTheme.textMuted.withOpacity(0.56),
              fontSize: 11.5,
              height: 1.25,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// العربية: يبني ultra minimal typing.
  Widget _buildUltraMinimalTyping(BuildContext context) {
    return Row(
      children: [
        Text(
          context.tr('chat.inbox.typing'),
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.primaryBlue.withOpacity(0.82),
            fontStyle: FontStyle.italic,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 12,
          height: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(value * 0.85),
                      shape: BoxShape.circle,
                    ),
                  );
                },
                onEnd: () {},
              );
            }),
          ),
        ),
      ],
    );
  }

  /// العربية: يبني ultra minimal badge.
  Widget _buildUltraMinimalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.16),
          width: 0.7,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      child: Center(
        child: Text(
          conversation.unreadCount > 99
              ? '99+'
              : conversation.unreadCount.toString(),
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.primaryBlue.withOpacity(0.92),
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  String _buildConversationSubtitle({
    required BuildContext context,
    required ChatUser? otherParticipant,
  }) {
    if (conversation.isDirectChat && otherParticipant != null) {
      if (otherParticipant.isOnline) {
        return context.tr('chat.thread.onlineNow');
      }
      if (otherParticipant.lastSeen != null) {
        return context.tr(
          'chat.thread.lastSeen',
          params: {
            'value': _formatTime(context, otherParticipant.lastSeen!),
          },
        );
      }
    }

    if (conversation.description?.trim().isNotEmpty == true) {
      return conversation.description!.trim();
    }

    return context.tr(
      'chat.newConversation.membersCount',
      params: {'count': conversation.participants.length},
    );
  }

  /// العربية: ينسق time.
  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return context.tr('chat.thread.yesterday');
    } else if (now.difference(dateTime).inDays < 7) {
      switch (dateTime.weekday) {
        case DateTime.monday:
          return context.tr('chat.thread.days.monday');
        case DateTime.tuesday:
          return context.tr('chat.thread.days.tuesday');
        case DateTime.wednesday:
          return context.tr('chat.thread.days.wednesday');
        case DateTime.thursday:
          return context.tr('chat.thread.days.thursday');
        case DateTime.friday:
          return context.tr('chat.thread.days.friday');
        case DateTime.saturday:
          return context.tr('chat.thread.days.saturday');
        default:
          return context.tr('chat.thread.days.sunday');
      }
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// العربية: يعيد initials.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '؟';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
