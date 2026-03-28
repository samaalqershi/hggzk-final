// lib/features/auth/presentation/pages/login_page.dart

import 'package:hggzkportal/injection_container.dart';
import 'package:hggzkportal/core/constants/storage_constants.dart';
import 'package:hggzkportal/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/app_logo_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/social_login_buttons.dart';
import '../../../../services/biometric_auth_service.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../settings/presentation/bloc/settings_event.dart';

/// يعرّف الكلاس `LoginPage`.
/// Describes the `LoginPage` class.
class LoginPage extends StatefulWidget {
  /// Initializes a new `LoginPage` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `LoginPage`.
  const LoginPage({super.key});

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// يعرّف الكلاس `_LoginPageState`.
/// Describes the `_LoginPageState` class.
class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Optimized animation controllers
  /// يخزن العضو `_mainAnimationController`.
  /// Holds the `_mainAnimationController` member.
  late AnimationController _mainAnimationController;

  /// يخزن العضو `_floatingAnimationController`.
  /// Holds the `_floatingAnimationController` member.
  late AnimationController _floatingAnimationController;

  // Simplified animations
  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// يخزن العضو `_slideAnimation`.
  /// Holds the `_slideAnimation` member.
  late Animation<Offset> _slideAnimation;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// يخزن العضو `_floatingAnimation`.
  /// Holds the `_floatingAnimation` member.
  late Animation<double> _floatingAnimation;

  // Remove complex particle systems for performance
  final ScrollController _scrollController = ScrollController();

  final BiometricAuthService _biometric = BiometricAuthService();

  /// يخزن العضو `_biometricAvailable`.
  /// Holds the `_biometricAvailable` member.
  bool _biometricAvailable = false;

  /// يخزن العضو `_biometricEnabled`.
  /// Holds the `_biometricEnabled` member.
  bool _biometricEnabled = false;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// ينفذ العملية `_initializeAnimations`.
  /// Runs the `_initializeAnimations` operation.
  void _initializeAnimations() {
    // Main animations
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    // Simple floating animation
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  /// ينفذ العملية `didChangeDependencies`.
  /// Runs the `didChangeDependencies` operation.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure settings are loaded and read biometric flag
    final settingsBloc = context.read<SettingsBloc>();
    final state = settingsBloc.state;
    if (state is! SettingsLoaded && state is! SettingsUpdated) {
      settingsBloc.add(LoadSettingsEvent());
    }
    _initBiometricStatus();
  }

