import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/enums/booking_status.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Compact badge that summarizes the booking lifecycle state.
/// شارة مختصرة تلخّص حالة الحجز الحالية.
class BookingStatusWidget extends StatefulWidget {
  /// Primary booking state displayed to the user.
  /// حالة الحجز الأساسية التي تُعرض للمستخدم.
  final BookingStatus status;

  /// Optional payment flag used to refine the pending label in some flows.
  /// إشارة اختيارية للدفع تُستخدم لتخصيص النص في بعض الحالات.
  final bool? isPaid;

  /// Allows the badge text style to inherit from surrounding widgets.
  /// يسمح للنص بأن يرث النمط من العناصر المحيطة.
  final TextStyle? style;

  /// Controls whether the status icon is shown beside the label.
  /// يتحكم في إظهار الأيقونة بجانب النص.
  final bool showIcon;

  /// Overrides the default icon size when the badge is used in dense layouts.
  /// يغيّر حجم الأيقونة الافتراضي في المساحات الضيقة.
  final double? iconSize;

  /// Enables the subtle pulse animation for states that need attention.
  /// يفعّل حركة النبض الخفيفة للحالات التي تحتاج الانتباه.
  final bool animated;

  /// Builds a status badge configured for the current booking.
  /// ينشئ شارة حالة مهيأة حسب الحجز الحالي.
  const BookingStatusWidget({
    super.key,
    required this.status,
    this.isPaid,
    this.style,
    this.showIcon = true,
    this.iconSize,
    this.animated = false,
  });

  /// Builds the animation-aware state for the badge.
  /// ينشئ حالة الشارة المراعية للحركة.
  @override
  State<BookingStatusWidget> createState() => _BookingStatusWidgetState();
}

/// Drives the optional pulse animation and resolves the visible badge content.
/// يدير حركة النبض الاختيارية ويحدد محتوى الشارة الظاهر.
class _BookingStatusWidgetState extends State<BookingStatusWidget>
    with SingleTickerProviderStateMixin {
  /// Repeats the pulse effect when the booking is still waiting.
  /// يكرر تأثير النبض عندما يكون الحجز ما يزال قيد الانتظار.
  late AnimationController _animationController;

  /// Scales the badge slightly so the pending state feels alive.
  /// يكبّر الشارة قليلًا لإظهار أن الحالة قيد المتابعة.
  late Animation<double> _pulseAnimation;

  /// Builds the animation controller only when the badge can animate.
  /// يهيئ وحدة الحركة فقط عندما تكون الشارة قابلة للنبض.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated && widget.status == BookingStatus.pending) {
      _animationController.repeat(reverse: true);
    }
  }

  /// Stops the pulse controller so the widget does not leak animation ticks.
  /// يوقف وحدة الحركة حتى لا يبقى العنصر يستهلك الإطارات.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Renders a compact status chip with optional animation and iconography.
  /// يرسم شارة حالة مدمجة مع حركة وأيقونة عند الحاجة.
  @override
  Widget build(BuildContext context) {
    final shouldAnimate =
        widget.animated && widget.status == BookingStatus.pending;

    return AnimatedBuilder(
      animation:
          shouldAnimate ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: shouldAnimate ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showIcon) ...[
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: widget.iconSize ?? 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _getStatusText(context),
                  style: (widget.style ?? AppTextStyles.caption).copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Maps each booking state to the palette used across the app.
  /// يربط كل حالة حجز بلونها المعتمد داخل التطبيق.
  Color _getStatusColor() {
    switch (widget.status) {
      case BookingStatus.confirmed:
        return AppTheme.success.withOpacity(0.8);
      case BookingStatus.pending:
        return AppTheme.warning.withOpacity(0.8);
      case BookingStatus.cancelled:
        return AppTheme.error.withOpacity(0.8);
      case BookingStatus.completed:
        return AppTheme.info.withOpacity(0.8);
      case BookingStatus.checkedIn:
        return AppTheme.primaryBlue.withOpacity(0.8);
    }
  }

  /// Chooses the icon that best communicates the current booking phase.
  /// يختار الأيقونة الأنسب للتعبير عن مرحلة الحجز الحالية.
  IconData _getStatusIcon() {
    switch (widget.status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.hourglass_empty_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
      case BookingStatus.completed:
        return Icons.done_all_rounded;
      case BookingStatus.checkedIn:
        return Icons.login_rounded;
    }
  }

  /// يعيد النص المحلي المعروض داخل الشارة.
  String _getStatusText(BuildContext context) {
    switch (widget.status) {
      case BookingStatus.confirmed:
        return context.tr(
          'booking.status.confirmed',
        );
      case BookingStatus.pending:
        // [ISSUE 1011] تعديل حالة الحجز لتكون في انتظار الدفع وليس في انتظار التأكيد في حال كان الحجز غير مدفوع
        // تم تعطيل كود الإصلاح أدناه لإرجاع السلوك القديم (إظهار "في انتظار التأكيد" حتى وإن كان الحجز غير مدفوع)
        // if (widget.isPaid == false) {
        //   return 'في انتظار الدفع';
        // }
        return widget.isPaid == false
            ? context.tr(
                'booking.status.waitingPayment',
              )
            : context.tr(
                'booking.status.pending',
              );
      case BookingStatus.cancelled:
        return context.tr(
          'booking.status.cancelled',
        );
      case BookingStatus.completed:
        return context.tr(
          'booking.status.completed',
        );
      case BookingStatus.checkedIn:
        return context.tr(
          'booking.status.checkedIn',
        );
    }
  }
}
