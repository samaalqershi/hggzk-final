import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';

/// يعرّف الكلاس `ReactionPickerWidget`.
/// Describes the `ReactionPickerWidget` class.
class ReactionPickerWidget extends StatefulWidget {
  /// Receives `Function`.
  /// العربية: يعالج `Function`.
  final Function(String) onReaction;

  /// ينشئ مثيلاً من `ReactionPickerWidget`.
  /// Builds an instance of `ReactionPickerWidget`.
  const ReactionPickerWidget({
    super.key,
    required this.onReaction,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<ReactionPickerWidget> createState() => _ReactionPickerWidgetState();
}

/// يعرّف الكلاس `_ReactionPickerWidgetState`.
/// Describes the `_ReactionPickerWidgetState` class.
class _ReactionPickerWidgetState extends State<ReactionPickerWidget>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_scaleAnimations`.
  /// Holds the `_scaleAnimations` member.
  late List<Animation<double>> _scaleAnimations;

  /// يخزن العضو `_containerAnimation`.
  /// Holds the `_containerAnimation` member.
  late Animation<double> _containerAnimation;

  /// يخزن العضو `reactions`.
  /// Holds the `reactions` member.
  final List<ReactionItem> reactions = [
    ReactionItem(emoji: '👍', type: 'like'),

    /// ينفذ العملية `ReactionItem`.
    /// Runs the `ReactionItem` operation.
    ReactionItem(emoji: '❤️', type: 'love'),

    /// ينفذ العملية `ReactionItem`.
    /// Runs the `ReactionItem` operation.
    ReactionItem(emoji: '😂', type: 'laugh'),

    /// ينفذ العملية `ReactionItem`.
    /// Runs the `ReactionItem` operation.
    ReactionItem(emoji: '😮', type: 'wow'),

    /// ينفذ العملية `ReactionItem`.
    /// Runs the `ReactionItem` operation.
    ReactionItem(emoji: '😢', type: 'sad'),

    /// ينفذ العملية `ReactionItem`.
    /// Runs the `ReactionItem` operation.
    ReactionItem(emoji: '😠', type: 'angry'),
  ];

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _containerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _scaleAnimations = List.generate(reactions.length, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.08,
            0.4 + index * 0.1,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _animationController.forward();
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
      animation: _containerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _containerAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkCard.withValues(alpha: 0.7),
                        AppTheme.darkCard.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowDark.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(reactions.length, (index) {
                      return AnimatedBuilder(
                        animation: _scaleAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimations[index].value,
                            child: _MinimalReactionButton(
                              reaction: reactions[index],
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onReaction(reactions[index].type);
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// يعرّف الكلاس `_MinimalReactionButton`.
/// Describes the `_MinimalReactionButton` class.
class _MinimalReactionButton extends StatefulWidget {
  /// Holds the `reaction` value.
  /// العربية: يخزن القيمة `reaction`.
  final ReactionItem reaction;

  /// يخزن العضو `onTap`.
  /// Holds the `onTap` member.
  final VoidCallback onTap;

  /// ينشئ مثيلاً من `_MinimalReactionButton`.
  /// Builds an instance of `_MinimalReactionButton`.
  const _MinimalReactionButton({
    required this.reaction,
    required this.onTap,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<_MinimalReactionButton> createState() => _MinimalReactionButtonState();
}

/// يعرّف الكلاس `_MinimalReactionButtonState`.
/// Describes the `_MinimalReactionButtonState` class.
class _MinimalReactionButtonState extends State<_MinimalReactionButton>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// يخزن العضو `_isPressed`.
  /// Holds the `_isPressed` member.
  bool _isPressed = false;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: _isPressed
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.1),
                          AppTheme.primaryPurple.withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                widget.reaction.emoji,
                style: const TextStyle(fontSize: 20), // Reduced from 24
              ),
            ),
          );
        },
      ),
    );
  }
}

/// يعرّف الكلاس `ReactionItem`.
/// Describes the `ReactionItem` class.
class ReactionItem {
  /// Holds the `emoji` value.
  /// العربية: يخزن القيمة `emoji`.
  final String emoji;

  /// يخزن العضو `type`.
  /// Holds the `type` member.
  final String type;

  /// ينشئ مثيلاً من `ReactionItem`.
  /// Builds an instance of `ReactionItem`.
  ReactionItem({
    required this.emoji,
    required this.type,
  });
}
