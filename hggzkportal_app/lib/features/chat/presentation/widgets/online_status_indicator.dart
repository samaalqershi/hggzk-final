import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Small presence dot with optional pulse for active users.
class OnlineStatusIndicator extends StatefulWidget {
  /// Indicates whether the user is currently online.
  final bool isOnline;

  /// Controls the rendered diameter of the indicator.
  final double size;

  /// Adds a thin border that separates the dot from the background.
  final bool showBorder;

  /// Enables the soft pulse when the user is online.
  final bool animate;

  /// Builds a presence indicator that can pulse when online.
  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 10, // Reduced from 12
    this.showBorder = true,
    this.animate = true,
  });

  /// Creates the animation state for the pulse effect.
  @override
  State<OnlineStatusIndicator> createState() => _OnlineStatusIndicatorState();
}

/// Manages the repeating pulse animation for the online dot.
class _OnlineStatusIndicatorState extends State<OnlineStatusIndicator>
    with SingleTickerProviderStateMixin {
  /// Drives the pulse animation.
  late AnimationController _controller;

  /// Expands and fades the halo around the indicator.
  late Animation<double> _pulseAnimation;

  /// Starts the pulse only when the widget should animate.
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

  /// Starts or stops the pulse when the online state changes.
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

  /// Releases the pulse animation controller.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the indicator and its optional pulse halo.
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
                  color: AppTheme.success.withOpacity(
                    0.3 * (1 - _pulseAnimation.value),
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
                    ? AppTheme.textMuted.withOpacity(0.3)
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
                          color: AppTheme.success.withOpacity(0.4),
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
