import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';

/// Provides the compact quick toggle used to switch the app theme.
/// يوفّر مفتاح تبديل سريع ومضغوط لتغيير سمة التطبيق.
class FuturisticThemeToggle extends StatefulWidget {
  /// Whether the dark theme is currently active.
  /// يحدد ما إذا كان الوضع الداكن مفعّلًا حاليًا.
  final bool isDarkMode;

  /// Optional callback used by parents that manage theme state themselves.
  /// استدعاء اختياري تستخدمه الجهات الأعلى التي تدير حالة السمة بنفسها.
  final Function(bool)? onChanged;

  /// Builds the compact toggle that animates between night and day states.
  /// ينشئ المفتاح المضغوط الذي يتحرك بين حالتي الليل والنهار.
  const FuturisticThemeToggle({
    super.key,
    required this.isDarkMode,
    this.onChanged,
  });

  /// Creates the state object that drives the animated toggle.
  /// ينشئ كائن الحالة الذي يقود حركة المفتاح.
  @override
  State<FuturisticThemeToggle> createState() => _FuturisticThemeToggleState();
}

/// Coordinates the rotating background and the switch thumb animation.
/// ينسق حركة الخلفية الدوّارة وحركة زر التبديل.
class _FuturisticThemeToggleState extends State<FuturisticThemeToggle>
    with TickerProviderStateMixin {
  /// Repeats the decorative rotation in the toggle background.
  /// يكرر الحركة الزخرفية الدوّارة في خلفية المفتاح.
  late AnimationController _rotationController;

  /// Drives the thumb position animation between dark and light states.
  /// يقود حركة موضع المؤشر بين حالتي الداكن والفاتح.
  late AnimationController _switchController;

  /// Rotation applied to the decorative icon.
  /// زاوية الدوران المطبقة على الأيقونة الزخرفية.
  late Animation<double> _rotationAnimation;

  /// Curved animation used to soften the thumb transition.
  /// حركة بمنحنى لطيف يخفف انتقال المؤشر.
  late Animation<double> _switchAnimation;

  /// Initializes the looping background and switch animations.
  /// يهيئ الحركات المتكررة للخلفية والمفتاح.
  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _switchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: widget.isDarkMode ? 1.0 : 0.0,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _switchAnimation = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    );
  }

  /// Synchronizes the switch animation when external theme state changes.
  /// يزامن حركة المفتاح عندما تتغير حالة السمة من الخارج.
  @override
  void didUpdateWidget(FuturisticThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      if (widget.isDarkMode) {
        _switchController.forward();
      } else {
        _switchController.reverse();
      }
    }
  }

  /// Releases the animation controllers owned by the toggle.
  /// يحرر متحكمات الحركة المملوكة للمفتاح.
  @override
  void dispose() {
    _rotationController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  /// Renders the animated theme toggle and handles the tap action.
  /// يرسم المفتاح المتحرك ويتعامل مع حدث النقر.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleThemeChange(!widget.isDarkMode),
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _switchAnimation]),
        builder: (context, child) {
          return Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [
                        const Color(0xFF1A1B3A),
                        const Color(0xFF2D2F5F),
                      ]
                    : [
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA500),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDarkMode
                    ? AppTheme.primaryBlue.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isDarkMode
                      ? AppTheme.primaryBlue.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                if (widget.isDarkMode)
                  ...List.generate(3, (index) {
                    return Positioned(
                      left: 8 + (index * 12),
                      top: 8 + (index * 4),
                      child: Icon(
                        Icons.star,
                        size: 4 + (index * 2),
                        color: Colors.white.withOpacity(0.6),
                      ),
                    );
                  })
                else
                  Center(
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Icon(
                        Icons.wb_sunny,
                        size: 20,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: widget.isDarkMode ? 32 : 4,
                  top: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: widget.isDarkMode
                            ? [
                                const Color(0xFF4A5568),
                                const Color(0xFF2D3748),
                              ]
                            : [
                                const Color(0xFFFFF9C4),
                                const Color(0xFFFFEB3B),
                              ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isDarkMode
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Applies the selected theme either through the callback or the bloc.
  /// يطبق السمة المختارة عبر الاستدعاء الخارجي أو الـ bloc.
  void _handleThemeChange(bool isDark) {
    if (widget.onChanged != null) {
      widget.onChanged!(isDark);
    } else {
      context.read<SettingsBloc>().add(UpdateThemeEvent(isDark));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppTheme.primaryBlue, AppTheme.primaryPurple]
                        : [Colors.orange, Colors.yellow],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isDark ? 'تم تفعيل الوضع الليلي' : 'تم تفعيل الوضع النهاري',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.darkCard.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(20),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// يعرض محددًا موسعًا يتيح للمستخدم اختيار الوضع الداكن أو الفاتح بوضوح أكبر
/// من المفتاح السريع.
/// Displays an expanded selector that lets the user choose light or dark mode
/// more explicitly than the compact quick toggle.
class FuturisticThemeSelector extends StatefulWidget {
  /// Whether the dark option is currently selected.
  /// يحدد ما إذا كان الخيار الداكن هو المختار حاليًا.
  final bool isDarkMode;

  /// Optional callback invoked when the user picks a theme option.
  /// استدعاء اختياري يُنفّذ عندما يختار المستخدم أحد خيارات السمة.
  final Function(bool)? onChanged;

  /// Builds the two-option selector used in settings screens.
  /// ينشئ محدد الخيارين المستخدم في شاشات الإعدادات.
  const FuturisticThemeSelector({
    super.key,
    required this.isDarkMode,
    this.onChanged,
  });

  /// Creates the state object that drives the option press animation.
  /// ينشئ كائن الحالة الذي يقود حركة الضغط على الخيارات.
  @override
  State<FuturisticThemeSelector> createState() =>
      _FuturisticThemeSelectorState();
}

/// Controls the press animation and selection styling for theme options.
/// يتحكم في حركة الضغط وتنسيق تحديد خيارات السمة.
class _FuturisticThemeSelectorState extends State<FuturisticThemeSelector>
    with SingleTickerProviderStateMixin {
  /// Animates the active option when it is pressed.
  /// يحرك الخيار النشط عند الضغط عليه.
  late AnimationController _animationController;

  /// Scales the active option down slightly during press feedback.
  /// يصغّر الخيار النشط قليلًا أثناء تغذية اللمس الراجعة.
  late Animation<double> _scaleAnimation;

  /// Prepares the press animation for the selector options.
  /// يجهز حركة الضغط لخيارات المحدد.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  /// Releases the press animation controller.
  /// يحرر متحكم حركة الضغط.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Renders the day and night options inside a compact container.
  /// يرسم خياري النهار والليل داخل حاوية مضغوطة.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            icon: Icons.wb_sunny,
            label: 'نهاري',
            isSelected: !widget.isDarkMode,
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.yellow],
            ),
            onTap: () => _handleThemeChange(false),
          ),
          const SizedBox(width: 8),
          _buildThemeOption(
            icon: Icons.nightlight_round,
            label: 'ليلي',
            isSelected: widget.isDarkMode,
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
            ),
            onTap: () => _handleThemeChange(true),
          ),
        ],
      ),
    );
  }

  /// Builds one selectable theme option with icon, label, and feedback.
  /// يبني خيار سمة قابلًا للاختيار مع الأيقونة والوسم وتغذية الضغط.
  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? gradient : null,
                color: !isSelected ? AppTheme.darkCard.withOpacity(0.3) : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: gradient.colors[0].withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Sends the selected theme back to the parent or the settings bloc.
  /// يرسل السمة المختارة إلى الوالد أو إلى bloc الإعدادات.
  void _handleThemeChange(bool isDark) {
    if (widget.onChanged != null) {
      widget.onChanged!(isDark);
    } else {
      context.read<SettingsBloc>().add(UpdateThemeEvent(isDark));
    }
  }
}
