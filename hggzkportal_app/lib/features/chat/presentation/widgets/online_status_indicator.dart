import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// يعرّف الكلاس `OnlineStatusIndicator`.
/// Describes the `OnlineStatusIndicator` class.
class OnlineStatusIndicator extends StatefulWidget {
  /// Indicates whether `isOnline` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isOnline` مفعلة.
  final bool isOnline;

  /// يخزن العضو `size`.
  /// Holds the `size` member.
  final double size;

  /// يخزن العضو `showBorder`.
  /// Holds the `showBorder` member.
  final bool showBorder;

  /// يخزن العضو `animate`.
  /// Holds the `animate` member.
  final bool animate;

  /// ينشئ مثيلاً من `OnlineStatusIndicator`.
  /// Builds an instance of `OnlineStatusIndicator`.
  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 10, // Reduced from 12
    this.showBorder = true,
    this.animate = true,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<OnlineStatusIndicator> createState() => _OnlineStatusIndicatorState();
}

/// يعرّف الكلاس `_OnlineStatusIndicatorState`.
/// Describes the `_OnlineStatusIndicatorState` class.
class _OnlineStatusIndicatorState extends State<OnlineStatusIndicator>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_controller`.
  /// Holds the `_controller` member.
  late AnimationController _controller;

  /// يخزن العضو `_pulseAnimation`.
  /// Holds the `_pulseAnimation` member.
  late Animation<double> _pulseAnimation;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isOnline && widget.animate) {
      _controller.repeat();
    }
  }

  /// ينفذ العملية `didUpdateWidget`.
  /// Runs the `didUpdateWidget` operation.
  @override
  void didUpdateWidget(OnlineStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline && widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect for online status
            if (widget.isOnline && widget.animate)
              Container(
                width: widget.size + 6 * _pulseAnimation.value,
                height: widget.size + 6 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(
                    alpha: 0.3 * (1 - _pulseAnimation.value),
                  ),
                  shape: BoxShape.circle,
                ),
              ),

            // Main indicator
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: widget.isOnline
                    ? LinearGradient(
                        colors: [AppTheme.success, AppTheme.neonGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !widget.isOnline
                    ? AppTheme.textMuted.withValues(alpha: 0.3)
                    : null,
                shape: BoxShape.circle,
                border: widget.showBorder
                    ? Border.all(
                        color: Theme.of(context).cardColor,
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.isOnline
                    ? [
                        BoxShadow(
                          color: AppTheme.success.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
