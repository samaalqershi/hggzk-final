import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';

/// Floating action button used to enter the chat experience from property or
/// home screens.
/// زر عائم يفتح تجربة المحادثة من شاشات العقار أو الصفحة الرئيسية.
class ChatFAB extends StatefulWidget {
  /// Called after the press animation and haptic feedback finish.
  /// يُستدعى بعد انتهاء حركة الضغط والتغذية اللمسية.
  final VoidCallback onPressed;

  /// Builds the chat entry button with the provided tap action.
  /// ينشئ زر الدخول إلى الدردشة باستخدام الإجراء الممرر عند النقر.
  const ChatFAB({
    super.key,
    required this.onPressed,
  });

  /// Sets up the animated state that drives scale, rotation, and pulse.
  /// يهيئ حالة الحركة التي تدير التكبير والدوران والنبض.
  @override
  State<ChatFAB> createState() => _ChatFABState();
}

/// Maintains the entry animation and press feedback for the chat shortcut.
/// يدير حركة الظهور وتغذية الضغط الخاصة باختصار المحادثة.
class _ChatFABState extends State<ChatFAB> with TickerProviderStateMixin {
  /// Drives the initial scale-in animation.
  /// يقود حركة الظهور بالتكبير.
  late AnimationController _scaleController;

  /// Spins the plus icon when the button is tapped.
  /// يدير دوران علامة الإضافة عند الضغط.
  late AnimationController _rotationController;

  /// Repeats the soft halo pulse behind the button.
  /// يكرر نبضة الهالة الناعمة خلف الزر.
  late AnimationController _pulseController;

  /// Animates the entry size from hidden to fully visible.
  /// يحرك الحجم من الحالة المخفية إلى الظهور الكامل.
  late Animation<double> _scaleAnimation;

  /// Provides the icon rotation value while interacting.
  /// يوفّر قيمة دوران الأيقونة أثناء التفاعل.
  late Animation<double> _rotationAnimation;

  /// Controls the glowing pulse ring around the action button.
  /// يتحكم في حلقة التوهج حول زر الإجراء.
  late Animation<double> _pulseAnimation;

  /// Tracks the current press state so the button can compress slightly.
  /// يتتبع حالة الضغط الحالية كي ينكمش الزر قليلًا.
  bool _isPressed = false;

  /// Prepares the entry animation and looping pulse when the widget mounts.
  /// يجهز حركة الظهور والنبض المتكرر عند تركيب العنصر.
  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleController.forward();
  }

  /// Disposes the animation controllers owned by the floating button.
  /// يحرر متحكمات الحركة المملوكة للزر العائم.
  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Resets the icon animation, triggers haptics, and forwards the tap to
  /// the parent screen.
  /// Resets the animation, triggers haptic feedback, and forwards the tap to
  /// the host screen.
  /// يعيد ضبط الحركة ويشغّل الاهتزاز ثم يمرر النقر إلى الشاشة المضيفة.
  void _handleTap() {
    HapticFeedback.lightImpact();
    _rotationController.forward(from: 0);
    widget.onPressed();
  }

  /// Renders the layered glass button, glow, and rotating icon.
  /// يرسم الزر الزجاجي متعدد الطبقات مع التوهج والأيقونة الدوّارة.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (_isPressed ? 0.95 : 1.0),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _handleTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle halo that gives the shortcut a stronger visual anchor.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue
                              .withOpacity(_isPressed ? 0.3 : 0.15),
                          blurRadius: _isPressed ? 20 : 15,
                          spreadRadius: _isPressed ? 2 : 0,
                        ),
                      ],
                    ),
                  ),

                  // Glass-like floating button used as the main chat entry point.
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.8),
                              AppTheme.primaryPurple.withOpacity(0.6),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: _rotationAnimation.value * 0.5,
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white.withOpacity(0.95),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gentle pulse ring that makes the button feel alive.
                  if (!_isPressed)
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryBlue
                                .withOpacity(0.1 * (1 - _pulseAnimation.value)),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
