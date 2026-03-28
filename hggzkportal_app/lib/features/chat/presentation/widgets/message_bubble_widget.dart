import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/attachment.dart';
import '../bloc/chat_bloc.dart';
import 'message_status_indicator.dart';
import 'reaction_picker_widget.dart';
import 'attachment_preview_widget.dart';
import 'audio_message_widget.dart';

/// يعرّف الكلاس `MessageBubbleWidget`.
/// Describes the `MessageBubbleWidget` class.
class MessageBubbleWidget extends StatefulWidget {
  /// Holds the `message` value.
  /// العربية: يخزن القيمة `message`.
  final Message message;

  /// يخزن العضو `isMe`.
  /// Holds the `isMe` member.
  final bool isMe;

  /// يخزن العضو `previousMessage`.
  /// Holds the `previousMessage` member.
  final Message? previousMessage;

  /// يخزن العضو `nextMessage`.
  /// Holds the `nextMessage` member.
  final Message? nextMessage;

  /// يخزن العضو `onReply`.
  /// Holds the `onReply` member.
  final VoidCallback? onReply;

  /// يخزن العضو `onEdit`.
  /// Holds the `onEdit` member.
  final VoidCallback? onEdit;

  /// يخزن العضو `onDelete`.
  /// Holds the `onDelete` member.
  final VoidCallback? onDelete;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(String)? onReaction;

  /// يخزن العضو `onReplyTap`.
  /// Holds the `onReplyTap` member.
  final VoidCallback? onReplyTap;

  /// ينشئ مثيلاً من `MessageBubbleWidget`.
  /// Builds an instance of `MessageBubbleWidget`.
  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.previousMessage,
    this.nextMessage,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onReaction,
    this.onReplyTap,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<MessageBubbleWidget> createState() => _MessageBubbleWidgetState();
}

