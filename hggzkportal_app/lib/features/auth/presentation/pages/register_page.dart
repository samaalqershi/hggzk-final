// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/app_logo_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/register_form.dart';

/// يعرّف الكلاس `RegisterPage`.
/// Describes the `RegisterPage` class.
class RegisterPage extends StatefulWidget {
  /// Indicates whether `isFirst` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isFirst` مفعلة.
  final bool isFirst;

  /// ينشئ مثيلاً من `RegisterPage`.
  /// Builds an instance of `RegisterPage`.
  const RegisterPage({
    super.key,
    this.isFirst = false,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// يعرّف الكلاس `_RegisterPageState`.
/// Describes the `_RegisterPageState` class.
class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  /// يخزن العضو `_backgroundController`.
  /// Holds the `_backgroundController` member.
  late AnimationController _backgroundController;

  /// يخزن العضو `_contentController`.
  /// Holds the `_contentController` member.
  late AnimationController _contentController;

  /// يخزن العضو `_particleController`.
  /// Holds the `_particleController` member.
  late AnimationController _particleController;

  /// يخزن العضو `_glowController`.
  /// Holds the `_glowController` member.
  late AnimationController _glowController;

  /// يخزن العضو `_waveController`.
  /// Holds the `_waveController` member.
  late AnimationController _waveController;

  /// يخزن العضو `_logoController`.
  /// Holds the `_logoController` member.
  late AnimationController _logoController;

  // Animations
  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// يخزن العضو `_slideAnimation`.
  /// Holds the `_slideAnimation` member.
  late Animation<Offset> _slideAnimation;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// يخزن العضو `_rotationAnimation`.
  /// Holds the `_rotationAnimation` member.
  late Animation<double> _rotationAnimation;

  /// يخزن العضو `_glowAnimation`.
  /// Holds the `_glowAnimation` member.
  late Animation<double> _glowAnimation;

  /// يخزن العضو `_waveAnimation`.
  /// Holds the `_waveAnimation` member.
  late Animation<double> _waveAnimation;

  /// يخزن العضو `_logoRotation`.
  /// Holds the `_logoRotation` member.
  late Animation<double> _logoRotation;

  // Particles
  /// يخزن العضو `_particles`.
  /// Holds the `_particles` member.
  final List<_UltraParticle> _particles = [];

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();

    /// ينفذ العملية `_initializeAnimations`.
    /// Runs the `_initializeAnimations` operation.
    _initializeAnimations();

    /// ينفذ العملية `_generateParticles`.
    /// Runs the `_generateParticles` operation.
    _generateParticles();

    /// ينفذ العملية `_startAnimations`.
    /// Runs the `_startAnimations` operation.
    _startAnimations();
  }

  /// ينفذ العملية `_initializeAnimations`.
  /// Runs the `_initializeAnimations` operation.
  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _logoController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _logoRotation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
  }

