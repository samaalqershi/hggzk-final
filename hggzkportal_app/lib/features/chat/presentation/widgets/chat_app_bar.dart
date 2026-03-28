import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/conversation.dart';

/// يعرّف الكلاس `ChatAppBar`.
/// Describes the `ChatAppBar` class.
class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Holds the `conversation` value.
  /// العربية: يخزن القيمة `conversation`.
  final Conversation conversation;

  /// يخزن العضو `currentUserId`.
  /// Holds the `currentUserId` member.
  final String currentUserId;

  /// يخزن العضو `onBackPressed`.
  /// Holds the `onBackPressed` member.
  final VoidCallback onBackPressed;

  /// يخزن العضو `onInfoPressed`.
  /// Holds the `onInfoPressed` member.
  final VoidCallback onInfoPressed;

  /// يخزن العضو `onCallPressed`.
  /// Holds the `onCallPressed` member.
  final VoidCallback? onCallPressed;

  /// يخزن العضو `onVideoCallPressed`.
  /// Holds the `onVideoCallPressed` member.
  final VoidCallback? onVideoCallPressed;

  /// ينشئ مثيلاً من `ChatAppBar`.
  /// Builds an instance of `ChatAppBar`.
  const ChatAppBar({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onBackPressed,
    required this.onInfoPressed,
    this.onCallPressed,
    this.onVideoCallPressed,
  });

  /// يعيد قيمة `preferredSize`.
  /// Exposes the `preferredSize` value.
  @override
  Size get preferredSize => const Size.fromHeight(52); // Reduced from 56

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

/// يعرّف الكلاس `_ChatAppBarState`.
/// Describes the `_ChatAppBarState` class.
class _ChatAppBarState extends State<ChatAppBar>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_glowController`.
  /// Holds the `_glowController` member.
  late AnimationController _glowController;

  /// يخزن العضو `_glowAnimation`.
  /// Holds the `_glowAnimation` member.
  late Animation<double> _glowAnimation;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
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

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    final otherParticipant = widget.conversation.isDirectChat
        ? widget.conversation.getOtherParticipant(widget.currentUserId)
        : null;

    final displayName =
        widget.conversation.title ?? otherParticipant?.name ?? 'محادثة';

    final displayImage =
        widget.conversation.avatar ?? otherParticipant?.profileImage;

    final statusText = _getStatusText();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.85),
                AppTheme.darkCard.withValues(alpha: 0.8),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.05),
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
                                    color: AppTheme.textWhite
                                        .withValues(alpha: 0.9),
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

  /// ينفذ العملية `_buildMinimalIconButton`.
  /// Runs the `_buildMinimalIconButton` operation.
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
              Colors.white.withValues(alpha: 0.03),
              Colors.white.withValues(alpha: 0.01),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: size,
          color: AppTheme.textWhite.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildPremiumAvatar`.
  /// Runs the `_buildPremiumAvatar` operation.
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
                    AppTheme.primaryBlue.withValues(alpha: 0.08),
                    AppTheme.primaryPurple.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(
                      alpha: 0.05 * _glowAnimation.value,
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
                          color: AppTheme.primaryBlue.withValues(alpha: 0.8),
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

  /// ينفذ العملية `_buildMinimalOnlineIndicator`.
  /// Runs the `_buildMinimalOnlineIndicator` operation.
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
                AppTheme.success.withValues(alpha: 0.9),
                AppTheme.neonGreen.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.darkCard,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.success.withValues(
                  alpha: 0.3 + 0.1 * _glowAnimation.value,
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

  /// ينفذ العملية `_getStatusText`.
  /// Runs the `_getStatusText` operation.
  String? _getStatusText() {
    if (widget.conversation.isDirectChat) {
      final otherParticipant =
          widget.conversation.getOtherParticipant(widget.currentUserId);
      if (otherParticipant == null) return null;

      if (otherParticipant.isOnline) {
        return 'متصل';
      } else if (otherParticipant.lastSeen != null) {
        return _formatLastSeen(otherParticipant.lastSeen!);
      }
    } else {
      final onlineCount = widget.conversation.participants
          .where((p) => p.isOnline && p.id != widget.currentUserId)
          .length;
      if (onlineCount > 0) {
        return '$onlineCount متصل';
      }
    }
    return null;
  }

  /// ينفذ العملية `_getStatusColor`.
  /// Runs the `_getStatusColor` operation.
  Color _getStatusColor() {
    final otherParticipant = widget.conversation.isDirectChat
        ? widget.conversation.getOtherParticipant(widget.currentUserId)
        : null;

    if (otherParticipant?.isOnline == true) {
      return AppTheme.success.withValues(alpha: 0.8);
    }
    return AppTheme.textMuted.withValues(alpha: 0.6);
  }

  /// ينفذ العملية `_formatLastSeen`.
  /// Runs the `_formatLastSeen` operation.
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes}د';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours}س';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else {
      return 'منذ ${difference.inDays}ي';
    }
  }

  /// ينفذ العملية `_getInitials`.
  /// Runs the `_getInitials` operation.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
