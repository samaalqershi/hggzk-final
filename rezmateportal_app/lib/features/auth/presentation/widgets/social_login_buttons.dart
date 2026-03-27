import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SocialLoginButtons extends StatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _isLoadingShown = false;
  bool _isSocialAuthInFlight = false;
  OverlayEntry? _loadingOverlayEntry;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!_isSocialAuthInFlight) return;
        if (state is AuthLoading) {
          _showLoadingOverlay();
          return;
        }
        _hideLoadingOverlay();
        _isSocialAuthInFlight = false;
      },
      child: Column(
        children: [
          _FuturisticSocialButton(
            icon: 'assets/icons/google.svg',
            fallbackIcon: Icons.g_mobiledata,
            label: 'Google',
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderColor: Colors.white.withValues(alpha: 0.2),
            onPressed: () => _handleSocialLogin(
              context,
              SocialLoginProvider.google,
            ),
          ),
          const SizedBox(height: 16),
          _FuturisticSocialButton(
            icon: 'assets/icons/facebook.svg',
            fallbackIcon: Icons.facebook,
            label: 'Facebook',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1877F2).withValues(alpha: 0.2),
                const Color(0xFF1877F2).withValues(alpha: 0.1),
              ],
            ),
            borderColor: const Color(0xFF1877F2).withValues(alpha: 0.3),
            onPressed: () => _handleSocialLogin(
              context,
              SocialLoginProvider.facebook,
            ),
          ),
          const SizedBox(height: 16),
          _FuturisticSocialButton(
            icon: 'assets/icons/apple.svg',
            fallbackIcon: Icons.apple,
            label: 'Apple',
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderColor: Colors.white.withValues(alpha: 0.2),
            onPressed: () => _handleSocialLogin(
              context,
              SocialLoginProvider.apple,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideLoadingOverlay();
    super.dispose();
  }

  void _showLoadingOverlay() {
    if (!mounted || _isLoadingShown) return;
    _isLoadingShown = true;
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;
    _loadingOverlayEntry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          ignoring: true,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
                const Center(
                  child: LoadingWidget(
                    type: LoadingType.futuristic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    overlay.insert(_loadingOverlayEntry!);
  }

  void _hideLoadingOverlay() {
    if (!_isLoadingShown) return;
    _isLoadingShown = false;
    _loadingOverlayEntry?.remove();
    _loadingOverlayEntry = null;
  }

  void _handleSocialLogin(BuildContext context, SocialLoginProvider provider) {
    switch (provider) {
      case SocialLoginProvider.google:
        _handleGoogleLogin(context);
        return;
      case SocialLoginProvider.facebook:
        _showErrorSnackBar(
          'تسجيل الدخول عبر ${_getProviderLabel(provider)} غير متاح حالياً',
        );
        return;
      case SocialLoginProvider.apple:
        _handleAppleLogin(context);
        return;
    }
  }

  String _getProviderLabel(SocialLoginProvider provider) {
    switch (provider) {
      case SocialLoginProvider.google:
        return 'Google';
      case SocialLoginProvider.facebook:
        return 'Facebook';
      case SocialLoginProvider.apple:
        return 'Apple';
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    _isSocialAuthInFlight = true;
    _showLoadingOverlay();
    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        _isSocialAuthInFlight = false;
        _hideLoadingOverlay();
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken ?? '';
      if (idToken.isEmpty) {
        _isSocialAuthInFlight = false;
        _hideLoadingOverlay();
        return;
      }

      context.read<AuthBloc>().add(
            SocialLoginEvent(
              provider: SocialLoginProvider.google,
              token: idToken,
            ),
          );
    } catch (_) {
      _isSocialAuthInFlight = false;
      _hideLoadingOverlay();
    }
  }

  Future<void> _handleAppleLogin(BuildContext context) async {
    _isSocialAuthInFlight = true;
    _showLoadingOverlay();
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final WebAuthenticationOptions? webAuthOptions;
      if (kIsWeb) {
        _isSocialAuthInFlight = false;
        _hideLoadingOverlay();
        _showErrorSnackBar('تسجيل الدخول عبر Apple غير مدعوم على Web في هذا الإصدار');
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (AppConstants.appleRedirectUri.isEmpty) {
          _isSocialAuthInFlight = false;
          _hideLoadingOverlay();
          _showErrorSnackBar(
            'Apple Sign-In على Android يحتاج Redirect URI (https) مضبوط في AppConstants.appleRedirectUri ومُسجل في Apple Developer Services ID (${AppConstants.appleServiceId}).',
          );
          return;
        }
        webAuthOptions = WebAuthenticationOptions(
          clientId: AppConstants.appleServiceId,
          redirectUri: Uri.parse(AppConstants.appleRedirectUri),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        webAuthOptions = null;
      } else {
        _isSocialAuthInFlight = false;
        _hideLoadingOverlay();
        _showErrorSnackBar('تسجيل الدخول عبر Apple غير مدعوم على هذه المنصة');
        return;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: webAuthOptions,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        _isSocialAuthInFlight = false;
        _hideLoadingOverlay();
        return;
      }

      final appleFullName = [
        credential.givenName,
        credential.familyName,
      ].where((e) => (e ?? '').trim().isNotEmpty).map((e) => e!.trim()).join(' ');

      context.read<AuthBloc>().add(
            SocialLoginEvent(
              provider: SocialLoginProvider.apple,
              token: idToken,
              nonce: rawNonce,
              name: appleFullName.isEmpty ? null : appleFullName,
            ),
          );
    } catch (_) {
      _isSocialAuthInFlight = false;
      _hideLoadingOverlay();
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}

class _FuturisticSocialButton extends StatefulWidget {
  final String icon;
  final IconData fallbackIcon;
  final String label;
  final LinearGradient gradient;
  final Color borderColor;
  final VoidCallback onPressed;

  const _FuturisticSocialButton({
    required this.icon,
    required this.fallbackIcon,
    required this.label,
    required this.gradient,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  State<_FuturisticSocialButton> createState() => 
      _FuturisticSocialButtonState();
}

class _FuturisticSocialButtonState extends State<_FuturisticSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
        setState(() => _isHovered = true);
      },
      onTapUp: (_) {
        _animationController.reverse();
        setState(() => _isHovered = false);
        widget.onPressed();
      },
      onTapCancel: () {
        _animationController.reverse();
        setState(() => _isHovered = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? widget.borderColor
                    : widget.borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.borderColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.fallbackIcon,
                            size: 24,
                            color: AppTheme.textWhite,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'تسجيل الدخول بـ ${widget.label}',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppTheme.textWhite,
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
      ),
    );
  }
}