import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';

/// يعرّف الكلاس `TypingIndicatorWidget`.
/// Describes the `TypingIndicatorWidget` class.
class TypingIndicatorWidget extends StatefulWidget {
  /// Holds the `typingUserIds` value.
  /// العربية: يخزن القيمة `typingUserIds`.
  final List<String> typingUserIds;

  /// يخزن العضو `conversation`.
  /// Holds the `conversation` member.
  final Conversation conversation;

  /// ينشئ مثيلاً من `TypingIndicatorWidget`.
  /// Builds an instance of `TypingIndicatorWidget`.
  const TypingIndicatorWidget({
    super.key,
    required this.typingUserIds,
    required this.conversation,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

/// يعرّف الكلاس `_TypingIndicatorWidgetState`.
/// Describes the `_TypingIndicatorWidgetState` class.
class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_dotAnimations`.
  /// Holds the `_dotAnimations` member.
  late List<Animation<double>> _dotAnimations;

  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    ));

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
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
    if (widget.typingUserIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final typingUsers = widget.conversation.participants
        .where((p) => widget.typingUserIds.contains(p.id))
        .toList();

    final typingText = _getTypingText(typingUsers);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(
          left: 0,
          right: 40, // Reduced from 48
          bottom: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkCard.withValues(alpha: 0.7),
                        AppTheme.darkCard.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMinimalDots(),
                      const SizedBox(width: 6),
                      Text(
                        typingText,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildMinimalDots`.
  /// Runs the `_buildMinimalDots` operation.
  Widget _buildMinimalDots() {
    return SizedBox(
      width: 24, // Reduced from 30
      height: 8, // Reduced from 10
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _dotAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -3 * _dotAnimations[index].value),
                child: Container(
                  width: 5, // Reduced from 6
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(
                          alpha: 0.3 + 0.5 * _dotAnimations[index].value,
                        ),
                        AppTheme.primaryPurple.withValues(
                          alpha: 0.2 + 0.4 * _dotAnimations[index].value,
                        ),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(
                          alpha: 0.2 * _dotAnimations[index].value,
                        ),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// ينفذ العملية `_getTypingText`.
  /// Runs the `_getTypingText` operation.
  String _getTypingText(List<ChatUser> typingUsers) {
    if (typingUsers.isEmpty) return '';

    if (typingUsers.length == 1) {
      return '${typingUsers.first.name} يكتب';
    } else if (typingUsers.length == 2) {
      return '${typingUsers.first.name} و${typingUsers.last.name} يكتبان';
    } else {
      return 'عدة أشخاص يكتبون';
    }
  }
}
