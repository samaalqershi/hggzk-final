// lib/features/admin_bookings/presentation/widgets/booking_status_badge.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/booking_status.dart';

/// يحدد الأحجام المتاحة لشارة حالة الحجز في الواجهة.
/// Defines the available badge sizes for booking status chips.
enum BadgeSize { small, medium, large }

/// يعرض حالة الحجز بشكل بصري مدمج مع لون وأيقونة وحركة اختيارية.
/// Renders a compact booking status indicator with color, icon, and optional animation.
class BookingStatusBadge extends StatelessWidget {
  /// يحدد حالة الحجز التي سيعتمد عليها لون الشارة وأيقونتها.
  /// Defines the booking status that drives the badge color and icon.
  final BookingStatus status;

  /// يحدد حجم الشارة وطريقة تباعدها الداخلي.
  /// Defines the badge size and its internal spacing.
  final BadgeSize size;

  /// يحدد ما إذا كان يجب إظهار الأيقونة بجانب النص.
  /// Controls whether the icon is shown next to the label.
  final bool showIcon;

  /// يحدد ما إذا كانت الشارة تستخدم تأثير الوميض للحالات المنتظرة.
  /// Controls whether pending statuses use a pulsing animation.
  final bool animated;

  /// ينشئ شارة الحالة مع خيارات العرض والحجم والسلوك البصري.
  /// Creates the status badge with size, icon, and animation options.
  const BookingStatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.medium,
    this.showIcon = true,
    this.animated = true,
  });

  /// يبني الشارة النهائية مع النص والأيقونة والحالة اللونية المناسبة.
  /// Builds the final badge with the label, icon, and matching visual state.
  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    Widget badge = Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.color.withValues(alpha: 0.15),
            config.color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: _getIconSize(),
              color: config.color,
            ),
            SizedBox(width: _getSpacing()),
          ],
          Text(
            status.displayName,
            style: _getTextStyle().copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (animated && status == BookingStatus.pending) {
      return _AnimatedBadge(child: badge);
    }

    return badge;
  }

  /// Resolves the color and icon pair that matches the current booking status.
  ///
  /// يحدد زوج اللون والأيقونة الموافق لحالة الحجز الحالية.
  _StatusConfig _getStatusConfig() {
    switch (status) {
      case BookingStatus.confirmed:
        return _StatusConfig(
          color: AppTheme.success,
          icon: CupertinoIcons.checkmark_circle_fill,
        );
      case BookingStatus.pending:
        return _StatusConfig(
          color: AppTheme.warning,
          icon: CupertinoIcons.clock_fill,
        );
      case BookingStatus.cancelled:
        return _StatusConfig(
          color: AppTheme.error,
          icon: CupertinoIcons.xmark_circle_fill,
        );
      case BookingStatus.completed:
        return _StatusConfig(
          color: AppTheme.info,
          icon: CupertinoIcons.checkmark_seal_fill,
        );
      case BookingStatus.checkedIn:
        return _StatusConfig(
          color: AppTheme.primaryBlue,
          icon: CupertinoIcons.house_fill,
        );
    }
  }

  /// Chooses internal spacing based on the selected badge size.
  ///
  /// يختار التباعد الداخلي وفق حجم الشارة المحدد.
  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  /// Chooses the corner radius that keeps the badge proportions balanced.
  ///
  /// يختار نصف قطر الزوايا الذي يحافظ على توازن أبعاد الشارة.
  double _getBorderRadius() {
    switch (size) {
      case BadgeSize.small:
        return 8;
      case BadgeSize.medium:
        return 10;
      case BadgeSize.large:
        return 12;
    }
  }

  /// Chooses the icon size that fits the selected badge variant.
  ///
  /// يختار حجم الأيقونة المناسب لنسخة الشارة المختارة.
  double _getIconSize() {
    switch (size) {
      case BadgeSize.small:
        return 12;
      case BadgeSize.medium:
        return 14;
      case BadgeSize.large:
        return 16;
    }
  }

  /// Chooses the gap between icon and text for the current badge size.
  ///
  /// يختار المسافة بين الأيقونة والنص وفق حجم الشارة الحالي.
  double _getSpacing() {
    switch (size) {
      case BadgeSize.small:
        return 4;
      case BadgeSize.medium:
        return 6;
      case BadgeSize.large:
        return 8;
    }
  }

  /// Returns the typography variant that matches the selected badge size.
  ///
  /// يعيد نمط الخط الموافق لحجم الشارة المختار.
  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return AppTextStyles.caption;
      case BadgeSize.medium:
        return AppTextStyles.bodyMedium;
      case BadgeSize.large:
        return AppTextStyles.bodyLarge;
    }
  }
}

/// Stores the minimal visual recipe needed to render one status badge variant.
///
/// يخزن الوصفة البصرية الدنيا اللازمة لرسم نسخة واحدة من شارة الحالة.
class _StatusConfig {
  /// يحدد لون الحالة المستخدم في التدرج وحدود الشارة.
  /// Defines the color used for the badge gradient and border.
  final Color color;

  /// يحدد الأيقونة المرتبطة بهذه الحالة.
  /// Defines the icon associated with this status.
  final IconData icon;

  /// ينشئ تكوين الحالة الداخلي الذي يربط اللون بالأيقونة.
  /// Creates the internal status configuration that pairs color with icon.
  const _StatusConfig({
    required this.color,
    required this.icon,
  });
}

/// يضيف تأثير وميض خفيف للشارة عندما تحتاج الحالة إلى لفت الانتباه.
/// Adds a subtle pulsing effect when the badge needs attention.
class _AnimatedBadge extends StatefulWidget {
  /// يحدد العنصر المراد تطبيق تأثير الوميض عليه.
  /// Defines the child widget that receives the pulsing effect.
  final Widget child;

  /// ينشئ غلاف الحركة للعنصر الداخلي.
  /// Creates the animated wrapper for the inner child.
  const _AnimatedBadge({required this.child});

  /// ينشئ حالة الوميض المتحركة.
  /// Creates the pulsing animation state.
  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

/// يدير متحكم الحركة والتدرج الزمني لتأثير الوميض.
/// Manages the animation controller and tween used for the pulse effect.
class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة الذي يعيد تشغيل الوميض بشكل دوري.
  /// Animation controller that repeats the pulse loop.
  late AnimationController _controller;

  /// قيمة التعتيم المتدرجة المستخدمة في الوميض.
  /// Opacity tween used to create the pulse.
  late Animation<double> _animation;

  /// يجهز المتحكم والانتقال التدريجي قبل العرض الأول.
  /// Initializes the animation controller and tween before the first frame.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  /// يحرر متحكم الحركة عند إزالة الويدجت من الشجرة.
  /// Disposes the animation controller when the widget leaves the tree.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// يعرض الطفل مع تعتيم متحرك يعبّر عن حالة الوميض.
  /// Renders the child with animated opacity for the pulsing effect.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
