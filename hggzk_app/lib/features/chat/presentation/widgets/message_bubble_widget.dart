import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/message.dart';
import 'attachment_preview_widget.dart';
import 'message_status_indicator.dart';
import 'reaction_picker_widget.dart';

/// Renders one chat message bubble with replies, attachments, reactions, and
/// action affordances.
/// يرسم فقاعة رسالة واحدة مع الردود والمرفقات والتفاعلات وأفعال الرسالة.
class MessageBubbleWidget extends StatefulWidget {
  /// Message being rendered in the bubble.
  /// الرسالة التي تُعرض داخل الفقاعة.
  final Message message;

  /// True when the bubble belongs to the current user.
  /// تكون صحيحة عندما تعود الفقاعة للمستخدم الحالي.
  final bool isMe;

  /// Previous message used to decide grouping and tail visibility.
  /// الرسالة السابقة المستخدمة لتحديد التجميع وإظهار الذيل.
  final Message? previousMessage;

  /// Next message used to decide grouping and tail visibility.
  /// الرسالة التالية المستخدمة لتحديد التجميع وإظهار الذيل.
  final Message? nextMessage;

  /// Opens the reply composer for this message.
  /// يفتح محرر الرد لهذه الرسالة.
  final VoidCallback? onReply;

  /// Opens edit mode for this message.
  /// يفتح وضع التعديل لهذه الرسالة.
  final VoidCallback? onEdit;

  /// Deletes the message when the user confirms the action.
  /// يحذف الرسالة عند تأكيد المستخدم.
  final VoidCallback? onDelete;

  /// Applies a reaction picked from the inline reaction tray.
  /// يضيف تفاعلًا مختارًا من درج التفاعلات المضمّن.
  final Function(String)? onReaction;

  /// Opens the referenced reply when the user taps the quoted preview.
  /// يفتح الرد المشار إليه عندما ينقر المستخدم على المعاينة المقتبسة.
  final VoidCallback? onReplyTap;

  /// Builds one message bubble with optional reaction support.
  /// ينشئ فقاعة رسالة واحدة مع دعم اختياري للتفاعلات.
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

  /// Creates the state object for this widget.
  /// ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<MessageBubbleWidget> createState() => _MessageBubbleWidgetState();
}