  /// ينفذ العملية `_initBiometricStatus`.
  /// Runs the `_initBiometricStatus` operation.
  Future<void> _initBiometricStatus() async {
    final supported = await _biometric.isDeviceSupported();
    final canCheck = await _biometric.canCheckBiometrics();
    final settingsState = context.read<SettingsBloc>().state;
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

  /// ينفذ العملية `_startAnimations`.
  /// Runs the `_startAnimations` operation.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _mainAnimationController.forward();
      }
    });
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _scrollController.dispose();
    _mainAnimationController.dispose();
    _floatingAnimationController.dispose();
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
            // Simplified background
            _buildOptimizedBackground(),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          _buildHeader(),
                          const SizedBox(height: 50),
                          _buildLoginCard(),
                          const SizedBox(height: 40),
                          _buildDivider(),
                          const SizedBox(height: 30),
                          const SocialLoginButtons(),
                          const SizedBox(height: 40),
                          _buildFooter(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildOptimizedBackground`.
  /// Runs the `_buildOptimizedBackground` operation.
  Widget _buildOptimizedBackground() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkBackground,
                    AppTheme.darkBackground2.withValues(alpha: 0.8),
                    AppTheme.darkBackground3.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

            // Simple floating orbs - no complex CustomPaint
            Positioned(
              top: -100 + _floatingAnimation.value,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.08),
                      AppTheme.primaryBlue.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -150 - _floatingAnimation.value,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.06),
                      AppTheme.primaryPurple.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ينفذ العملية `_buildHeader`.
  /// Runs the `_buildHeader` operation.
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: const AppLogoWidget(
              width: 58,
              height: 58,
              showAdaptiveBackground: true,
              semanticsLabel: 'hggzkportal-logo',
            ),
          ),
        ),

        const SizedBox(height: 24),

        // App name
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'hggzk',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'نظام إدارة الحجوزات',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  /// ينفذ العملية `_buildLoginCard`.
  /// Runs the `_buildLoginCard` operation.
  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تسجيل الدخول',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'أدخل بياناتك للمتابعة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              if (_biometricAvailable && _biometricEnabled)
                _buildBiometricButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildBiometricButton`.
  /// Runs the `_buildBiometricButton` operation.
  Widget _buildBiometricButton() {
    return Align(
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // خلفية متحركة خلف البصمة
                    AnimatedBuilder(
                      animation: _floatingAnimationController,
                      builder: (context, child) {
                        return Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.15),
                                AppTheme.primaryPurple.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                              stops: [
                                0.3 + (_floatingAnimation.value / 50),
                                0.6 + (_floatingAnimation.value / 40),
                                1.0,
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // الزر الرئيسي
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onBiometricLoginPressed,
                        borderRadius: BorderRadius.circular(35),
                        splashColor:
                            AppTheme.primaryBlue.withValues(alpha: 0.2),
                        highlightColor:
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.darkCard.withValues(alpha: 0.9),
                                AppTheme.darkCard.withValues(alpha: 0.7),
                              ],
                            ),
                            border: Border.all(
                              width: 1.5,
                              color:
                                  AppTheme.primaryBlue.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: AppTheme.darkBackground
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // أيقونة البصمة
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryBlue,
                                    AppTheme.primaryPurple,
                                  ],
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),

                              // دائرة نابضة حول البصمة
                              AnimatedBuilder(
                                animation: _floatingAnimationController,
                                builder: (context, child) {
                                  final double scale = 1 +
                                      (0.15 *
                                          (1 +
                                                  _floatingAnimationController
                                                      .value)
                                              .abs());
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 1,
                                          color:
                                              AppTheme.primaryBlue.withValues(
                                            alpha: 0.2 *
                                                (1 -
                                                    _floatingAnimationController
                                                        .value
                                                        .abs()),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
      ),
    );
  }

  /// ينفذ العملية `_onBiometricLoginPressed`.
  /// Runs the `_onBiometricLoginPressed` operation.
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
          'لا يوجد رمز تحديث محفوظ. يرجى تسجيل الدخول مرة واحدة أولاً.');
      return;
    }

    context.read<AuthBloc>().add(
          LoginWithRefreshTokenEvent(refreshToken: refreshToken),
        );
  }

  /// ينفذ العملية `_buildDivider`.
  /// Runs the `_buildDivider` operation.
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  /// ينفذ العملية `_buildFooter`.
  /// Runs the `_buildFooter` operation.
  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ليس لديك حساب؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(RouteConstants.register);
              },
              child: Text(
                'سجل الآن',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('الشروط والأحكام'),
            _buildDot(),
            _buildFooterLink('سياسة الخصوصية'),
            _buildDot(),
            _buildFooterLink('المساعدة'),
          ],
        ),
      ],
    );
  }

  /// ينفذ العملية `_buildFooterLink`.
  /// Runs the `_buildFooterLink` operation.
  Widget _buildFooterLink(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withValues(alpha: 0.7),
          fontSize: 11,
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildDot`.
  /// Runs the `_buildDot` operation.
  Widget _buildDot() {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.textMuted.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  /// ينفذ العملية `_handleAuthState`.
  /// Runs the `_handleAuthState` operation.
  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthLoginSuccess || state is AuthAuthenticated) {
      HapticFeedback.mediumImpact();
      final user = state is AuthLoginSuccess
          ? state.user
          : (state as AuthAuthenticated).user;
      if (user.requiresProfileCompletion) {
        context.go('/complete-profile');
        return;
      }
      if (user.isEmailVerified) {
        context.go(RouteConstants.main);
      } else {
        context.go(RouteConstants.verifyEmail);
      }
    } else if (state is AuthError) {
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(state.message);
    }
  }

  /// ينفذ العملية `_showErrorSnackBar`.
  /// Runs the `_showErrorSnackBar` operation.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
