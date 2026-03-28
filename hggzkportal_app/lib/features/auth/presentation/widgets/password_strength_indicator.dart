import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يعرّف الكلاس `PasswordStrengthIndicator`.
/// Describes the `PasswordStrengthIndicator` class.
class PasswordStrengthIndicator extends StatefulWidget {
  /// Holds the `password` value.
  /// العربية: يخزن القيمة `password`.
  final String password;

  /// يخزن العضو `showRequirements`.
  /// Holds the `showRequirements` member.
  final bool showRequirements;

  /// ينشئ مثيلاً من `PasswordStrengthIndicator`.
  /// Builds an instance of `PasswordStrengthIndicator`.
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

/// يعرّف الكلاس `_PasswordStrengthIndicatorState`.
/// Describes the `_PasswordStrengthIndicatorState` class.
class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_strengthAnimation`.
  /// Holds the `_strengthAnimation` member.
  late Animation<double> _strengthAnimation;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _strengthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `didUpdateWidget`.
  /// Runs the `didUpdateWidget` operation.
  @override
  void didUpdateWidget(PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) {
      _animationController.forward(from: 0);
    }
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(widget.password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: AnimatedBuilder(
              animation: _strengthAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: strength.value * _strengthAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: strength.gradientColors,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: strength.gradientColors[0]
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Shimmer effect
                    if (strength.value > 0)
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: strength.value * _strengthAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),

        if (strength.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: strength.gradientColors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: strength.gradientColors[0].withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strength.text,
                style: AppTextStyles.caption.copyWith(
                  color: strength.gradientColors[0],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        if (widget.showRequirements && widget.password.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildFuturisticRequirements(),
        ],
      ],
    );
  }

  /// ينفذ العملية `_buildFuturisticRequirements`.
  /// Runs the `_buildFuturisticRequirements` operation.
  Widget _buildFuturisticRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.3),
            AppTheme.darkCard.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FuturisticRequirementChip(
                label: '8+ أحرف',
                isMet: widget.password.length >= 8,
                icon: Icons.text_fields,
              ),
              _FuturisticRequirementChip(
                label: 'حرف كبير',
                isMet: widget.password.contains(RegExp(r'[A-Z]')),
                icon: Icons.text_increase,
              ),
              _FuturisticRequirementChip(
                label: 'حرف صغير',
                isMet: widget.password.contains(RegExp(r'[a-z]')),
                icon: Icons.text_decrease,
              ),
              _FuturisticRequirementChip(
                label: 'رقم',
                isMet: widget.password.contains(RegExp(r'[0-9]')),
                icon: Icons.numbers,
              ),
              _FuturisticRequirementChip(
                label: 'رمز خاص',
                isMet:
                    widget.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                icon: Icons.star,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_calculateStrength`.
  /// Runs the `_calculateStrength` operation.
  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        value: 0,
        gradientColors: [Colors.transparent, Colors.transparent],
        text: '',
      );
    }

    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) {
      return PasswordStrength(
        value: 0.25,
        gradientColors: [AppTheme.error, AppTheme.error.withValues(alpha: 0.7)],
        text: 'ضعيفة',
      );
    } else if (score <= 4) {
      return PasswordStrength(
        value: 0.5,
        gradientColors: [
          AppTheme.warning,
          AppTheme.warning.withValues(alpha: 0.7)
        ],
        text: 'متوسطة',
      );
    } else if (score <= 5) {
      return PasswordStrength(
        value: 0.75,
        gradientColors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
        text: 'جيدة',
      );
    } else {
      return PasswordStrength(
        value: 1.0,
        gradientColors: [AppTheme.success, AppTheme.neonGreen],
        text: 'قوية جداً',
      );
    }
  }
}

/// يعرّف الكلاس `_FuturisticRequirementChip`.
/// Describes the `_FuturisticRequirementChip` class.
class _FuturisticRequirementChip extends StatefulWidget {
  /// Holds the `label` value.
  /// العربية: يخزن القيمة `label`.
  final String label;

  /// يخزن العضو `isMet`.
  /// Holds the `isMet` member.
  final bool isMet;

  /// يخزن العضو `icon`.
  /// Holds the `icon` member.
  final IconData icon;

  /// ينشئ مثيلاً من `_FuturisticRequirementChip`.
  /// Builds an instance of `_FuturisticRequirementChip`.
  const _FuturisticRequirementChip({
    required this.label,
    required this.isMet,
    required this.icon,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<_FuturisticRequirementChip> createState() =>
      _FuturisticRequirementChipState();
}

/// يعرّف الكلاس `_FuturisticRequirementChipState`.
/// Describes the `_FuturisticRequirementChipState` class.
class _FuturisticRequirementChipState extends State<_FuturisticRequirementChip>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.isMet) {
      _animationController.forward();
    }
  }

  /// ينفذ العملية `didUpdateWidget`.
  /// Runs the `didUpdateWidget` operation.
  @override
  void didUpdateWidget(_FuturisticRequirementChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMet && !oldWidget.isMet) {
      _animationController.forward();
    } else if (!widget.isMet && oldWidget.isMet) {
      _animationController.reverse();
    }
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isMet ? _scaleAnimation.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: widget.isMet
                  ? LinearGradient(
                      colors: [
                        AppTheme.success.withValues(alpha: 0.2),
                        AppTheme.neonGreen.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              color: !widget.isMet
                  ? AppTheme.darkCard.withValues(alpha: 0.2)
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isMet
                    ? AppTheme.success.withValues(alpha: 0.5)
                    : AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: widget.isMet
                  ? [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isMet ? Icons.check_circle : widget.icon,
                  size: 14,
                  color: widget.isMet
                      ? AppTheme.success
                      : AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: AppTextStyles.caption.copyWith(
                    color: widget.isMet
                        ? AppTheme.success
                        : AppTheme.textMuted.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight:
                        widget.isMet ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// يعرّف الكلاس `PasswordStrength`.
/// Describes the `PasswordStrength` class.
class PasswordStrength {
  /// Holds the `value` value.
  /// العربية: يخزن القيمة `value`.
  final double value;

  /// يخزن العضو `gradientColors`.
  /// Holds the `gradientColors` member.
  final List<Color> gradientColors;

  /// يخزن العضو `text`.
  /// Holds the `text` member.
  final String text;

  /// ينشئ مثيلاً من `PasswordStrength`.
  /// Builds an instance of `PasswordStrength`.
  PasswordStrength({
    required this.value,
    required this.gradientColors,
    required this.text,
  });
}