/// يعرّف الكلاس `_MessageBubbleWidgetState`.
/// Describes the `_MessageBubbleWidgetState` class.
class _MessageBubbleWidgetState extends State<MessageBubbleWidget>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// يخزن العضو `_showReactions`.
  /// Holds the `_showReactions` member.
  bool _showReactions = false;

  // WhatsApp Colors
  /// يعيد قيمة `_bubbleColor`.
  /// Exposes the `_bubbleColor` value.
  Color get _bubbleColor {
    if (widget.isMe) {
      return AppTheme.isDark
          ? const Color(0xFF005C4B) // WhatsApp dark green
          : const Color(0xFFDCF8C6); // WhatsApp light green
    } else {
      return AppTheme.isDark
          ? const Color(0xFF1F2C34) // WhatsApp dark gray
          : const Color(0xFFFFFFFF); // White
    }
  }

  /// يعيد قيمة `_textColor`.
  /// Exposes the `_textColor` value.
  Color get _textColor {
    if (widget.isMe) {
      return AppTheme.isDark ? Colors.white : const Color(0xFF1F2C34);
    } else {
      return AppTheme.isDark
          ? const Color(0xFFE9EDEF)
          : const Color(0xFF1F2C34);
    }
  }

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// يعيد قيمة `_isFirstInGroup`.
  /// Exposes the `_isFirstInGroup` value.
  bool get _isFirstInGroup {
    if (widget.previousMessage == null) return true;
    return widget.previousMessage!.senderId != widget.message.senderId ||
        widget.message.createdAt
                .difference(widget.previousMessage!.createdAt)
                .inMinutes >
            5;
  }

  /// يعيد قيمة `_isLastInGroup`.
  /// Exposes the `_isLastInGroup` value.
  bool get _isLastInGroup {
    if (widget.nextMessage == null) return true;
    return widget.nextMessage!.senderId != widget.message.senderId ||
        widget.nextMessage!.createdAt
                .difference(widget.message.createdAt)
                .inMinutes >
            5;
  }

  /// ينفذ العملية `_findReplyMessage`.
  /// Runs the `_findReplyMessage` operation.
  Message? _findReplyMessage() {
    final replyId = widget.message.replyToMessageId;
    if (replyId == null) return null;

    final chatBloc = context.read<ChatBloc>();
    final chatState = chatBloc.state;
    if (chatState is! ChatLoaded) return null;

    final List<Message> messages =
        (chatState.messages[widget.message.conversationId] ?? [])
            .cast<Message>();

    for (final m in messages) {
      if (m.id == replyId) return m;
    }
    return null;
  }

  /// ينفذ العملية `_cleanContent`.
  /// Runs the `_cleanContent` operation.
  String _cleanContent(String? content) {
    if (content == null) return '';
    if (content.startsWith('::attref=')) {
      final endIdx = content.indexOf('::', '::attref='.length);
      if (endIdx > '::attref='.length) {
        return content.substring(endIdx + 2).trim();
      }
    }
    return content.trim();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    // Check if this is an audio message
    final bool isAudioMessage = widget.message.messageType == 'audio' ||
        (widget.message.attachments.isNotEmpty &&
            widget.message.attachments.first.isAudio);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            top: _isFirstInGroup ? 8 : 2,
            bottom: _isLastInGroup ? 8 : 2,
            left: widget.isMe ? MediaQuery.of(context).size.width * 0.15 : 12,
            right: widget.isMe ? 12 : MediaQuery.of(context).size.width * 0.15,
          ),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: _showOptions,
                onDoubleTap: _handleDoubleTap,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                    minWidth: isAudioMessage ? 250 : 0,
                  ),
                  child: CustomPaint(
                    painter: _BubblePainter(
                      color: _bubbleColor,
                      isMe: widget.isMe,
                      hasNip: _isLastInGroup,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                        left: widget.isMe ? 8 : 12,
                        right: widget.isMe ? 12 : 8,
                        top: 6,
                        bottom: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.message.replyToMessageId != null)
                            _buildReplyPreview(),
                          if (isAudioMessage)
                            _buildAudioMessage()
                          else
                            _buildMessageContent(),
                          const SizedBox(height: 2),
                          _buildMessageFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.message.reactions.isNotEmpty || _showReactions)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _showReactions
                      ? ReactionPickerWidget(
                          onReaction: (reaction) {
                            widget.onReaction?.call(reaction);
                            setState(() => _showReactions = false);
                          },
                        )
                      : _buildMinimalReactions(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildAudioMessage`.
  /// Runs the `_buildAudioMessage` operation.
  Widget _buildAudioMessage() {
    Attachment? audioAttachment;

    for (final attachment in widget.message.attachments) {
      if (attachment.isAudio ||
          attachment.contentType.startsWith('audio/') ||
          _isAudioExtension(attachment.fileName)) {
        audioAttachment = attachment;
        break;
      }
    }

    audioAttachment ??= widget.message.attachments.isNotEmpty
        ? widget.message.attachments.first
        : null;

    if (audioAttachment == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: _textColor.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'لا يمكن تحميل الملف الصوتي',
              style: AppTextStyles.bodySmall.copyWith(
                color: _textColor.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // احصل على معلومات المرسل من ChatBloc
    String? senderName;
    String? senderAvatar;

    if (!widget.isMe) {
      final chatBloc = context.read<ChatBloc>();
      final chatState = chatBloc.state;
      if (chatState is ChatLoaded) {
        // ابحث عن المحادثة الحالية بدون orElse لتجنب اختلاف الأنواع
        final convList = chatState.conversations;
        var convCandidates = convList.where(
          (c) => c.id == widget.message.conversationId,
        );
        final conversation = convCandidates.isNotEmpty
            ? convCandidates.first
            : (convList.isNotEmpty ? convList.first : null);

        if (conversation != null) {
          // احصل على معلومات المرسل من المشاركين بدون orElse
          final parts = conversation.participants;
          final senderCandidates = parts.where(
            (p) => p.id == widget.message.senderId,
          );
          final sender = senderCandidates.isNotEmpty
              ? senderCandidates.first
              : (parts.isNotEmpty ? parts.first : null);

          if (sender != null) {
            senderName = sender.name;
            senderAvatar = sender.profileImage;
          }
        }
      }
    }

    return AudioMessageWidget(
      attachment: audioAttachment,
      isMe: widget.isMe,
      bubbleColor: _bubbleColor,
      waveformColor: widget.isMe
          ? (AppTheme.isDark
              ? const Color(0xFF054640)
              : const Color(0xFF054640))
          : (AppTheme.isDark
              ? const Color(0xFF06CF9C)
              : const Color(0xFF06CF9C)),
      senderName: senderName ?? widget.message.senderName,
      senderAvatar: senderAvatar,
    );
  }

  /// ينفذ العملية `_buildReplyPreview`.
  /// Runs the `_buildReplyPreview` operation.
  Widget _buildReplyPreview() {
    final replyMessage = _findReplyMessage();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onReplyTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isMe
                ? const Color(0xFF00483B).withValues(alpha: 0.3)
                : const Color(0xFF000000).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: widget.isMe
                    ? const Color(0xFF7FC15E)
                    : AppTheme.primaryBlue,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                replyMessage?.senderName ?? 'Unknown',
                style: AppTextStyles.caption.copyWith(
                  color: widget.isMe
                      ? const Color(0xFF7FC15E)
                      : AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _cleanContent(replyMessage?.content),
                style: AppTextStyles.bodySmall.copyWith(
                  color: _textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildMessageContent`.
  /// Runs the `_buildMessageContent` operation.
  Widget _buildMessageContent() {
    if (widget.message.isDeleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block,
            size: 14,
            color: _textColor.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            'تم حذف هذه الرسالة',
            style: AppTextStyles.bodySmall.copyWith(
              color: _textColor.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    final displayContent = _cleanContent(widget.message.content);
    final nonImageAttachments = widget.message.attachments
        .where((a) => !a.isImage && !a.isAudio)
        .toList();

    if (displayContent.isEmpty && widget.message.attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayContent.isNotEmpty)
          Text(
            displayContent,
            style: AppTextStyles.bodyMedium.copyWith(
              color: _textColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        if (nonImageAttachments.isNotEmpty && displayContent.isNotEmpty)
          const SizedBox(height: 8),
        ...nonImageAttachments.map((att) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AttachmentPreviewWidget(
                attachment: att,
                isMe: widget.isMe,
                onTap: () {},
              ),
            )),
      ],
    );
  }

  /// ينفذ العملية `_buildMessageFooter`.
  /// Runs the `_buildMessageFooter` operation.
  Widget _buildMessageFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.message.isEdited) ...[
          Text(
            'معدّل',
            style: AppTextStyles.caption.copyWith(
              color: _textColor.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          _formatTime(widget.message.createdAt),
          style: AppTextStyles.caption.copyWith(
            color: _textColor.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        if (widget.isMe) ...[
          const SizedBox(width: 4),
          if (widget.message.status == 'failed')
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<ChatBloc>().add(
                      RetryFailedMessageEvent(
                        conversationId: widget.message.conversationId,
                        messageId: widget.message.id,
                      ),
                    );
              },
              child: MessageStatusIndicator(
                status: widget.message.status,
                color: AppTheme.error,
                size: 14,
              ),
            )
          else
            MessageStatusIndicator(
              status: widget.message.status,
              color: widget.message.status == 'read'
                  ? const Color(0xFF53BDEB)
                  : _textColor.withValues(alpha: 0.6),
              size: 14,
            ),
        ],
      ],
    );
  }

  /// ينفذ العملية `_buildMinimalReactions`.
  /// Runs the `_buildMinimalReactions` operation.
  Widget _buildMinimalReactions() {
    final groupedReactions = <String, int>{};
    for (final reaction in widget.message.reactions) {
      groupedReactions[reaction.reactionType] =
          (groupedReactions[reaction.reactionType] ?? 0) + 1;
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: groupedReactions.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getEmojiForReaction(entry.key),
                  style: const TextStyle(fontSize: 12)),
              if (entry.value > 1) ...[
                const SizedBox(width: 3),
                Text(
                  entry.value.toString(),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// ينفذ العملية `_showOptions`.
  /// Runs the `_showOptions` operation.
  void _showOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _MessageOptionsSheet(
          isMe: widget.isMe,
          onReply: widget.onReply,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
        );
      },
    );
  }

  /// ينفذ العملية `_handleDoubleTap`.
  /// Runs the `_handleDoubleTap` operation.
  void _handleDoubleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  /// ينفذ العملية `_getEmojiForReaction`.
  /// Runs the `_getEmojiForReaction` operation.
  String _getEmojiForReaction(String reactionType) {
    switch (reactionType) {
      case 'like':
        return '👍';
      case 'love':
        return '❤️';
      case 'laugh':
        return '😂';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'wow':
        return '😮';
      default:
        return '👍';
    }
  }

  /// ينفذ العملية `_formatTime`.
  /// Runs the `_formatTime` operation.
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// ينفذ العملية `_isAudioExtension`.
  /// Runs the `_isAudioExtension` operation.
  bool _isAudioExtension(String? fileName) {
    if (fileName == null || fileName.trim().isEmpty) {
      return false;
    }

    final normalizedName =
        fileName.split('/').last.split('\\').last.split('?').first.trim();

    if (!normalizedName.contains('.')) {
      return false;
    }

    final extension = normalizedName
        .substring(normalizedName.lastIndexOf('.') + 1)
        .toLowerCase();

    const audioExtensions = <String>{
      'mp3',
      'wav',
      'aac',
      'm4a',
      'ogg',
      'oga',
      'opus',
      'flac',
      'amr',
      'wma',
      'aiff',
      'caf',
    };

    return audioExtensions.contains(extension);
  }
}

