// lib/features/notifications/presentation/widgets/notification_badge_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Compact bell badge that shows the unread count and can pulse when new
/// notifications arrive.
/// شارة جرس مضغوطة تعرض عدد غير المقروء ويمكن أن تنبض عند وصول إشعارات
/// جديدة.
class NotificationBadgeWidget extends StatefulWidget {
  /// Number shown inside the badge.
  /// العدد الظاهر داخل الشارة.
  final int count;

  /// Optional tap handler used by the host screen.
  /// معالج نقر اختياري تستخدمه الشاشة المضيفة.
  final VoidCallback? onTap;

  /// Whether the badge should animate when the count changes.
  /// يحدد ما إذا كانت الشارة يجب أن تتحرك عند تغيّر العدد.
  final bool showAnimation;

  /// Builds the badge with its count and optional animation behavior.
  /// ينشئ الشارة مع العدد وسلوك الحركة الاختياري.
  const NotificationBadgeWidget({
    super.key,
    required this.count,
    this.onTap,
    this.showAnimation = true,
  });

  /// Creates the animated badge state.
  /// ينشئ حالة الشارة المتحركة.
  @override
  State<NotificationBadgeWidget> createState() =>
      _NotificationBadgeWidgetState();
}

/// Handles the badge pulse and scale animations.
/// يدير حركة النبض والتكبير الخاصة بالشارة.
class _NotificationBadgeWidgetState extends State<NotificationBadgeWidget>
    with SingleTickerProviderStateMixin {
  /// Drives the pulse and scale animations.
  /// يقود حركة النبض والتكبير.
  late AnimationController _animationController;

  /// Scales the bell icon slightly when notifications increase.
  /// يكبّر أيقونة الجرس قليلًا عند زيادة الإشعارات.
  late Animation<double> _scaleAnimation;

  /// Creates the soft pulse effect around the badge.
  /// ينشئ تأثير النبض الخفيف حول الشارة.
  late Animation<double> _pulseAnimation;

  /// Prepares the repeating animation when the widget is inserted.
  /// يجهز الحركة المتكررة عند إدخال العنصر في الشجرة.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation && widget.count > 0) {
      _animationController.repeat(reverse: true);
    }
  }

  /// Reacts to badge count changes and restarts animation when needed.
  /// يتفاعل مع تغيّر العدد ويعيد تشغيل الحركة عند الحاجة.
  @override
  void didUpdateWidget(NotificationBadgeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count && widget.showAnimation) {
      _animationController.forward().then((_) {
        _animationController.repeat(reverse: true);
      });
    } else if (widget.count == 0) {
      _animationController.stop();
    }
  }

  /// Releases the animation controller owned by the badge.
  /// يحرر متحكم الحركة المملوك للشارة.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Renders the bell icon and the numeric badge.
  /// يرسم أيقونة الجرس والعداد الرقمي.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withValues(alpha: 0.5),
                  AppTheme.darkCard.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: widget.count > 0
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.count > 0 ? _pulseAnimation.value : 1.0,
                  child: Icon(
                    widget.count > 0
                        ? CupertinoIcons.bell_fill
                        : CupertinoIcons.bell,
                    color: widget.count > 0
                        ? AppTheme.primaryBlue
                        : AppTheme.textMuted,
                    size: 24,
                  ),
                );
              },
            ),
          ),
          if (widget.count > 0)
            Positioned(
              top: 2,
              right: 2,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.count > 99 ? '99+' : widget.count.toString(),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
