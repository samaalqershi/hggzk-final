import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// العربية: يمثل العنصر `CancellationDeadlineHasExpiredWidget`.
class CancellationDeadlineHasExpiredWidget extends StatefulWidget {
  /// العربية: يحدد ما إذا كانت القيمة `hasExpired` مفعلة.
  final bool hasExpired;

  /// العربية: يخزن القيمة `deadline`.
  final DateTime deadline;

  /// العربية: يخزن القيمة `policy`.
  final String? policy;

  /// العربية: ينشئ مثيلًا جديدًا من `CancellationDeadlineHasExpiredWidget`.
  const CancellationDeadlineHasExpiredWidget({
    super.key,
    required this.hasExpired,
    required this.deadline,
    this.policy,
  });

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<CancellationDeadlineHasExpiredWidget> createState() =>
      _CancellationDeadlineHasExpiredWidgetState();
}

/// العربية: يمثل الحالة الخاصة بـ `CancellationDeadlineHasExpiredWidgetState`.
class _CancellationDeadlineHasExpiredWidgetState
    extends State<CancellationDeadlineHasExpiredWidget>
    with SingleTickerProviderStateMixin {
  /// العربية: يخزن القيمة `pulseController`.
  late AnimationController _pulseController;

  /// العربية: يخزن القيمة `pulseAnimation`.
  late Animation<double> _pulseAnimation;

  /// العربية: يخزن القيمة `countdownTimer`.
  Timer? _countdownTimer;

  /// العربية: يخزن القيمة `remainingTime`.
  Duration _remainingTime = Duration.zero;

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.hasExpired) {
      _pulseController.repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startCountdown();
  }

  /// العربية: يبدأ countdown.
  void _startCountdown() {
    if (!widget.hasExpired) {
      _updateRemainingTime();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemainingTime();
      });
    }
  }

  /// العربية: يحدّث remaining time.
  void _updateRemainingTime() {
    final now = DateTime.now();
    setState(() {
      _remainingTime = widget.deadline.difference(now);
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
        _countdownTimer?.cancel();
      }
    });
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'ar');

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.hasExpired ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.hasExpired
                  ? AppTheme.error.withOpacity(0.05)
                  : AppTheme.warning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.hasExpired
                    ? AppTheme.error.withOpacity(0.2)
                    : AppTheme.warning.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactHeader(),
                      const SizedBox(height: 10),
                      if (widget.hasExpired) ...[
                        _buildExpiredContent(),
                      ] else ...[
                        _buildActiveContent(dateFormat),
                        if (_remainingTime.inDays <= 2) ...[
                          const SizedBox(height: 10),
                          _buildTimeRemaining(),
                        ],
                      ],
                      if (widget.policy != null) ...[
                        const SizedBox(height: 10),
                        _buildPolicyDetails(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يبني compact header.
  Widget _buildCompactHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (widget.hasExpired ? AppTheme.error : AppTheme.warning)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.hasExpired
                ? Icons.cancel_rounded
                : Icons.warning_amber_rounded,
            color: (widget.hasExpired ? AppTheme.error : AppTheme.warning)
                .withOpacity(0.8),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hasExpired
                    ? 'انتهت مهلة الإلغاء المجاني'
                    : 'سياسة الإلغاء',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: (widget.hasExpired ? AppTheme.error : AppTheme.warning)
                      .withOpacity(0.9),
                ),
              ),
              if (!widget.hasExpired && _remainingTime.inHours <= 24) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'عاجل!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.error.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// العربية: يبني expired content.
  Widget _buildExpiredContent() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.error.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لقد انتهت المهلة المسموح بها للإلغاء المجاني.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textWhite.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'في حالة الإلغاء الآن، سيتم تطبيق رسوم إلغاء وفقاً لسياسة العقار.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني active content.
  Widget _buildActiveContent(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'يمكنك إلغاء الحجز مجاناً حتى:',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textWhite.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.warning.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppTheme.warning.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(widget.deadline),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warning.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// العربية: يبني time remaining.
  Widget _buildTimeRemaining() {
    String timeText;
    IconData icon;
    Color color;

    if (_remainingTime.inHours <= 0) {
      timeText = 'انتهت المهلة';
      icon = Icons.timer_off_rounded;
      color = AppTheme.error.withOpacity(0.8);
    } else if (_remainingTime.inHours <= 24) {
      timeText =
          'متبقي ${_remainingTime.inHours} ساعة و ${_remainingTime.inMinutes % 60} دقيقة';
      icon = Icons.timer_rounded;
      color = AppTheme.error.withOpacity(0.8);
    } else {
      timeText = 'متبقي ${_remainingTime.inDays} يوم';
      icon = Icons.calendar_today_rounded;
      color = AppTheme.warning.withOpacity(0.8);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            timeText,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني policy details.
  Widget _buildPolicyDetails() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.policy_rounded,
                color: AppTheme.primaryBlue.withOpacity(0.7),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'تفاصيل السياسة:',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.policy!,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
