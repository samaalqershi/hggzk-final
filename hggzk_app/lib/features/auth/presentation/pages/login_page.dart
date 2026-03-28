import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/app_logo_widget.dart';
import 'package:hggzk/core/services/biometric_auth_service.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/social_login_buttons.dart';

/// تعرض شاشة تسجيل الدخول الرئيسية مع النموذج التقليدي وخيارات الدخول
/// الاجتماعي وحالة الاسترجاع البيومتري عند توفرها.
/// Presents the main sign-in screen with the classic form, social login
/// options, and biometric restoration when available.
class LoginPage extends StatefulWidget {
  /// ينشئ شاشة تسجيل الدخول.
  /// Creates the login screen.
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // ============ Animation Controllers ============
  late AnimationController _backgroundAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _glowAnimationController;

  // ============ Animations ============
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // ============ Particles ============
  final List<_FloatingParticle> _particles = [];

  // ============ Constants ============
  static const double _horizontalPadding = 24.0;
  static const double _cardPadding = 28.0;
  static const double _cardBorderRadius = 24.0;
  final BiometricAuthService _biometric = BiometricAuthService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsBloc = context.read<SettingsBloc>();
    final state = settingsBloc.state;
    if (state is! SettingsLoaded && state is! SettingsUpdated) {
      settingsBloc.add(LoadSettingsEvent());
    }
    _initBiometricStatus();
  }

  void _initializeAnimations() {
    // Background Animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);

    // Form Animation
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Particle Animation
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Glow Animation
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _generateParticles() {
    for (int i = 0; i < 12; i++) {
      _particles.add(_FloatingParticle());
    }
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _formAnimationController.forward();
    });
  }

  Future<void> _initBiometricStatus() async {
    final settingsBloc = context.read<SettingsBloc>();
    final supported = await _biometric.isDeviceSupported();
    final canCheck = await _biometric.canCheckBiometrics();
    if (!mounted) return;
    final settingsState = settingsBloc.state;
    final enabled = settingsState is SettingsLoaded
        ? settingsState.settings.biometricEnabled
        : settingsState is SettingsUpdated
            ? settingsState.settings.biometricEnabled
            : false;
    if (mounted) {
      setState(() {
        _biometricAvailable = supported && canCheck;
        _biometricEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _formAnimationController.dispose();
    _particleAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthState,
        child: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(),

            // Floating Particles
            _buildParticles(),

            // Main Content
            SafeArea(
              child: AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildMainContent(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Header Section
          _buildHeader(),

          const SizedBox(height: 40),

          // Login Form Card
          _buildLoginFormCard(),

          const SizedBox(height: 32),

          // Divider
          _buildDivider(),

          const SizedBox(height: 32),

          // Social Login
          _buildSocialLogin(),

          const SizedBox(height: 32),

          // Register Link
          _buildRegisterLink(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============ Background Widgets ============
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
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
          child: CustomPaint(
            painter: _BackgroundPatternPainter(
              rotation: _rotationAnimation.value,
              glowIntensity: _glowAnimationController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _particleAnimationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  // ============ Header Section ============
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with Glow Effect
        _buildLogo(),

        const SizedBox(height: 24),

        // App Name
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'hggzk',
            style: AppTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Welcome Text
        Text(
          'مرحباً بعودتك',
          style: AppTextStyles.h4.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          'سجل دخولك للمتابعة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow
        AnimatedBuilder(
          animation: _glowAnimationController,
          builder: (context, child) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(
                      0.15 + (_glowAnimationController.value * 0.2),
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),

        // Logo Container
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppTheme.darkCard.withOpacity(0.3),
                child: Center(
                  child: const AppLogoWidget(
                    width: 52,
                    height: 52,
                    showAdaptiveBackground: true,
                    semanticsLabel: 'hggzk-logo',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ Login Form Card ============
  Widget _buildLoginFormCard() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Title
              Text(
                'تسجيل الدخول',
                style: AppTextStyles.h3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // Card Subtitle
              Text(
                'أدخل بياناتك للمتابعة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Login Form
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return LoginForm(
                    onSubmit: (emailOrPhone, password, rememberMe) {
                      context.read<AuthBloc>().add(
                            LoginEvent(
                              emailOrPhone: emailOrPhone,
                              password: password,
                              rememberMe: rememberMe,
                            ),
                          );
                    },
                    isLoading: state is AuthLoading,
                  );
                },
              ),
              if (_biometricAvailable && _biometricEnabled) ...[
                const SizedBox(height: 20),
                _buildBiometricButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'أو سجّل الدخول بالبصمة',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onBiometricLoginPressed,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkCard.withOpacity(0.95),
                      AppTheme.darkCard.withOpacity(0.75),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.28),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      size: 38,
                      color: Colors.white,
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

  Future<void> _onBiometricLoginPressed() async {
    final result =
        await _biometric.authenticate(reason: 'تأكيد هويتك لتسجيل الدخول');

    if (!result.isSuccess) {
      if (mounted && result.message != null) {
        _showErrorSnackBar(result.message!);
      }
      return;
    }

    String? refreshToken = await _biometric.getSecureRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      final localStorage = sl<LocalStorageService>();
      final stored = localStorage.getData(StorageConstants.refreshToken);
      if (stored is String && stored.isNotEmpty) {
        try {
          await _biometric.saveRefreshTokenSecurely(stored);
          refreshToken = stored;
        } catch (_) {}
      }
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      _showErrorSnackBar(
        'لا يوجد رمز تحديث محفوظ. يرجى تسجيل الدخول مرة واحدة أولاً.',
      );
      return;
    }

    if (!mounted) return;
    context.read<AuthBloc>().add(
          LoginWithRefreshTokenEvent(refreshToken: refreshToken),
        );
  }

  // ============ Divider ============
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.darkBorder.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.2),
              ),
            ),
            child: Text(
              'أو',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkBorder.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ Social Login ============
  Widget _buildSocialLogin() {
    return const SocialLoginButtons();
  }

  // ============ Register Link ============
  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ليس لديك حساب؟',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          TextButton(
            onPressed: () => context.push(RouteConstants.register),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                'سجل الآن',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ Auth State Handler ============
  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthLoginSuccess) {
      final user = state.user;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      final decodedFrom =
          (from == null || from.isEmpty) ? null : Uri.decodeComponent(from);

      if (user.isEmailVerified) {
        if (decodedFrom != null && !decodedFrom.startsWith('/login')) {
          context.replace(decodedFrom);
        } else {
          context.go(RouteConstants.main);
        }
      } else {
        context.go(RouteConstants.verifyOtp);
      }
    } else if (state is AuthAuthenticated) {
      final user = state.user;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      final decodedFrom =
          (from == null || from.isEmpty) ? null : Uri.decodeComponent(from);

      if (user.isEmailVerified) {
        if (decodedFrom != null && !decodedFrom.startsWith('/login')) {
          context.replace(decodedFrom);
        } else {
          context.go(RouteConstants.main);
        }
      } else {
        context.go(RouteConstants.verifyOtp);
      }
    } else if (state is AuthError) {
      _showErrorSnackBar(state.message);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.error.withOpacity(0.9),
                AppTheme.error,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.error.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'خطأ في تسجيل الدخول',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// ============ Background Pattern Painter ============
class _BackgroundPatternPainter extends CustomPainter {
  final double rotation;
  final double glowIntensity;
  _BackgroundPatternPainter({
    required this.rotation,
    required this.glowIntensity,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      paint.shader = RadialGradient(
        colors: [
          AppTheme.primaryBlue.withOpacity(0.08 + (glowIntensity * 0.08)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 250));

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation + (i * math.pi / 3));
      canvas.translate(-center.dx, -center.dy);

      canvas.drawCircle(
        Offset(center.dx + 80, center.dy),
        60 + (i * 40),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ Floating Particle Model ============
class _FloatingParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double radius;
  late double opacity;
  late Color color;
  _FloatingParticle() {
    reset();
  }
  void reset() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    vx = (random.nextDouble() - 0.5) * 0.0015;
    vy = (random.nextDouble() - 0.5) * 0.0015;
    radius = random.nextDouble() * 2.5 + 1;
    opacity = random.nextDouble() * 0.4 + 0.1;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// ============ Particle Painter ============
class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double animationValue;
  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