/// Animates the message entrance and manages inline reaction visibility.
/// يحرك ظهور الرسالة ويدير ظهور درج التفاعلات المضمّن.
class _MessageBubbleWidgetState extends State<MessageBubbleWidget>
    with SingleTickerProviderStateMixin {
  /// Drives the bubble entrance animation.
  /// يقود حركة ظهور الفقاعة.
  late AnimationController _animationController;

  /// Scales the bubble slightly as it enters the viewport.
  /// يكبّر الفقاعة قليلًا أثناء دخولها إلى الشاشة.
  late Animation<double> _scaleAnimation;

  /// Fades the bubble into view.
  /// يدرج الفقاعة إلى الواجهة بالتدريج.
  late Animation<double> _fadeAnimation;

  /// Tracks whether the reaction tray is visible.
  /// يتتبع ما إذا كان درج التفاعلات ظاهرًا.
  bool _showReactions = false;

  /// Starts the entrance animation when the widget mounts.
  /// يبدأ حركة الظهور عند تركيب العنصر.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
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

  /// Releases the animation controller owned by the bubble.
  /// يحرر متحكم الحركة المملوك للفقاعة.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Builds the bubble, attachment previews, footer, and reaction tray.
  /// يبني الفقاعة ومعاينات المرفقات والتذييل ودرج التفاعلات.
  @override
  Widget build(BuildContext context) {
    final showTail = _shouldShowTail();
    final borderRadius = _getBorderRadius(showTail);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        // FIXED: Remove alignment from ScaleTransition to preserve message position
        child: Container(
          margin: EdgeInsets.only(
            // FIXED: Proper margins for left/right alignment
            left: widget.isMe ? MediaQuery.of(context).size.width * 0.2 : 8,
            right: widget.isMe ? 8 : MediaQuery.of(context).size.width * 0.2,
            top: _getTopPadding(),
            bottom: 2,
          ),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: _showOptions,
                onDoubleTap: () {
                  if (widget.onReaction != null) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showReactions = !_showReactions;
                    });
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                        minWidth: 60,
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: widget.isMe ? 0 : 8,
                            sigmaY: widget.isMe ? 0 : 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: widget.isMe
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryBlue.withOpacity(0.9),
                                        AppTheme.primaryPurple
                                            .withOpacity(0.85),
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        AppTheme.darkCard.withOpacity(0.6),
                                        AppTheme.darkCard.withOpacity(0.4),
                                      ],
                                    ),
                              borderRadius: borderRadius,
                              border: Border.all(
                                color: widget.isMe
                                    ? Colors.white.withOpacity(0.08)
                                    : AppTheme.darkBorder.withOpacity(0.08),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isMe
                                      ? AppTheme.primaryBlue.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.message.replyToMessageId != null)
                                  _buildMinimalReplySection(),
                                _buildMessageContent(),
                                if (widget.message.attachments.isNotEmpty)
                                  _buildAttachments(),
                                _buildMinimalFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showTail) _buildMinimalTail(),
                  ],
                ),
              ),
              if (widget.message.reactions.isNotEmpty) _buildMinimalReactions(),
              if (_showReactions)
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    left: widget.isMe ? 0 : 8,
                    right: widget.isMe ? 8 : 0,
                  ),
                  child: ReactionPickerWidget(
                    onReaction: (reaction) {
                      widget.onReaction?.call(reaction);
                      setState(() {
                        _showReactions = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the quoted reply preview so users can jump back to the referenced
  /// message.
  /// ينشئ معاينة الرد المقتبس حتى يتمكن المستخدم من الرجوع إلى الرسالة
  /// المشار إليها.
  Widget _buildMinimalReplySection() {
    return GestureDetector(
      onTap: widget.onReplyTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isMe
                ? [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ]
                : [
                    AppTheme.primaryBlue.withOpacity(0.06),
                    AppTheme.primaryBlue.withOpacity(0.03),
                  ],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.isMe
                      ? [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.2),
                        ]
                      : [
                          AppTheme.primaryBlue.withOpacity(0.8),
                          AppTheme.primaryPurple.withOpacity(0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('chat.message.replyTo'),
                    style: AppTextStyles.caption.copyWith(
                      color: widget.isMe
                          ? Colors.white.withOpacity(0.6)
                          : AppTheme.primaryBlue.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    context.tr(
                      'chat.message.repliedContent',
                    ),
                    style: AppTextStyles.caption.copyWith(
                      color: widget.isMe
                          ? Colors.white.withOpacity(0.4)
                          : AppTheme.textMuted.withOpacity(0.5),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the message body or the special location payload for the bubble.
  /// يرسم نص الرسالة أو حمولة الموقع الخاصة بالفقاعة.
  Widget _buildMessageContent() {
    if (widget.message.messageType == 'text' &&
        widget.message.content != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        child: Text(
          widget.message.content!,
          style: AppTextStyles.bodySmall.copyWith(
            color: widget.isMe
                ? Colors.white
                : AppTheme.textWhite.withOpacity(0.85),
            height: 1.35,
            fontSize: 12,
          ),
        ),
      );
    }

    if (widget.message.messageType == 'location' &&
        widget.message.location != null) {
      return _buildMinimalLocationMessage();
    }

    return const SizedBox.shrink();
  }

  /// Renders the compact location card used for map-style chat messages.
  /// يرسم بطاقة الموقع المدمجة المستخدمة لرسائل المواقع.
  Widget _buildMinimalLocationMessage() {
    return Container(
      margin: const EdgeInsets.all(5),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Map placeholder
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.8),
                    AppTheme.darkCard.withOpacity(0.6),
                  ],
                ),
              ),
              child: Icon(
                Icons.map_rounded,
                size: 32,
                color: AppTheme.textMuted,
              ),
            ),

            // Glass overlay with location info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.8),
                                AppTheme.primaryPurple.withOpacity(0.6),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.message.location!.address ??
                                context.tr(
                                  'chat.message.location',
                                ),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders all attachments that belong to the message.
  /// يرسم كل المرفقات التابعة للرسالة.
  Widget _buildAttachments() {
    return Column(
      children: widget.message.attachments.map((attachment) {
        return AttachmentPreviewWidget(
          attachment: attachment,
          isMe: widget.isMe,
        );
      }).toList(),
    );
  }

  /// Renders timestamp, edit state, and delivery status for the bubble.
  /// يرسم الوقت وحالة التعديل وحالة التسليم داخل الفقاعة.
  Widget _buildMinimalFooter() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 5,
        bottom: 5,
        top: 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.message.isEdited)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Text(
                context.tr('chat.message.edited'),
                style: AppTextStyles.caption.copyWith(
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.4)
                      : AppTheme.textMuted.withOpacity(0.35),
                  fontSize: 8,
                ),
              ),
            ),
          Text(
            _formatTime(widget.message.createdAt),
            style: AppTextStyles.caption.copyWith(
              color: widget.isMe
                  ? Colors.white.withOpacity(0.5)
                  : AppTheme.textMuted.withOpacity(0.4),
              fontSize: 9,
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 2),
            MessageStatusIndicator(
              status: widget.message.status,
              color: Colors.white.withOpacity(0.5),
              size: 10,
            ),
          ],
        ],
      ),
    );
  }

  /// Renders the grouped reaction chips shown under the message.
  /// يرسم شرائح التفاعل المجمعة أسفل الرسالة.
  Widget _buildMinimalReactions() {
    final groupedReactions = <String, int>{};
    for (final reaction in widget.message.reactions) {
      groupedReactions[reaction.reactionType] =
          (groupedReactions[reaction.reactionType] ?? 0) + 1;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        left: widget.isMe ? 0 : 8,
        right: widget.isMe ? 8 : 0,
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: groupedReactions.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.5),
                  AppTheme.darkCard.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getEmojiForReaction(entry.key),
                  style: const TextStyle(fontSize: 10),
                ),
                if (entry.value > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    entry.value.toString(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textWhite.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the small tail pointer that visually anchors the bubble.
  /// ينشئ الذيل الصغير الذي يثبت الفقاعة بصريًا.
  Widget _buildMinimalTail() {
    return Positioned(
      bottom: 0,
      left: widget.isMe ? null : -5,
      right: widget.isMe ? -5 : null,
      child: CustomPaint(
        painter: _MinimalTailPainter(
          color: widget.isMe
              ? AppTheme.primaryPurple.withOpacity(0.85)
              : AppTheme.darkCard.withOpacity(0.6),
          isMe: widget.isMe,
        ),
        size: const Size(6, 10),
      ),
    );
  }

  /// Computes the bubble radius so grouped messages can connect cleanly.
  /// يحسب نصف قطر الفقاعة حتى تتصل الرسائل المجمعة بشكل متناسق.
  BorderRadius _getBorderRadius(bool showTail) {
    const radius = 8.0;
    const smallRadius = 2.0;

    if (widget.isMe) {
      return BorderRadius.only(
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomLeft: const Radius.circular(radius),
        bottomRight: Radius.circular(showTail ? smallRadius : radius),
      );
    } else {
      return BorderRadius.only(
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomLeft: Radius.circular(showTail ? smallRadius : radius),
        bottomRight: const Radius.circular(radius),
      );
    }
  }

  /// Decides whether the bubble should render a tail based on the next
  /// message in the thread.
  /// يقرر ما إذا كانت الفقاعة تحتاج ذيلًا بناءً على الرسالة التالية في
  /// السلسلة.
  bool _shouldShowTail() {
    if (widget.nextMessage == null) return true;
    if (widget.nextMessage!.senderId != widget.message.senderId) return true;

    final timeDiff = widget.message.createdAt
        .difference(widget.nextMessage!.createdAt)
        .inMinutes;
    return timeDiff > 1;
  }

  /// Computes top spacing so consecutive messages from the same sender stay
  /// visually compact.
  /// يحسب التباعد العلوي حتى تبقى الرسائل المتتالية من نفس المرسل متقاربة
  /// بصريًا.
  double _getTopPadding() {
    if (widget.previousMessage == null) return 8;
    if (widget.previousMessage!.senderId != widget.message.senderId) {
      return 8;
    }

    final timeDiff = widget.previousMessage!.createdAt
        .difference(widget.message.createdAt)
        .inMinutes;
    return timeDiff > 1 ? 8 : 1.5;
  }

  /// Opens the message action sheet for reply, edit, delete, and copy flows.
  /// يفتح ورقة إجراءات الرسالة لمسارات الرد والتعديل والحذف والنسخ.
  void _showOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MinimalMessageOptionsSheet(
        message: widget.message,
        isMe: widget.isMe,
        onReply: () {
          Navigator.pop(context);
          widget.onReply?.call();
        },
        onEdit: widget.onEdit != null
            ? () {
                Navigator.pop(context);
                widget.onEdit!();
              }
            : null,
        onDelete: widget.onDelete != null
            ? () {
                Navigator.pop(context);
                widget.onDelete!();
              }
            : null,
        onCopy: () {
          Navigator.pop(context);
          if (widget.message.content != null) {
            Clipboard.setData(ClipboardData(text: widget.message.content!));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr('chat.message.copied'),
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.darkCard.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.all(8),
              ),
            );
          }
        },
      ),
    );
  }

  /// Formats a timestamp into the compact clock label shown inside bubbles.
  /// ينسق الطابع الزمني إلى تسمية وقت مختصرة تظهر داخل الفقاعات.
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Resolves the emoji used for a reaction chip.
  /// يحدد الإيموجي المستخدم لشريحة التفاعل.
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
}

