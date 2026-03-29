// lib/features/notifications/presentation/widgets/notification_item_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/notification.dart';

/// يعرض بطاقة إشعار واحدة مع إمكان فتحها أو تعليمها كمقروء أو إخفائها.
/// Renders a single notification card with open, mark-as-read, and dismiss
/// actions.
class NotificationItemWidget extends StatefulWidget {
  /// بيانات الإشعار المعروضة داخل البطاقة.
  /// Notification data rendered inside the card.
  final NotificationEntity notification;

  /// رد اختياري عند الضغط على البطاقة لفتح تفاصيل أو توجيه المستخدم.
  /// Optional callback triggered when the card is tapped to open details or
  /// navigate.
  final VoidCallback? onTap;

  /// رد اختياري عند إخفاء الإشعار من القائمة.
  /// Optional callback triggered when the notification is dismissed.
  final VoidCallback? onDismiss;

  /// رد اختياري عند تعليم الإشعار كمقروء.
  /// Optional callback triggered when the notification is marked as read.
  final VoidCallback? onMarkAsRead;

  /// ينشئ عنصر الإشعار مع بياناته وإجراءاته الاختيارية.
  /// Creates the notification item with its data and optional actions.
  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.onMarkAsRead,
  });

  /// ينشئ الحالة الخاصة بالتفاعل البصري للبطاقة.
  /// Creates the state responsible for the card's visual interaction.
  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

