import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays one settings row or action tile with a futuristic visual style.
/// يعرض عنصر إعدادات واحدًا بتصميم تفاعلي حديث يصلح كصف معلومات أو زر.
class FuturisticSettingsItem extends StatefulWidget {
  /// Leading icon rendered inside the action tile.
  /// الأيقونة الرئيسية المعروضة داخل عنصر الإعداد.
  final IconData icon;

  /// Main label displayed to the user.
  /// العنوان الرئيسي الظاهر للمستخدم.
  final String title;

  /// Optional secondary text that explains the item.
  /// نص ثانوي اختياري يشرح العنصر.
  final String? subtitle;

  /// Optional trailing widget such as a switch or chevron.
  /// ويدجت اختيارية في النهاية مثل المفتاح أو السهم.
  final Widget? trailing;

  /// Callback fired when the item is tapped.
  /// الاستدعاء الذي يعمل عند النقر على العنصر.
  final VoidCallback? onTap;

  /// Gradient used to color the icon and selected hover state.
  /// التدرج اللوني المستخدم لتلوين الأيقونة وحالة التمرير.
  final Gradient gradient;

  /// Marks actions that should read as destructive.
  /// يحدد الأفعال التي يجب أن تبدو تحذيرية/تدميرية.
  final bool isDestructive;

  /// Controls whether the row is interactive.
  /// يتحكم في كون الصف قابلًا للتفاعل.
  final bool enabled;

  /// Builds a single futuristic settings row.
  /// ينشئ صف إعدادات واحدًا بتصميم حديث.
  const FuturisticSettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.gradient,
    this.isDestructive = false,
    this.enabled = true,
  });

  /// Creates the state object that handles hover and press feedback.
  /// ينشئ كائن الحالة الذي يتعامل مع تغذية التمرير والضغط.
  @override
  State<FuturisticSettingsItem> createState() => _FuturisticSettingsItemState();
}

