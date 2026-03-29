import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';

/// Shows who is currently composing a reply inside a conversation.
/// يعرض من يكتب ردًا حاليًا داخل المحادثة.
class TypingIndicatorWidget extends StatefulWidget {
  /// Identifiers of the users who are typing right now.
  /// معرّفات المستخدمين الذين يكتبون الآن.
  final List<String> typingUserIds;

  /// Conversation used to resolve names and avatars for the indicator text.
  /// المحادثة المستخدمة لاستخراج الأسماء والصور في نص المؤشر.
  final Conversation conversation;

  /// Builds the live typing banner for the active conversation.
  /// ينشئ شريط الكتابة الحي للمحادثة النشطة.
  const TypingIndicatorWidget({
    super.key,
    required this.typingUserIds,
    required this.conversation,
  });

  /// Sets up the animation state that drives the typing dots and fade-in.
  /// يهيئ حالة الحركة التي تقود نقاط الكتابة والظهور التدريجي.
  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

/// Animates the typing dots and keeps the banner in sync with the user list.
/// يحرك نقاط الكتابة ويُبقي الشريط متزامنًا مع قائمة المستخدمين.
class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  /// Drives the repeating typing animation.
  /// يقود حركة الكتابة المتكررة.
  late AnimationController _animationController;

  /// Staggers the three dots so the typing hint feels lively.
  /// يوزع حركة النقاط الثلاث بتتابع يجعل الإشارة أكثر حيوية.
  late List<Animation<double>> _dotAnimations;

  /// Fades the banner in when the typing state becomes active.
  /// يُظهر الشريط تدريجيًا عند تفعيل حالة الكتابة.
  late Animation<double> _fadeAnimation;

  /// Starts the looping dot animation as soon as the widget is inserted.
  /// يبدأ حركة النقاط المتكررة فور إدراج العنصر.
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

  /// Disposes the animation controller used by the banner.
  /// يحرر متحكم الحركة المستخدم بالشريط.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Renders the typing text and animated dots for the active participants.
  /// يرسم نص الكتابة والنقاط المتحركة للمشاركين النشطين.
  @override
  Widget build(BuildContext context) {
    if (widget.typingUserIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final typingUsers = widget.conversation.participants
        .where((p) => widget.typingUserIds.contains(p.id))
        .toList();

    final typingText = _getTypingText(context, typingUsers);

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
                        AppTheme.darkCard.withOpacity(0.7),
                        AppTheme.darkCard.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.darkBorder.withOpacity(0.1),
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
                          color: AppTheme.textMuted.withOpacity(0.7),
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

  /// العربية: يبني minimal dots.
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
                        AppTheme.primaryBlue.withOpacity(
                          0.3 + 0.5 * _dotAnimations[index].value,
                        ),
                        AppTheme.primaryPurple.withOpacity(
                          0.2 + 0.4 * _dotAnimations[index].value,
                        ),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(
                          0.2 * _dotAnimations[index].value,
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

  /// Builds the localized label shown beneath the typing dots.
  /// ينشئ النص المحلي الظاهر أسفل نقاط الكتابة.
  String _getTypingText(BuildContext context, List<ChatUser> typingUsers) {
    if (typingUsers.isEmpty) return '';

    if (typingUsers.length == 1) {
      return context.tr(
        'chat.thread.typingSingle',
        params: {'name': typingUsers.first.name},
      );
    } else if (typingUsers.length == 2) {
      return context.tr(
        'chat.thread.typingDual',
        params: {
          'first': typingUsers.first.name,
          'second': typingUsers.last.name,
        },
      );
    } else {
      return context.tr(
        'chat.thread.typingMultiple',
      );
    }
  }
}
