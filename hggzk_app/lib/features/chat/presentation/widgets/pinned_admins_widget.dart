import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';

/// Horizontal admin strip shown when the chat screen needs to surface staff
/// members or pinned moderators.
/// شريط أفقي للمشرفين يظهر عندما تحتاج شاشة الدردشة إلى إبراز أفراد
/// الطاقم أو المشرفين المثبتين.
class PinnedAdminsWidget extends StatelessWidget {
  /// Admin accounts that should appear in the pinned strip.
  /// حسابات الإدارة التي يجب أن تظهر في الشريط المثبت.
  final List<ChatUser> adminUsers;

  /// Admins currently selected by the surrounding flow.
  /// المشرفون المختارون حاليًا في المسار المحيط.
  final Set<ChatUser> selectedUsers;

  /// Called when a user tile is tapped so the host screen can update the
  /// selection state.
  /// يُستدعى عند النقر على بطاقة مستخدم كي تحدّث الشاشة المضيفة حالة
  /// الاختيار.
  final Function(ChatUser) onUserTap;

  /// Optional controller used when the strip participates in a larger scroll
  /// experience.
  /// متحكم اختياري عندما يكون الشريط جزءًا من تجربة تمرير أكبر.
  final ScrollController? scrollController;

  /// Builds the pinned admin strip that sits above the chat composer.
  /// ينشئ شريط المشرفين المثبت الذي يظهر فوق محرر الرسائل.
  const PinnedAdminsWidget({
    super.key,
    required this.adminUsers,
    required this.selectedUsers,
    required this.onUserTap,
    this.scrollController,
  });

  /// Renders the admin strip or collapses it when no staff members exist.
  /// يرسم الشريط أو يطويه عندما لا توجد حسابات طاقم.
  @override
  Widget build(BuildContext context) {
    if (adminUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.03),
            AppTheme.primaryPurple.withOpacity(0.02),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr(
                    'chat.thread.adminGroup',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${adminUsers.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Admins horizontal list
          SizedBox(
            height: 100,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: adminUsers.length,
              itemBuilder: (context, index) {
                final admin = adminUsers[index];
                final isSelected = selectedUsers.contains(admin);

                return _AdminItemWidget(
                  admin: admin,
                  isSelected: isSelected,
                  onTap: () => onUserTap(admin), // استخدام callback مباشرة
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual admin tile rendered inside the horizontal strip.
/// بطاقة مشرف منفصلة داخل الشريط الأفقي.
class _AdminItemWidget extends StatefulWidget {
  /// Admin user represented by this tile.
  /// مستخدم الإدارة الذي تمثله هذه البطاقة.
  final ChatUser admin;

  /// Whether the tile should render as selected.
  /// يحدد ما إذا كانت البطاقة يجب أن تظهر كعنصر محدد.
  final bool isSelected;

  /// Triggered when the user taps the tile.
  /// يُستدعى عند النقر على البطاقة.
  final VoidCallback onTap;

  /// Position in the strip used to stagger the entrance animation.
  /// الموقع داخل الشريط ويُستخدم لتدرّج حركة الظهور.
  final int index;

  /// Builds one selectable admin tile.
  /// ينشئ بطاقة مشرف قابلة للاختيار.
  const _AdminItemWidget({
    required this.admin,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  /// Creates the animated state for the admin tile.
  /// ينشئ الحالة المتحركة لبطاقة المشرف.
  @override
  State<_AdminItemWidget> createState() => _AdminItemWidgetState();
}

/// Animates the tile entry, scaling, and fade-in so the strip feels more
/// deliberate.
/// يدير ظهور البطاقة بالحركة والتكبير والتلاشي حتى يبدو الشريط مقصودًا.
class _AdminItemWidgetState extends State<_AdminItemWidget>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the admin tile entrance.
  /// متحكم الحركة الخاص بظهور بطاقة المشرف.
  late AnimationController _controller;

  /// Controls the tile scale as it enters the strip.
  /// يتحكم في تكبير البطاقة أثناء ظهورها.
  late Animation<double> _scaleAnimation;

  /// Controls the opacity ramp for the same entrance animation.
  /// يتحكم في تغير الشفافية أثناء حركة الظهور نفسها.
  late Animation<double> _fadeAnimation;

  /// Prepares the staggered entrance animation.
  /// يهيئ حركة الظهور المتدرجة.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  /// Releases the animation controller owned by the tile.
  /// يحرر متحكم الحركة المملوك للبطاقة.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Renders the selectable admin tile with avatar, labels, and highlight.
  /// يرسم بطاقة المشرف القابلة للاختيار مع الصورة والعناوين والتأكيد البصري.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onTap();
              },
              child: Container(
                width: 72,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar with premium effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        if (widget.isSelected)
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),

                        // Avatar container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: widget.isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.primaryBlue,
                                      AppTheme.primaryPurple,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.amber.withOpacity(0.2),
                                      Colors.orange.withOpacity(0.15),
                                    ],
                                  ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.amber.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(widget.admin.name),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: widget.isSelected
                                    ? Colors.white
                                    : Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        // Crown badge
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.darkCard,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Selection checkmark
                        if (widget.isSelected)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.darkCard,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Name
                    Text(
                      widget.admin.name.split(' ').first,
                      style: AppTextStyles.caption.copyWith(
                        color: widget.isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.textWhite,
                        fontSize: 11,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                    // Status
                    if (widget.admin.isOnline)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.tr(
                            'chat.participant.onlineNow',
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.success,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يعيد initials.
  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