// Custom painter for WhatsApp-style bubble with tail
/// يعرّف الكلاس `_BubblePainter`.
/// Describes the `_BubblePainter` class.
class _BubblePainter extends CustomPainter {
  /// Holds the `color` value.
  /// العربية: يخزن القيمة `color`.
  final Color color;

  /// يخزن العضو `isMe`.
  /// Holds the `isMe` member.
  final bool isMe;

  /// يخزن العضو `hasNip`.
  /// Holds the `hasNip` member.
  final bool hasNip;

  /// ينشئ مثيلاً من `_BubblePainter`.
  /// Builds an instance of `_BubblePainter`.
  _BubblePainter({
    required this.color,
    required this.isMe,
    required this.hasNip,
  });

  /// ينفذ العملية `paint`.
  /// Runs the `paint` operation.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = Radius.circular(12);
    const smallRadius = Radius.circular(6);

    if (isMe) {
      // Right-aligned bubble with tail
      path.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width - 8, size.height),
        topLeft: radius,
        topRight: hasNip ? smallRadius : radius,
        bottomLeft: radius,
        bottomRight: radius,
      ));

      if (hasNip) {
        // Add tail
        path.moveTo(size.width - 8, 10);
        path.lineTo(size.width, 0);
        path.lineTo(size.width - 8, 3);
      }
    } else {
      // Left-aligned bubble with tail
      path.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(8, 0, size.width - 8, size.height),
        topLeft: hasNip ? smallRadius : radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ));

      if (hasNip) {
        // Add tail
        path.moveTo(8, 10);
        path.lineTo(0, 0);
        path.lineTo(8, 3);
      }
    }

    canvas.drawPath(path, paint);
  }

  /// ينفذ العملية `shouldRepaint`.
  /// Runs the `shouldRepaint` operation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bottom Sheet for message options
