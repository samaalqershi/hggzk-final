import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Floating reaction tray shown beneath a message bubble.
///
/// It gives the user a small, low-friction way to react without leaving the
/// conversation flow.
/// يتيح للمستخدم التفاعل بسرعة من دون الخروج من سياق المحادثة.
class ReactionPickerWidget extends StatefulWidget {
  /// Called with the selected reaction type when the user taps an emoji.
  final Function(String) onReaction;

  /// Builds the animated picker that exposes quick message reactions.
  const ReactionPickerWidget({
    super.key,
    required this.onReaction,
  });

  /// Creates the animation state used to stagger and scale the reactions.
  @override
  State<ReactionPickerWidget> createState() => _ReactionPickerWidgetState();
}

/// Orchestrates the tray animation and the per-reaction entrance scale.
class _ReactionPickerWidgetState extends State<ReactionPickerWidget>
    with SingleTickerProviderStateMixin {
  /// Drives the overall tray entrance animation.
  late AnimationController _animationController;

  /// Individual pop-in animations used for each reaction button.
  late List<Animation<double>> _scaleAnimations;

  /// Scales the tray as a single unit when it appears.
  late Animation<double> _containerAnimation;

  final List<ReactionItem> reactions = [
    ReactionItem(emoji: '👍', type: 'like'),
    ReactionItem(emoji: '❤️', type: 'love'),
    ReactionItem(emoji: '😂', type: 'laugh'),
    ReactionItem(emoji: '😮', type: 'wow'),
    ReactionItem(emoji: '😢', type: 'sad'),
    ReactionItem(emoji: '😠', type: 'angry'),
  ];

  /// Creates the tray and per-item animations as soon as the widget mounts.
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

  /// Releases the tray animation controller.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Builds the floating tray and its reaction buttons.
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
                        AppTheme.darkCard.withOpacity(0.7),
                        AppTheme.darkCard.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.darkBorder.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowDark.withOpacity(0.15),
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

/// Individual reaction button rendered inside the tray.
class _MinimalReactionButton extends StatefulWidget {
  /// Emoji and metadata for the reaction option.
  final ReactionItem reaction;

  /// Invoked when the reaction is selected.
  final VoidCallback onTap;

  /// Builds one compact reaction button.
  const _MinimalReactionButton({
    required this.reaction,
    required this.onTap,
  });

  /// Creates the press feedback animation state for the reaction button.
  @override
  State<_MinimalReactionButton> createState() => _MinimalReactionButtonState();
}

class _MinimalReactionButtonState extends State<_MinimalReactionButton>
    with SingleTickerProviderStateMixin {
  /// Drives the press-scale animation.
  late AnimationController _animationController;

  /// Expands the reaction slightly during press feedback.
  late Animation<double> _scaleAnimation;

  /// Tracks the current pressed state for tactile feedback.
  bool _isPressed = false;

  /// Prepares the press animation when the button enters the tree.
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

  /// Releases the press animation controller.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Builds the tappable reaction button surface.
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
                          AppTheme.primaryBlue.withOpacity(0.1),
                          AppTheme.primaryPurple.withOpacity(0.05),
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

/// One reaction option rendered inside the tray.
/// خيار تفاعل واحد يُعرض داخل الدرج.
class ReactionItem {
  /// Emoji shown to the user.
  /// الإيموجي الظاهر للمستخدم.
  final String emoji;

  /// Backend-friendly reaction identifier.
  /// معرّف التفاعل المناسب للخادم.
  final String type;

  /// Builds one reaction option with emoji and semantic type.
  /// ينشئ خيار تفاعل واحدًا مع الإيموجي والنوع الدلالي.
  ReactionItem({
    required this.emoji,
    required this.type,
  });
}