/// Paints the small triangular tail attached to a message bubble.
/// يرسم الذيل المثلث الصغير المرفق بفقاعة الرسالة.
class _MinimalTailPainter extends CustomPainter {
  /// Tail fill color.
  /// لون تعبئة الذيل.
  final Color color;

  /// Whether the bubble belongs to the current user.
  /// يحدد ما إذا كانت الفقاعة تخص المستخدم الحالي.
  final bool isMe;

  /// Builds the painter for the bubble tail.
  /// ينشئ الرسّام الخاص بذيل الفقاعة.
  _MinimalTailPainter({
    required this.color,
    required this.isMe,
  });

  /// Draws the tail path on the provided canvas.
  /// يرسم مسار الذيل على اللوحة المحددة.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isMe) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - 1.5);
      path.quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 3,
      );
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - 1.5);
      path.quadraticBezierTo(
        size.width / 2,
        size.height,
        0,
        size.height - 3,
      );
      path.lineTo(0, 0);
    }

    canvas.drawPath(path, paint);
  }

  /// The tail shape is static, so repainting is not required.
  /// شكل الذيل ثابت، لذلك لا حاجة لإعادة الرسم.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom sheet that exposes message-specific actions in a compact form.
/// ورقة سفلية تعرض إجراءات الرسالة بشكل مضغوط.
class _MinimalMessageOptionsSheet extends StatelessWidget {
  /// Message that the action sheet operates on.
  /// الرسالة التي تعمل عليها ورقة الإجراءات.
  final Message message;

