import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/conversation.dart';

/// Top bar for a one-to-one or group chat. It combines navigation, identity,
/// and high-value actions in a compact header.
/// شريط علوي للمحادثة الفردية أو الجماعية. يجمع بين التنقل وهوية الطرف
/// الآخر والإجراءات الأساسية في مساحة واحدة مضغوطة.
class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Conversation currently shown in the chat screen.
  /// المحادثة المعروضة حاليًا داخل شاشة الدردشة.
  final Conversation conversation;

  /// Current user id used to resolve the other participant in direct chats.
  /// معرّف المستخدم الحالي المستخدم لتحديد الطرف الآخر في المحادثات الثنائية.
  final String currentUserId;

  /// Navigates back to the previous screen.
  /// ينقل المستخدم إلى الشاشة السابقة.
  final VoidCallback onBackPressed;

  /// Opens the conversation info or settings surface.
  /// يفتح شاشة معلومات المحادثة أو إعداداتها.
  final VoidCallback onInfoPressed;

  /// Starts an audio call when that action is supported for the thread.
  /// يبدأ مكالمة صوتية عندما يدعمها هذا المسار.
  final VoidCallback? onCallPressed;

  /// Starts a video call when that action is available.
  /// يبدأ مكالمة فيديو عندما تكون متاحة.
  final VoidCallback? onVideoCallPressed;

  /// Builds the chat header with navigation and optional communication
  /// shortcuts.
  /// ينشئ رأس المحادثة مع التنقل واختصارات الاتصال الاختيارية.
  const ChatAppBar({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onBackPressed,
    required this.onInfoPressed,
    this.onCallPressed,
    this.onVideoCallPressed,
  });

  /// Exposes the height expected by `Scaffold.appBar`.
  /// يحدد الارتفاع المتوقع من `Scaffold.appBar`.
  @override
  Size get preferredSize => const Size.fromHeight(52);

  /// Creates the state object that drives header animations.
  /// ينشئ كائن الحالة الذي يدير حركات الرأس.
  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

