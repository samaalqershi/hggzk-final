// lib/features/auth/presentation/pages/profile_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/bloc/app_bloc.dart';
import '../../../../core/bloc/theme/theme_bloc.dart';
import '../../../../core/bloc/theme/theme_event.dart';
import '../../../../core/bloc/theme/theme_state.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/upload_user_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _subtleGlowController;
  late AnimationController _themeSwitchController;
  late Animation<double> _themeSwitchRotation;
  late Animation<double> _themeSwitchScale;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _subtleGlowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _themeSwitchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _themeSwitchRotation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _themeSwitchController,
      curve: Curves.easeInOut,
    ));

    _themeSwitchScale = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _themeSwitchController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _subtleGlowController.dispose();
    _themeSwitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) {
          // Avoid rebuilding on transient loading to prevent flicker to unauthenticated view
          return current is! AuthLoading;
        },
        builder: (context, state) {
          if (state is AuthUnauthenticated) {
            return _buildUnauthenticatedView(context);
          }

          // Extract user from states that carry it to keep UI stable during updates
          final dynamic user = state is AuthAuthenticated
              ? state.user
              : state is AuthProfileUpdateSuccess
                  ? state.user
                  : state is AuthProfileImageUploadSuccess
                      ? state.user
                      : state is AuthLoginSuccess
                          ? state.user
                          : null;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              _buildMinimalBackground(),

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildMinimalAppBar(context, user),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: Column(
                        children: [
                          _buildProfileHeader(context, user),
                          const SizedBox(height: 20),
                          _buildMinimalInfoCard(user),
                          const SizedBox(height: 16),
                          _buildMinimalMenuOptions(context),
                          const SizedBox(height: 16),
                          _buildLogoutButton(context),
                          const SizedBox(height: 12),
                          _buildDeleteAccountButton(context),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // زر تبديل الثيم العائم
              _buildFloatingThemeToggle(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMinimalBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkSurface.withOpacity(0.8),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _subtleGlowController,
        builder: (context, child) {
          return CustomPaint(
            painter: _MinimalBackgroundPainter(
              animationValue: _subtleGlowController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkSurface.withOpacity(0.95),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withOpacity(0.3),
                      AppTheme.darkCard.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'يرجى تسجيل الدخول',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'قم بتسجيل الدخول للوصول إلى ملفك الشخصي',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildMinimalButton(
                onPressed: () => context.push(RouteConstants.login),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تسجيل الدخول',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalAppBar(BuildContext context, dynamic user) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue.withOpacity(0.08),
                AppTheme.darkBackground.withOpacity(0.95),
              ],
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppTheme.darkCard.withOpacity(0.1),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'الملف الشخصي',
                          style: AppTextStyles.h2.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AppTheme.textWhite,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _subtleGlowController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(
                            0.08 + (_subtleGlowController.value * 0.04),
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              UploadUserImage(
                currentImageUrl: user.profileImage,
                onImageSelected: (imagePath) {
                  context.read<AuthBloc>().add(
                        UploadProfileImageEvent(imagePath: imagePath),
                      );
                },
                size: 90,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: user.isVerified
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: user.isVerified
                    ? AppTheme.success.withOpacity(0.25)
                    : AppTheme.warning.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isVerified
                      ? Icons.verified_rounded
                      : Icons.pending_rounded,
                  size: 14,
                  color: user.isVerified ? AppTheme.success : AppTheme.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isVerified ? 'حساب موثق' : 'في انتظار التحقق',
                  style: AppTextStyles.caption.copyWith(
                    color:
                        user.isVerified ? AppTheme.success : AppTheme.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalInfoCard(dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkCard.withOpacity(0.25),
              AppTheme.darkCard.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                _buildMinimalInfoRow(
                  icon: Icons.email_outlined,
                  label: 'البريد الإلكتروني',
                  value: user.email,
                  verified: user.isEmailVerified,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool? verified,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (verified != null)
                      Icon(
                        verified ? Icons.check_circle : Icons.error_outline,
                        size: 14,
                        color: verified
                            ? AppTheme.success.withOpacity(0.8)
                            : AppTheme.warning.withOpacity(0.8),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.darkBorder.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // زر تبديل الثيم العائم - يستخدم AppBloc.theme
  Widget _buildFloatingThemeToggle() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      bloc: AppBloc.theme, // استخدام ThemeBloc من AppBloc
      builder: (context, themeState) {
        final isDark = themeState.themeMode == ThemeMode.dark;

        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _themeSwitchController.forward().then((_) {
                      _themeSwitchController.reverse();
                    });
                    AppBloc.theme
                        .add(const ToggleThemeEvent()); // استخدام AppBloc.theme
                  },
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _themeSwitchRotation,
                      _themeSwitchScale,
                      _subtleGlowController,
                    ]),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _themeSwitchRotation.value,
                        child: Transform.scale(
                          scale: _themeSwitchScale.value,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        const Color(0xFFFDB813)
                                            .withOpacity(0.15),
                                        const Color(0xFFFFE082)
                                            .withOpacity(0.08),
                                      ]
                                    : [
                                        const Color(0xFF6366F1)
                                            .withOpacity(0.15),
                                        const Color(0xFF8B5CF6)
                                            .withOpacity(0.08),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFFDB813).withOpacity(
                                        0.2 + _subtleGlowController.value * 0.1)
                                    : const Color(0xFF6366F1).withOpacity(0.2 +
                                        _subtleGlowController.value * 0.1),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0xFFFDB813).withOpacity(
                                          0.1 +
                                              _subtleGlowController.value *
                                                  0.05)
                                      : const Color(0xFF6366F1).withOpacity(
                                          0.1 +
                                              _subtleGlowController.value *
                                                  0.05),
                                  blurRadius:
                                      12 + _subtleGlowController.value * 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: isDark
                                              ? [
                                                  const Color(0xFFFDB813)
                                                      .withOpacity(0.05),
                                                  Colors.transparent,
                                                ]
                                              : [
                                                  const Color(0xFF6366F1)
                                                      .withOpacity(0.05),
                                                  Colors.transparent,
                                                ],
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: RotationTransition(
                                            turns: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        isDark
                                            ? Icons.light_mode_rounded
                                            : Icons.dark_mode_rounded,
                                        key: ValueKey(isDark),
                                        size: 20,
                                        color: isDark
                                            ? const Color(0xFFFDB813)
                                            : const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ],
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
            },
          ),
        );
      },
    );
  }

  // إضافة خيار تبديل الثيم في القائمة
  Widget _buildThemeToggleMenuItem() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      bloc: AppBloc.theme, // استخدام AppBloc.theme
      builder: (context, themeState) {
        final isDark = themeState.themeMode == ThemeMode.dark;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _themeSwitchController.forward().then((_) {
                _themeSwitchController.reverse();
              });
              AppBloc.theme
                  .add(const ToggleThemeEvent()); // استخدام AppBloc.theme
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _themeSwitchController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _themeSwitchRotation.value,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFFFDB813).withOpacity(0.15),
                                      const Color(0xFFFFE082).withOpacity(0.08),
                                    ]
                                  : [
                                      const Color(0xFF6366F1).withOpacity(0.15),
                                      const Color(0xFF8B5CF6).withOpacity(0.08),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFFDB813).withOpacity(0.2)
                                  : const Color(0xFF6366F1).withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              key: ValueKey(isDark),
                              color: isDark
                                  ? const Color(0xFFFDB813)
                                  : const Color(0xFF6366F1),
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مظهر التطبيق',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildUltraSwitch(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraSwitch(bool value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: value
              ? [
                  const Color(0xFF6366F1).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.15),
                ]
              : [
                  AppTheme.darkBorder.withOpacity(0.15),
                  AppTheme.darkBorder.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: value
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            left: value ? 22 : 2,
            top: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: value
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.darkCard.withOpacity(0.5),
                          AppTheme.darkCard.withOpacity(0.3),
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: value
                        ? const Color(0xFF6366F1).withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    value ? Icons.dark_mode : Icons.light_mode,
                    key: ValueKey(value),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalToggleMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required bool value,
    required bool loading,
    ValueChanged<bool>? onChanged,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, animationValue, child) {
        return Opacity(
          opacity: animationValue,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (!loading && onChanged != null)
                  ? () => onChanged(!value)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: color.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 54,
                      height: 30,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: value
                            ? LinearGradient(
                                colors: [
                                  color.withOpacity(0.95),
                                  color.withOpacity(0.7),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  AppTheme.darkCard.withOpacity(0.5),
                                  AppTheme.darkCard.withOpacity(0.3),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: value
                              ? color.withOpacity(0.15)
                              : AppTheme.darkBorder.withOpacity(0.25),
                          width: 0.5,
                        ),
                      ),
                      child: loading
                          ? Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    value ? Colors.white : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            )
                          : AnimatedAlign(
                              duration: const Duration(milliseconds: 220),
                              alignment: value
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
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

  Widget _buildBiometricToggleMenuItem(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final bool isLoading =
            state is SettingsLoading || state is SettingsInitial;
        final bool isUpdating = state is SettingsUpdating;

        AppSettings? settings;
        if (state is SettingsLoaded) {
          settings = state.settings;
        } else if (state is SettingsUpdated) {
          settings = state.settings;
        } else if (state is SettingsUpdating) {
          settings = state.currentSettings;
        } else if (state is SettingsError && state.lastKnownSettings != null) {
          settings = state.lastKnownSettings;
        }

        final bool biometricEnabled = settings?.biometricEnabled ?? false;
        final bool showLoading = isLoading || isUpdating;

        return _buildMinimalToggleMenuItem(
          icon: Icons.fingerprint_rounded,
          title: 'تسجيل الدخول بالبصمة',
          subtitle: 'فعّل لتسجيل الدخول السريع باستخدام البصمة',
          color: AppTheme.primaryPurple,
          value: biometricEnabled,
          loading: showLoading,
          onChanged: showLoading
              ? null
              : (enabled) {
                  context
                      .read<SettingsBloc>()
                      .add(UpdateBiometricEvent(enabled));
                },
        );
      },
    );
  }

  Widget _buildMinimalMenuOptions(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.edit_outlined,
        'title': 'تعديل الملف الشخصي',
        'route': RouteConstants.editProfile,
        'extra': null,
        'color': AppTheme.primaryBlue,
        'widget': null,
      },
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'تغيير كلمة المرور',
        'route': RouteConstants.changePassword,
        'extra': null,
        'color': AppTheme.primaryPurple,
        'widget': null,
      },
      {
        'icon': Icons.palette_outlined,
        'title': 'مظهر التطبيق',
        'route': null,
        'extra': null,
        'color': const Color(0xFF6366F1),
        'widget': _buildThemeToggleMenuItem(),
      },
      {
        'icon': Icons.notifications_none_rounded,
        'title': 'إعدادات الإشعارات',
        'route': RouteConstants.notificationSettings,
        'extra': null,
        'color': AppTheme.warning,
        'widget': null,
      },
      {
        'icon': Icons.fingerprint_rounded,
        'title': 'تسجيل الدخول بالبصمة',
        'route': null,
        'extra': null,
        'color': AppTheme.primaryPurple,
        'widget': _buildBiometricToggleMenuItem(context),
      },
      {
        'icon': Icons.policy_rounded,
        'title': 'السياسات والشروط',
        'route': '/legal',
        'extra': null,
        'color': AppTheme.primaryBlue,
        'widget': null,
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'المساعدة والدعم',
        'route': '/support',
        'extra': null,
        'color': AppTheme.primaryCyan,
        'widget': null,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              children: menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                if (item['widget'] != null) {
                  return Column(
                    children: [
                      item['widget'] as Widget,
                      if (index < menuItems.length - 1)
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppTheme.darkBorder.withOpacity(0.08),
                        ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildMinimalMenuItem(
                      icon: item['icon'] as IconData,
                      title: item['title'] as String,
                      color: item['color'] as Color,
                      onTap: () {
                        final route = item['route'] as String?;
                        if (route != null) {
                          final extra = item['extra'] as Map<String, dynamic>?;
                          context.push(route, extra: extra);
                        }
                      },
                      delay: index * 50,
                    ),
                    if (index < menuItems.length - 1)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppTheme.darkBorder.withOpacity(0.08),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: color.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textMuted.withOpacity(0.5),
                      size: 14,
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

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildMinimalButton(
        onPressed: () => _showLogoutDialog(context),
        isDestructive: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'تسجيل الخروج',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalButton({
    required Widget child,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDestructive
              ? [
                  AppTheme.error.withOpacity(0.9),
                  AppTheme.error.withOpacity(0.7),
                ]
              : [
                  AppTheme.primaryBlue.withOpacity(0.9),
                  AppTheme.primaryPurple.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.15)
                : AppTheme.primaryBlue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDeleteAccountDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    color: AppTheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'حذف الحساب',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => _DeleteAccountDialog(
        onConfirm: ({
          String? password,
          String? reason,
          String? socialProvider,
          String? socialToken,
          String? socialNonce,
        }) {
          context.read<AuthBloc>().add(
                DeleteAccountEvent(
                  password: password,
                  socialProvider: socialProvider,
                  socialToken: socialToken,
                  socialNonce: socialNonce,
                  reason: reason,
                ),
              );
        },
        onSuccess: () {
          Navigator.pop(dialogContext);
          context.go(RouteConstants.login);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.darkCard.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.darkBorder.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          title: Text(
            'تسجيل الخروج',
            style: AppTextStyles.h3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.error.withOpacity(0.9),
                    AppTheme.error.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthBloc>().add(const LogoutEvent());
                    context.go(RouteConstants.login);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'تسجيل الخروج',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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

  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Minimal Background Painter
class _MinimalBackgroundPainter extends CustomPainter {
  final double animationValue;

  _MinimalBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 2; i++) {
      paint.shader = RadialGradient(
        colors: [
          AppTheme.primaryBlue.withOpacity(0.02 + animationValue * 0.01),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * (0.3 + i * 0.4),
          size.height * (0.2 + i * 0.3),
        ),
        radius: 80 + animationValue * 10,
      ));

      canvas.drawCircle(
        Offset(
          size.width * (0.3 + i * 0.4),
          size.height * (0.2 + i * 0.3),
        ),
        80 + animationValue * 10,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Dialog widget for account deletion with proper lifecycle management
class _DeleteAccountDialog extends StatefulWidget {
  final void Function({
    String? password,
    String? reason,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
  }) onConfirm;
  final VoidCallback onSuccess;

  const _DeleteAccountDialog({
    required this.onConfirm,
    required this.onSuccess,
  });

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _passwordController;
  late final TextEditingController _reasonController;
  bool _obscure = true;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSocialAuthLoading = false;
  String? _socialProvider;
  String? _socialToken;
  String? _socialNonce;
  String? _lastSocialAuthAttemptProvider;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoading || _isSocialAuthLoading;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAccountDeleteSuccess) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.success,
            ),
          );
          widget.onSuccess();
        } else if (state is AuthError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        } else if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.darkCard.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.error.withOpacity(0.2),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'حذف الحساب',
                style: AppTextStyles.h3.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عرض رسالة الخطأ إذا وجدت
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'تحذير: سيتم حذف حسابك نهائياً ولا يمكن التراجع عن هذا الإجراء.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'كلمة المرور (اختياري)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  enabled: !isBusy,
                  style: TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'أدخل كلمة المرور أو استخدم Google/Apple بالأسفل',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkBackground.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                      onPressed: isBusy
                          ? null
                          : () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child:
                          Divider(color: AppTheme.darkBorder.withOpacity(0.4)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'أو',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          Divider(color: AppTheme.darkBorder.withOpacity(0.4)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _authenticateWithGoogle,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 18),
                      label: const Text('تأكيد عبر Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textWhite,
                        side: BorderSide(
                          color: AppTheme.primaryBlue.withOpacity(0.4),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _authenticateWithApple,
                      icon: const Icon(Icons.apple, size: 18),
                      label: const Text('تأكيد عبر Apple'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textWhite,
                        side: BorderSide(
                          color: AppTheme.primaryBlue.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_socialToken != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: AppTheme.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تم تأكيد الهوية عبر ${_socialProvider == 'apple' ? 'Apple' : 'Google'}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: isBusy
                              ? null
                              : () {
                                  setState(() {
                                    _socialProvider = null;
                                    _socialToken = null;
                                    _socialNonce = null;
                                  });
                                },
                          child: Icon(
                            Icons.close_rounded,
                            color: AppTheme.success,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_isSocialAuthLoading) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'جاري التحقق من الهوية...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'سبب الحذف (اختياري)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  enabled: !isBusy,
                  style: TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'لماذا تريد حذف حسابك؟',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkBackground.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isBusy ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isBusy
                      ? AppTheme.textMuted.withOpacity(0.5)
                      : AppTheme.textMuted,
                ),
              ),
            ),
            _isLoading
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.error),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.error.withOpacity(0.9),
                          AppTheme.error.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isBusy ? null : _handleDelete,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'حذف الحساب',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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

  void _handleDelete() {
    final password = _passwordController.text.trim().isEmpty
        ? null
        : _passwordController.text.trim();
    if (password == null && _socialToken == null) {
      final attemptedProvider = _lastSocialAuthAttemptProvider;
      setState(() {
        _errorMessage = attemptedProvider == null
            ? 'أدخل كلمة المرور أو أكد هويتك عبر Google/Apple'
            : 'تعذر تأكيد الهوية عبر ${attemptedProvider == 'apple' ? 'Apple' : 'Google'}، أعد المحاولة أو أدخل كلمة المرور';
      });
      return;
    }
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    widget.onConfirm(
      password: password,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      socialProvider: _socialProvider,
      socialToken: _socialToken,
      socialNonce: _socialNonce,
    );
  }

  Future<void> _authenticateWithGoogle() async {
    setState(() {
      _isSocialAuthLoading = true;
      _errorMessage = null;
      _lastSocialAuthAttemptProvider = 'google';
    });

    try {
      final GoogleSignIn googleSignIn;
      if (kIsWeb) {
        if (AppConstants.googleWebClientId.isEmpty) {
          throw Exception('Google Web Client ID غير مُعد');
        }
        googleSignIn = GoogleSignIn(
          scopes: const ['email', 'profile'],
          clientId: AppConstants.googleWebClientId,
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final serverClientId = AppConstants.googleWebClientId.isNotEmpty
            ? AppConstants.googleWebClientId
            : null;
        googleSignIn = serverClientId == null
            ? GoogleSignIn(scopes: const ['email', 'profile'])
            : GoogleSignIn(
                scopes: const ['email', 'profile'],
                serverClientId: serverClientId,
              );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        if (AppConstants.googleIosClientId.isEmpty) {
          throw Exception('Google iOS Client ID غير مُعد');
        }
        final serverClientId = AppConstants.googleWebClientId.isNotEmpty
            ? AppConstants.googleWebClientId
            : null;
        googleSignIn = GoogleSignIn(
          scopes: const ['email', 'profile'],
          clientId: AppConstants.googleIosClientId,
          serverClientId: serverClientId,
        );
      } else {
        throw Exception('Google غير مدعوم على هذه المنصة');
      }

      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _errorMessage = 'تم إلغاء التحقق عبر Google';
        });
        return;
      }

      final auth = await account.authentication;
      final token = (auth.idToken != null && auth.idToken!.isNotEmpty)
          ? auth.idToken!
          : (auth.accessToken ?? '');
      if (token.isEmpty) {
        throw Exception('تعذر الحصول على رمز Google');
      }

      setState(() {
        _socialProvider = 'google';
        _socialToken = token;
        _socialNonce = null;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'فشل التحقق عبر Google، حاول مرة أخرى';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSocialAuthLoading = false;
        });
      }
    }
  }

  Future<void> _authenticateWithApple() async {
    setState(() {
      _isSocialAuthLoading = true;
      _errorMessage = null;
      _lastSocialAuthAttemptProvider = 'apple';
    });

    try {
      if (kIsWeb) {
        throw Exception('Apple غير مدعوم على Web');
      }
      if (defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.android) {
        throw Exception('Apple غير مدعوم على هذه المنصة');
      }

      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final WebAuthenticationOptions? webAuthOptions;
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (AppConstants.appleRedirectUri.isEmpty) {
          throw Exception('Apple Redirect URI غير مُعد');
        }
        webAuthOptions = WebAuthenticationOptions(
          clientId: AppConstants.appleServiceId,
          redirectUri: Uri.parse(AppConstants.appleRedirectUri),
        );
      } else {
        webAuthOptions = null;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: webAuthOptions,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('تعذر الحصول على رمز Apple');
      }

      setState(() {
        _socialProvider = 'apple';
        _socialToken = idToken;
        _socialNonce = rawNonce;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'فشل التحقق عبر Apple، حاول مرة أخرى';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSocialAuthLoading = false;
        });
      }
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