/// تدير حالة التحويم والإخفاء والتفاعل اللمسي داخل بطاقة الإشعار.
/// Manages hover, dismissal, and touch interaction inside the notification
/// card.
class _NotificationItemWidgetState extends State<NotificationItemWidget>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة المستخدم للتفاعلات البصرية الخفيفة.
  /// Animation controller used for subtle visual interactions.
  late AnimationController _animationController;

  /// يحدد ما إذا كانت البطاقة في حالة تفاعل بصري.
  /// Indicates whether the card is currently in a hovered or pressed state.
  bool _isHovered = false;

  /// يحدد ما إذا كان الإشعار قد أُخفي من القائمة محليًا.
  /// Indicates whether the notification has already been locally dismissed.
  bool _isDismissed = false;

  /// يهيئ متحكم الحركة عند إنشاء البطاقة.
  /// Initializes the animation controller when the card is created.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// يحرر متحكم الحركة عند إزالة البطاقة من الشجرة.
  /// Disposes the animation controller when the card leaves the tree.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// يبني بطاقة الإشعار بالحجم والتخطيط المناسبين حسب عرض المساحة.
  /// Builds the notification card using the layout that best matches the
  /// available width.
  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(widget.notification.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        onDismissed: (_) {
          setState(() => _isDismissed = true);
          widget.onDismiss?.call();
        },
        child: GestureDetector(
          onTap: _handleTap,
          onTapDown: (_) => _setHovered(true),
          onTapUp: (_) => _setHovered(false),
          onTapCancel: () => _setHovered(false),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowDark.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.notification.isRead
                          ? [
                              AppTheme.darkCard.withValues(alpha: 0.5),
                              AppTheme.darkCard.withValues(alpha: 0.3),
                            ]
                          : [
                              AppTheme.primaryBlue.withValues(alpha: 0.08),
                              AppTheme.primaryPurple.withValues(alpha: 0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.notification.isRead
                          ? AppTheme.darkBorder.withValues(alpha: 0.2)
                          : AppTheme.primaryBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 350;
                      return isCompact
                          ? _buildCompactContent()
                          : _buildFullContent();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يبني النسخة الكاملة من البطاقة للشاشات الأوسع.
  /// Builds the full-size card layout for wider screens.
  Widget _buildFullContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.notification.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: widget.notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(context, widget.notification.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.notification.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTypeChip(),
                    const Spacer(),
                    if (!widget.notification.isRead)
                      _buildActionButton(
                        icon: CupertinoIcons.check_mark,
                        onTap: widget.onMarkAsRead,
                        tooltip: context.tr(
                          'notifications.item.markRead',
                        ),
                      ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: CupertinoIcons.trash,
                      onTap: () {
                        setState(() => _isDismissed = true);
                        widget.onDismiss?.call();
                      },
                      tooltip: context.tr(
                        'notifications.item.delete',
                      ),
                      color: AppTheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يبني النسخة المضغوطة من البطاقة للمساحات الأصغر.
  /// Builds the compact card layout for narrower spaces.
  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIcon(size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notification.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: widget.notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(context, widget.notification.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.notification.message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeChip(isSmall: true),
              const Spacer(),
              if (!widget.notification.isRead)
                _buildCompactActionButton(
                  icon: CupertinoIcons.check_mark,
                  onTap: widget.onMarkAsRead,
                ),
              const SizedBox(width: 4),
              _buildCompactActionButton(
                icon: CupertinoIcons.trash,
                onTap: () {
                  setState(() => _isDismissed = true);
                  widget.onDismiss?.call();
                },
                color: AppTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// يبني أيقونة الإشعار المناسبة بحسب نوعه.
  /// Builds the notification icon that matches the notification type.
  Widget _buildIcon({double size = 48}) {
    final IconData icon;
    final List<Color> gradient;

    switch (widget.notification.type) {
      case 'booking':
        icon = CupertinoIcons.calendar;
        gradient = [AppTheme.info, AppTheme.neonBlue];
        break;
      case 'payment':
        icon = CupertinoIcons.creditcard_fill;
        gradient = [AppTheme.warning, const Color(0xFFFFD700)];
        break;
      case 'promotion':
        icon = CupertinoIcons.gift_fill;
        gradient = [AppTheme.error, const Color(0xFFFF69B4)];
        break;
      case 'system':
        icon = CupertinoIcons.gear_solid;
        gradient = [AppTheme.textMuted, AppTheme.darkBorder];
        break;
      default:
        icon = CupertinoIcons.bell_fill;
        gradient = [AppTheme.primaryBlue, AppTheme.primaryCyan];
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  /// يبني شارة نصية صغيرة توضّح تصنيف الإشعار.
  /// Builds a small text chip that communicates the notification category.
  Widget _buildTypeChip({bool isSmall = false}) {
    String label;
    switch (widget.notification.type) {
      case 'booking':
        label = context.tr('notifications.item.booking');
        break;
      case 'payment':
        label = context.tr('notifications.item.payment');
        break;
      case 'promotion':
        label = context.tr('notifications.item.promotion');
        break;
      case 'system':
        label = context.tr('notifications.item.system');
        break;
      default:
        label = context.tr('notifications.item.general');
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// يبني زر إجراء قياسي للنسخة الكاملة من البطاقة.
  /// Builds a standard action button for the full card layout.
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                icon,
                size: 14,
                color: color ?? AppTheme.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يبني زر إجراء مضغوط للنسخة الصغيرة من البطاقة.
  /// Builds a compact action button for the small card layout.
  Widget _buildCompactActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 12,
          color: color ?? AppTheme.primaryBlue,
        ),
      ),
    );
  }

  /// يبني خلفية السحب المستخدمة عند إخفاء الإشعار.
  /// Builds the swipe-to-dismiss background shown while dismissing.
  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.error.withValues(alpha: 0.1),
            AppTheme.error.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        CupertinoIcons.trash,
        color: AppTheme.error,
        size: 24,
      ),
    );
  }

  /// يحول وقت إنشاء الإشعار إلى صياغة زمنية مناسبة للواجهة.
  /// Converts the notification timestamp into a UI-friendly relative label.
  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return context.tr('notifications.item.now');
    } else if (difference.inMinutes < 60) {
      return context.tr(
        'notifications.item.agoMinutes',
        params: {'minutes': difference.inMinutes},
      );
    } else if (difference.inHours < 24) {
      return context.tr(
        'notifications.item.agoHours',
        params: {'hours': difference.inHours},
      );
    } else if (difference.inDays < 7) {
      return context.tr(
        'notifications.item.agoDays',
        params: {'days': difference.inDays},
      );
    } else {
      return Formatters.formatDate(dateTime);
    }
  }

  /// يعالج الضغط على البطاقة ويعلم الإشعار كمقروء قبل تمرير حدث الفتح.
  /// Handles tapping the card and marks the notification as read before
  /// forwarding the open action.
  void _handleTap() {
    HapticFeedback.lightImpact();
    if (!widget.notification.isRead) {
      widget.onMarkAsRead?.call();
    }
    widget.onTap?.call();
  }

  /// يحدّث حالة التحويم مع مزامنة الحركة البصرية المرتبطة بها.
  /// Updates the hover state and synchronizes the associated visual
  /// animation.
  void _setHovered(bool value) {
    setState(() => _isHovered = value);
    if (value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