  /// ينفذ العملية `_generateParticles`.
  /// Runs the `_generateParticles` operation.
  void _generateParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(_UltraParticle());
    }
  }

  /// ينفذ العملية `_startAnimations`.
  /// Runs the `_startAnimations` operation.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthState,
        child: Stack(
          children: [
            // Ultra smooth background
            _buildUltraBackground(),

            // Floating particles
            _buildFloatingParticles(),

            // Main content
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildUltraBackground`.
  /// Runs the `_buildUltraBackground` operation.
  Widget _buildUltraBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _waveAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Subtle wave pattern
              CustomPaint(
                painter: _SubtleWavePainter(
                  animation: _waveAnimation.value,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.02),
                ),
                size: Size.infinite,
              ),

              // Ultra light grid
              CustomPaint(
                painter: _UltraGridPainter(
                  rotation: _rotationAnimation.value * 0.05,
                  opacity: 0.015,
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }

  /// ينفذ العملية `_buildFloatingParticles`.
  /// Runs the `_buildFloatingParticles` operation.
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _UltraParticlePainter(
            particles: _particles,
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// ينفذ العملية `_buildMainContent`.
  /// Runs the `_buildMainContent` operation.
  Widget _buildMainContent() {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildCompactHeader(),
                        const SizedBox(height: 24),
                        _buildCompactLogo(),
                        const SizedBox(height: 20),
                        _buildCompactTitle(),
                        const SizedBox(height: 28),
                        _buildUltraForm(),
                        const SizedBox(height: 20),
                        _buildLoginLink(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildCompactHeader`.
  /// Runs the `_buildCompactHeader` operation.
  Widget _buildCompactHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        if (!widget.isFirst)
          _buildGlassButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => context.pop(),
            size: 36,
          )
        else
          const SizedBox(width: 36, height: 36),

        // Language button (optional)
        const SizedBox(width: 36, height: 36),
      ],
    );
  }

  /// ينفذ العملية `_buildGlassButton`.
  /// Runs the `_buildGlassButton` operation.
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.4),
              AppTheme.darkCard.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(
              icon,
              color: AppTheme.textWhite.withValues(alpha: 0.8),
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildCompactLogo`.
  /// Runs the `_buildCompactLogo` operation.
  Widget _buildCompactLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoRotation, _glowAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _logoRotation.value,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(
                    alpha: 0.2 + 0.1 * _glowAnimation.value,
                  ),
                  blurRadius: 20 + 10 * _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: AppLogoWidget(
                      width: 34,
                      height: 34,
                      showAdaptiveBackground: true,
                      semanticsLabel: 'hggzkportal-logo',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ينفذ العملية `_buildCompactTitle`.
  /// Runs the `_buildCompactTitle` operation.
  Widget _buildCompactTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'إنشاء حساب',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'انضم واستمتع بتجربة فريدة',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.6),
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  /// ينفذ العملية `_buildUltraForm`.
  /// Runs the `_buildUltraForm` operation.
  Widget _buildUltraForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return RegisterForm(
                isProfileCompletion: widget.isFirst,
                initialName: widget.isFirst
                    ? (context.read<AuthBloc>().state is AuthAuthenticated
                        ? (context.read<AuthBloc>().state as AuthAuthenticated)
                            .user
                            .name
                        : null)
                    : null,
                initialEmail: widget.isFirst
                    ? (context.read<AuthBloc>().state is AuthAuthenticated
                        ? (context.read<AuthBloc>().state as AuthAuthenticated)
                            .user
                            .email
                        : null)
                    : null,
                initialPhone: widget.isFirst
                    ? (context.read<AuthBloc>().state is AuthAuthenticated
                        ? (context.read<AuthBloc>().state as AuthAuthenticated)
                            .user
                            .phone
                        : null)
                    : null,
                onSubmit: (
                  name,
                  email,
                  phone,
                  password,
                  passwordConfirmation,
                  propertyTypeId,
                  propertyName,
                  city,
                  address,
                  latitude,
                  longitude,
                  description,
                  walletAccounts,
                ) {
                  if (widget.isFirst) {
                    context.read<AuthBloc>().add(
                          CompleteOwnerProfileEvent(
                            name: name,
                            phone: phone,
                            propertyTypeId: propertyTypeId,
                            propertyName: propertyName,
                            city: city,
                            address: address,
                            latitude: latitude,
                            longitude: longitude,
                            description: description,
                            walletAccounts: walletAccounts,
                          ),
                        );
                  } else {
                    // استخدام endpoint تسجيل المالك مع إنشاء العقار
                    // الباك إند يُسند دور Owner تلقائياً
                    context.read<AuthBloc>().add(
                          RegisterOwnerWithPropertyEvent(
                            name: name,
                            email: email,
                            phone: phone,
                            password: password,
                            propertyTypeId: propertyTypeId,
                            propertyName: propertyName,
                            city: city,
                            address: address,
                            latitude: latitude,
                            longitude: longitude,
                            description: description,
                            walletAccounts: walletAccounts,
                          ),
                        );
                  }
                },
                isLoading: state is AuthLoading,
              );
            },
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildLoginLink`.
  /// Runs the `_buildLoginLink` operation.
  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'لديك حساب؟',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(RouteConstants.login);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.primaryPurple.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'سجل دخول',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_handleAuthState`.
  /// Runs the `_handleAuthState` operation.
  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthRegistrationSuccess) {
      HapticFeedback.mediumImpact();
      // بعد التسجيل الناجح، انتقل لصفحة التحقق من البريد
      context.go(RouteConstants.verifyEmail);
    } else if (state is AuthAuthenticated) {
      HapticFeedback.mediumImpact();
      if (state.user.requiresProfileCompletion) {
        context.go('/complete-profile');
        return;
      }
      if (state.user.isEmailVerified) {
        context.go(RouteConstants.main);
      } else {
        context.go(RouteConstants.verifyEmail);
      }
    } else if (state is AuthError) {
      _showUltraErrorSnackBar(state.message);
    }
  }

  /// ينفذ العملية `_showUltraErrorSnackBar`.
  /// Runs the `_showUltraErrorSnackBar` operation.
  void _showUltraErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.error.withValues(alpha: 0.8),
                      AppTheme.error.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'خطأ',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.darkCard.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Ultra light particle model
/// يعرّف الكلاس `_UltraParticle`.
/// Describes the `_UltraParticle` class.
class _UltraParticle {
  /// Holds the `y` value.
  /// العربية: يخزن القيمة `y`.
  late double x, y;

  /// يخزن العضو `vy`.
  /// Holds the `vy` member.
  late double vx, vy;

  /// يخزن العضو `radius`.
  /// Holds the `radius` member.
  late double radius;

  /// يخزن العضو `opacity`.
  /// Holds the `opacity` member.
  late double opacity;

  /// يخزن العضو `color`.
  /// Holds the `color` member.
  late Color color;

  /// ينشئ مثيلاً من `_UltraParticle`.
  /// Builds an instance of `_UltraParticle`.
  _UltraParticle() {
    reset();
  }

  /// ينفذ العملية `reset`.
  /// Runs the `reset` operation.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0003;
    vy = (math.Random().nextDouble() - 0.5) * 0.0003;
    radius = math.Random().nextDouble() + 0.5;
    opacity = math.Random().nextDouble() * 0.1 + 0.02;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  /// ينفذ العملية `update`.
  /// Runs the `update` operation.
  void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// Custom Painters
/// يعرّف الكلاس `_UltraParticlePainter`.
/// Describes the `_UltraParticlePainter` class.
class _UltraParticlePainter extends CustomPainter {
  /// Holds the `particles` value.
  /// العربية: يخزن القيمة `particles`.
  final List<_UltraParticle> particles;

  /// يخزن العضو `animationValue`.
  /// Holds the `animationValue` member.
  final double animationValue;

  /// ينشئ مثيلاً من `_UltraParticlePainter`.
  /// Builds an instance of `_UltraParticlePainter`.
  _UltraParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  /// ينفذ العملية `paint`.
  /// Runs the `paint` operation.
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  /// ينفذ العملية `shouldRepaint`.
  /// Runs the `shouldRepaint` operation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يعرّف الكلاس `_SubtleWavePainter`.
/// Describes the `_SubtleWavePainter` class.
class _SubtleWavePainter extends CustomPainter {
  /// Holds the `animation` value.
  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// يخزن العضو `color`.
  /// Holds the `color` member.
  final Color color;

  /// ينشئ مثيلاً من `_SubtleWavePainter`.
  /// Builds an instance of `_SubtleWavePainter`.
  _SubtleWavePainter({
    required this.animation,
    required this.color,
  });

  /// ينفذ العملية `paint`.
  /// Runs the `paint` operation.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.95 +
          math.sin((x / size.width * 2 * math.pi) + (animation * 2 * math.pi)) *
              10;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// ينفذ العملية `shouldRepaint`.
  /// Runs the `shouldRepaint` operation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يعرّف الكلاس `_UltraGridPainter`.
/// Describes the `_UltraGridPainter` class.
class _UltraGridPainter extends CustomPainter {
  /// Holds the `rotation` value.
  /// العربية: يخزن القيمة `rotation`.
  final double rotation;

  /// يخزن العضو `opacity`.
  /// Holds the `opacity` member.
  final double opacity;

  /// ينشئ مثيلاً من `_UltraGridPainter`.
  /// Builds an instance of `_UltraGridPainter`.
  _UltraGridPainter({
    required this.rotation,
    required this.opacity,
  });

  /// ينفذ العملية `paint`.
  /// Runs the `paint` operation.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.15;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    const spacing = 30.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height * 2),
        paint,
      );
    }

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      canvas.drawLine(
        Offset(-size.width, y),
        Offset(size.width * 2, y),
        paint,
      );
    }

    canvas.restore();
  }

  /// ينفذ العملية `shouldRepaint`.
  /// Runs the `shouldRepaint` operation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