/// يعرّف الكلاس `_MessageOptionsSheet`.
/// Describes the `_MessageOptionsSheet` class.
class _MessageOptionsSheet extends StatelessWidget {
  /// Indicates whether `isMe` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isMe` مفعلة.
  final bool isMe;

  /// يخزن العضو `onReply`.
  /// Holds the `onReply` member.
  final VoidCallback? onReply;

  /// يخزن العضو `onEdit`.
  /// Holds the `onEdit` member.
  final VoidCallback? onEdit;

  /// يخزن العضو `onDelete`.
  /// Holds the `onDelete` member.
  final VoidCallback? onDelete;

  /// ينشئ مثيلاً من `_MessageOptionsSheet`.
  /// Builds an instance of `_MessageOptionsSheet`.
  const _MessageOptionsSheet({
    required this.isMe,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.isDark
                    ? const Color(0xFF8696A0)
                    : const Color(0xFFD1D7DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (onReply != null)
              _buildOption(
                context,
                icon: Icons.reply_rounded,
                title: 'رد',
                onTap: () {
                  Navigator.pop(context);
                  onReply!();
                },
              ),
            if (isMe && onEdit != null)
              _buildOption(
                context,
                icon: Icons.edit_rounded,
                title: 'تعديل',
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            _buildOption(
              context,
              icon: Icons.copy_rounded,
              title: 'نسخ',
              onTap: () {
                Navigator.pop(context);
                // Copy logic
              },
            ),
            if (isMe && onDelete != null)
              _buildOption(
                context,
                icon: Icons.delete_rounded,
                title: 'حذف',
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
                isDestructive: true,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildOption`.
  /// Runs the `_buildOption` operation.
  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFEF4444)
                  : (AppTheme.isDark
                      ? const Color(0xFFE9EDEF)
                      : const Color(0xFF667781)),
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDestructive
                    ? const Color(0xFFEF4444)
                    : (AppTheme.isDark
                        ? const Color(0xFFE9EDEF)
                        : const Color(0xFF111B21)),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