/// Handles hover transitions and press feedback for the settings item.
/// يتعامل مع انتقالات التمرير وتغذية الضغط لعنصر الإعداد.
class _FuturisticSettingsItemState extends State<FuturisticSettingsItem>
    with SingleTickerProviderStateMixin {
  /// Drives the hover animation used by the item background.
  /// يقود حركة التمرير المستخدمة في خلفية العنصر.
  late AnimationController _hoverController;

  /// Curved hover animation that softens the transition.
  /// حركة تمرير بمنحنى لتلطيف الانتقال.
  late Animation<double> _hoverAnimation;

  /// Tracks whether the pointer is currently over the item.
  /// يتتبع ما إذا كان المؤشر فوق العنصر حاليًا.
  bool _isHovered = false;

  /// Prepares the hover animation controller.
  /// يجهز متحكم حركة التمرير.
  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  /// Releases the hover animation controller.
  /// يحرر متحكم حركة التمرير.
  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  /// Updates hover state and starts or reverses the animation.
  /// يحدث حالة التمرير ويبدأ الحركة أو يعكسها.
  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  /// Renders the interactive settings tile with hover and tap feedback.
  /// يرسم بطاقة الإعداد التفاعلية مع تغذية راجعة للتمرير والنقر.
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: (_) => _handleHover(true),
        onTapUp: (_) {
          _handleHover(false);
          if (widget.enabled && widget.onTap != null) {
            widget.onTap!();
          }
        },
        onTapCancel: () => _handleHover(false),
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isHovered
                      ? [
                          widget.gradient.colors[0].withOpacity(0.15),
                          widget.gradient.colors[1].withOpacity(0.1),
                        ]
                      : [
                          AppTheme.darkCard.withOpacity(0.3),
                          AppTheme.darkCard.withOpacity(0.2),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? widget.gradient.colors[0].withOpacity(0.5)
                      : AppTheme.darkBorder.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.gradient.colors[0].withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _isHovered ? 15 : 10,
                    sigmaY: _isHovered ? 15 : 10,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.enabled ? widget.onTap : null,
                      borderRadius: BorderRadius.circular(16),
                      splashColor: widget.gradient.colors[0].withOpacity(0.2),
                      highlightColor:
                          widget.gradient.colors[1].withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: _isHovered
                                    ? widget.gradient
                                    : LinearGradient(
                                        colors: [
                                          widget.gradient.colors[0]
                                              .withOpacity(0.3),
                                          widget.gradient.colors[1]
                                              .withOpacity(0.2),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: _isHovered
                                    ? [
                                        BoxShadow(
                                          color: widget.gradient.colors[0]
                                              .withOpacity(0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Transform.scale(
                                scale: _isHovered ? 1.1 : 1.0,
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Title and subtitle block.
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: widget.isDestructive
                                          ? AppTheme.error
                                          : AppTheme.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (widget.subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.subtitle!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Trailing widget or fallback chevron.
                            if (widget.trailing != null)
                              widget.trailing!
                            else if (widget.onTap != null)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: Matrix4.translationValues(
                                  _isHovered ? 5 : 0,
                                  0,
                                  0,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// يعرض صف إعدادات يتضمن مفتاح تبديل مباشرًا لتفعيل خيار أو إيقافه.
/// Displays a settings row that includes an inline toggle for enabling or
/// disabling a preference.
class FuturisticSettingsToggle extends StatefulWidget {
  /// Leading icon rendered on the toggle row.
  /// الأيقونة الرئيسية المعروضة في صف التبديل.
  final IconData icon;

  /// Main label shown to the user.
  /// العنوان الرئيسي الظاهر للمستخدم.
  final String title;

  /// Optional explanatory subtitle.
  /// وصف ثانوي اختياري.
  final String? subtitle;

  /// Current toggle value.
  /// قيمة التبديل الحالية.
  final bool value;

  /// Callback invoked when the toggle is changed.
  /// الاستدعاء الذي يعمل عند تغيير حالة التبديل.
  final ValueChanged<bool>? onChanged;

  /// Gradient used to style the active state.
  /// التدرج المستخدم لتنسيق الحالة النشطة.
  final Gradient gradient;

  /// Controls whether the toggle can be interacted with.
  /// يتحكم في قابلية التفاعل مع التبديل.
  final bool enabled;

  /// Builds a settings row that includes a toggle control.
  /// ينشئ صف إعدادات يحتوي على مفتاح تبديل.
  const FuturisticSettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.gradient,
    this.enabled = true,
  });

  /// Creates the state object that animates the toggle thumb.
  /// ينشئ كائن الحالة الذي يحرك مؤشر التبديل.
  @override
  State<FuturisticSettingsToggle> createState() =>
      _FuturisticSettingsToggleState();
}

/// Animates the toggle thumb so changes feel smooth and visible.
/// يحرك مؤشر التبديل حتى تبدو التغييرات ناعمة وواضحة.
class _FuturisticSettingsToggleState extends State<FuturisticSettingsToggle>
    with SingleTickerProviderStateMixin {
  /// Drives the toggle thumb animation.
  /// يقود حركة مؤشر التبديل.
  late AnimationController _toggleController;

  /// Curved animation used to animate the thumb position.
  /// حركة بمنحنى لتنسيق موضع المؤشر.
  late Animation<double> _toggleAnimation;

  /// Initializes the controller to match the current toggle value.
  /// يهيئ المتحكم ليتوافق مع قيمة التبديل الحالية.
  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );
  }

  /// Synchronizes the animation when the external toggle value changes.
  /// يزامن الحركة عندما تتغير قيمة التبديل من الخارج.
  @override
  void didUpdateWidget(FuturisticSettingsToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _toggleController.forward();
      } else {
        _toggleController.reverse();
      }
    }
  }

  /// Releases the toggle animation controller.
  /// يحرر متحكم حركة التبديل.
  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  /// Renders the settings row and the interactive toggle control.
  /// يرسم صف الإعدادات مع عنصر التبديل التفاعلي.
  @override
  Widget build(BuildContext context) {
    return FuturisticSettingsItem(
      icon: widget.icon,
      title: widget.title,
      subtitle: widget.subtitle,
      gradient: widget.gradient,
      enabled: widget.enabled,
      trailing: GestureDetector(
        onTap:
            widget.enabled ? () => widget.onChanged?.call(!widget.value) : null,
        child: AnimatedBuilder(
          animation: _toggleAnimation,
          builder: (context, child) {
            return Container(
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                gradient: widget.value
                    ? widget.gradient
                    : LinearGradient(
                        colors: [
                          AppTheme.darkCard.withOpacity(0.5),
                          AppTheme.darkCard.withOpacity(0.3),
                        ],
                      ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: widget.value
                      ? Colors.transparent
                      : AppTheme.darkBorder.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: widget.value
                    ? [
                        BoxShadow(
                          color: widget.gradient.colors[0].withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: widget.value ? 28 : 2,
                    top: 2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      onTap:
          widget.enabled ? () => widget.onChanged?.call(!widget.value) : null,
    );
  }
}