  /// Whether the current user owns the message.
  /// يحدد ما إذا كان المستخدم الحالي يملك الرسالة.
  final bool isMe;

  /// Invoked when the user chooses to reply.
  /// يُستدعى عندما يختار المستخدم الرد.
  final VoidCallback? onReply;

  /// Invoked when the user chooses to edit.
  /// يُستدعى عندما يختار المستخدم التعديل.
  final VoidCallback? onEdit;

  /// Invoked when the user chooses to delete.
  /// يُستدعى عندما يختار المستخدم الحذف.
  final VoidCallback? onDelete;

  /// Invoked when the user chooses to copy message text.
  /// يُستدعى عندما يختار المستخدم نسخ النص.
  final VoidCallback? onCopy;

  /// Builds the compact message action sheet.
  /// ينشئ ورقة إجراءات الرسالة المدمجة.
  const _MinimalMessageOptionsSheet({
    required this.message,
    required this.isMe,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onCopy,
  });

  /// Renders the compact set of actions for one message.
  /// يرسم مجموعة الإجراءات المضغوطة لرسالة واحدة.
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withOpacity(0.85),
                AppTheme.darkCard.withOpacity(0.9),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkBorder.withOpacity(0.2),
                        AppTheme.darkBorder.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                if (onReply != null)
                  _buildOption(
                    icon: Icons.reply_rounded,
                    title: context.tr('chat.message.reply'),
                    onTap: onReply!,
                  ),
                if (message.content != null && onCopy != null)
                  _buildOption(
                    icon: Icons.copy_rounded,
                    title: context.tr('chat.message.copy'),
                    onTap: onCopy!,
                  ),
                if (isMe && onEdit != null)
                  _buildOption(
                    icon: Icons.edit_rounded,
                    title: context.tr('chat.message.edit'),
                    onTap: onEdit!,
                  ),
                if (isMe && onDelete != null)
                  _buildOption(
                    icon: Icons.delete_rounded,
                    title: context.tr('chat.message.delete'),
                    onTap: onDelete!,
                    isDestructive: true,
                  ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني option.
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDestructive
                      ? [
                          AppTheme.error.withOpacity(0.12),
                          AppTheme.error.withOpacity(0.06),
                        ]
                      : [
                          AppTheme.primaryBlue.withOpacity(0.08),
                          AppTheme.primaryPurple.withOpacity(0.04),
                        ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppTheme.error.withOpacity(0.8)
                    : AppTheme.primaryBlue.withOpacity(0.8),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDestructive
                    ? AppTheme.error.withOpacity(0.8)
                    : AppTheme.textWhite.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