/// Controls the animated avatar glow and the compact action buttons in the
/// chat header.
/// يدير توهج الصورة المتحركة وأزرار الإجراءات المدمجة داخل رأس المحادثة.
class _ChatAppBarState extends State<ChatAppBar>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the avatar glow effect.
  /// متحكم الحركة الخاص بتأثير التوهج حول الصورة.
  late AnimationController _glowController;

  /// Drives the soft pulsing glow around the contact avatar.
  /// يقود النبض الخفيف حول صورة الطرف الآخر.
  late Animation<double> _glowAnimation;

  /// Prepares the glow animation before the header is rendered.
  /// يهيئ حركة التوهج قبل رسم الرأس.
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  /// Releases the animation controller owned by the header.
  /// يحرر متحكم الحركة المملوك لرأس المحادثة.
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  /// Renders the header content, optional status line, and compact actions.
  /// يرسم محتوى الرأس، وسطر الحالة، والأزرار المضغوطة الاختيارية.
  @override
  Widget build(BuildContext context) {
    final otherParticipant = widget.conversation.isDirectChat
        ? widget.conversation.getOtherParticipant(widget.currentUserId)
        : null;

    final displayName = widget.conversation.title ??
        otherParticipant?.name ??
        context.tr('chat.message.conversationFallback');

    final displayImage =
        widget.conversation.avatar ?? otherParticipant?.profileImage;

    final statusText = _getStatusText(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withOpacity(0.85),
                AppTheme.darkCard.withOpacity(0.8),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.05),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  // Back button - Premium minimal style
                  _buildMinimalIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: widget.onBackPressed,
                    size: 16,
                  ),

                  const SizedBox(width: 6),

                  // User info - Compact and elegant
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onInfoPressed();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          _buildPremiumAvatar(displayImage, displayName),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppTheme.textWhite.withOpacity(0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (statusText != null)
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: AppTextStyles.caption.copyWith(
                                      color: _getStatusColor(),
                                      fontSize: 9,
                                    ),
                                    child: Text(
                                      statusText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons - Minimal style
                  if (widget.onCallPressed != null)
                    _buildMinimalIconButton(
                      icon: Icons.call_rounded,
                      onPressed: widget.onCallPressed!,
                      size: 18,
                    ),
                  if (widget.onVideoCallPressed != null)
                    _buildMinimalIconButton(
                      icon: Icons.videocam_rounded,
                      onPressed: widget.onVideoCallPressed!,
                      size: 18,
                    ),
                  _buildMinimalIconButton(
                    icon: Icons.more_vert_rounded,
                    onPressed: widget.onInfoPressed,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the compact icon button used by the header actions.
  /// ينشئ زر الأيقونة المدمج المستخدم في إجراءات الرأس.
  Widget _buildMinimalIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 32, // Reduced from 36
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.03),
              Colors.white.withOpacity(0.01),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: size,
          color: AppTheme.textWhite.withOpacity(0.7),
        ),
      ),
    );
  }

  /// Builds the animated avatar that represents the current conversation.
  /// ينشئ الصورة المتحركة التي تمثل المحادثة الحالية.
  Widget _buildPremiumAvatar(String? imageUrl, String name) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              width: 34, // Reduced from 36
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.08),
                    AppTheme.primaryPurple.withOpacity(0.04),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(
                      0.05 * _glowAnimation.value,
                    ),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: imageUrl != null
                  ? ClipOval(
                      child: CachedImageWidget(
                        imageUrl: imageUrl,
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        _getInitials(name),
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.primaryBlue.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
            ),
            if (widget.conversation.isDirectChat)
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildMinimalOnlineIndicator(),
              ),
          ],
        );
      },
    );
  }

  /// Builds the compact online indicator shown beside direct chats.
  /// ينشئ مؤشر الاتصال المضغوط الذي يظهر بجانب المحادثات الثنائية.
  Widget _buildMinimalOnlineIndicator() {
    final otherParticipant =
        widget.conversation.getOtherParticipant(widget.currentUserId);
    if (otherParticipant == null || !otherParticipant.isOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 7, // Reduced from 8
          height: 7,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.success.withOpacity(0.9),
                AppTheme.neonGreen.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.darkCard,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.success.withOpacity(
                  0.3 + 0.1 * _glowAnimation.value,
                ),
                blurRadius: 3 + 2 * _glowAnimation.value,
                spreadRadius: 0.3,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Resolves the human-readable presence label for the active participant.
  /// يحدد تسمية الحضور المقروءة للطرف النشط.
  String? _getStatusText(BuildContext context) {
    if (widget.conversation.isDirectChat) {
      final otherParticipant =
          widget.conversation.getOtherParticipant(widget.currentUserId);
      if (otherParticipant == null) return null;

      if (otherParticipant.isOnline) {
        return context.tr(
          'chat.participant.onlineNow',
        );
      } else if (otherParticipant.lastSeen != null) {
        return _formatLastSeen(context, otherParticipant.lastSeen!);
      }
    } else {
      final onlineCount = widget.conversation.participants
          .where((p) => p.isOnline && p.id != widget.currentUserId)
          .length;
      if (onlineCount > 0) {
        return context.tr(
          'chat.thread.onlineCount',
          params: {'count': onlineCount},
        );
      }
    }
    return null;
  }

  /// Resolves the color used to paint the presence label.
  /// يحدد اللون المستخدم لعرض تسمية الحضور.
  Color _getStatusColor() {
    final otherParticipant = widget.conversation.isDirectChat
        ? widget.conversation.getOtherParticipant(widget.currentUserId)
        : null;

    if (otherParticipant?.isOnline == true) {
      return AppTheme.success.withOpacity(0.8);
    }
    return AppTheme.textMuted.withOpacity(0.6);
  }

  /// Formats last-seen time into a compact relative label.
  /// ينسق وقت آخر ظهور إلى تسمية نسبية مختصرة.
  String _formatLastSeen(BuildContext context, DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return context.tr('chat.participant.now');
    } else if (difference.inMinutes < 60) {
      return context.tr(
        'chat.participant.minuteAgo',
        params: {'value': difference.inMinutes},
      );
    } else if (difference.inHours < 24) {
      return context.tr(
        'chat.participant.hourAgo',
        params: {'value': difference.inHours},
      );
    } else if (difference.inDays == 1) {
      return context.tr('chat.thread.yesterday');
    } else {
      return context.tr(
        'chat.participant.dayAgo',
        params: {'value': difference.inDays},
      );
    }
  }

  /// Returns initials for fallback avatar rendering.
  /// يعيد الأحرف الأولى لاستخدامها عند غياب الصورة.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
