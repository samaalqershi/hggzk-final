import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// يعرّف الكلاس `SocialLoginButtons`.
/// Describes the `SocialLoginButtons` class.
class SocialLoginButtons extends StatefulWidget {
  /// Initializes a new `SocialLoginButtons` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `SocialLoginButtons`.
  const SocialLoginButtons({super.key});

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

/// يعرّف الكلاس `_SocialLoginButtonsState`.
/// Describes the `_SocialLoginButtonsState` class.
class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  /// Indicates whether `isPickerLoading` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isPickerLoading` مفعلة.
  bool _isPickerLoading = false;

  /// يخزن العضو `_isLoadingOverlayShown`.
  /// Holds the `_isLoadingOverlayShown` member.
  bool _isLoadingOverlayShown = false;

  /// يخزن العضو `_isSocialAuthInFlight`.
  /// Holds the `_isSocialAuthInFlight` member.
  bool _isSocialAuthInFlight = false;

  /// يخزن العضو `_loadingOverlayEntry`.
  /// Holds the `_loadingOverlayEntry` member.
  OverlayEntry? _loadingOverlayEntry;

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
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
            onPressed: _isPickerLoading
                ? () {}
                : () => _handleSocialLogin(SocialLoginProvider.google),
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
            onPressed: _isPickerLoading
                ? () {}
                : () => _handleSocialLogin(SocialLoginProvider.facebook),
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
            onPressed: _isPickerLoading
                ? () {}
                : () => _handleSocialLogin(SocialLoginProvider.apple),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _hideLoadingOverlay();
    super.dispose();
  }

  /// ينفذ العملية `_showLoadingOverlay`.
  /// Runs the `_showLoadingOverlay` operation.
  void _showLoadingOverlay() {
    if (!mounted || _isLoadingOverlayShown) return;
    final overlay = Overlay.of(context, rootOverlay: true);

    _isLoadingOverlayShown = true;
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
                    color: Colors.black.withValues(alpha: 0.35),
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

  /// ينفذ العملية `_hideLoadingOverlay`.
  /// Runs the `_hideLoadingOverlay` operation.
  void _hideLoadingOverlay() {
    if (!_isLoadingOverlayShown) return;
    _isLoadingOverlayShown = false;
    _loadingOverlayEntry?.remove();
    _loadingOverlayEntry = null;
  }

  /// ينفذ العملية `_handleSocialLogin`.
  /// Runs the `_handleSocialLogin` operation.
  Future<void> _handleSocialLogin(SocialLoginProvider provider) async {
    if (_isPickerLoading) return;

    try {
      switch (provider) {
        case SocialLoginProvider.google:
          await _handleGoogleLogin(provider);
          break;
        case SocialLoginProvider.facebook:
          await _handleFacebookLogin(provider);
          break;
        case SocialLoginProvider.apple:
          await _handleAppleLogin(provider);
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('Portal Social Login Error: $e');
      debugPrint('Portal Social Login StackTrace: $stackTrace');
      _isSocialAuthInFlight = false;
      _hideLoadingOverlay();
      if (mounted) {
        setState(() => _isPickerLoading = false);
      }
      _showErrorSnackBar('خطأ في تسجيل الدخول: $e');
    }
  }

  /// ينفذ العملية `_handleGoogleLogin`.
  /// Runs the `_handleGoogleLogin` operation.
  Future<void> _handleGoogleLogin(SocialLoginProvider provider) async {
    final GoogleSignIn googleSignIn;

    if (kIsWeb) {
      if (AppConstants.googleWebClientId.isEmpty) {
        throw Exception('Web Client ID غير مُعد في AppConstants');
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
        throw Exception('iOS Client ID غير مُعد في AppConstants');
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
      throw UnsupportedError(
        'منصة غير مدعومة للمصادقة بـ Google في تطبيق البورتال',
      );
    }

    await googleSignIn.signOut();
    _isSocialAuthInFlight = true;
    _showLoadingOverlay();
    if (mounted) {
      setState(() => _isPickerLoading = true);
    }

    final GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();
    } finally {
      if (mounted) {
        setState(() => _isPickerLoading = false);
      }
    }

    if (account == null) {
      _isSocialAuthInFlight = false;
      _hideLoadingOverlay();
      return;
    }

    final auth = await account.authentication;
    final token = (auth.idToken != null && auth.idToken!.isNotEmpty)
        ? auth.idToken!
        : (auth.accessToken ?? '');

    if (token.isEmpty) {
      _isSocialAuthInFlight = false;
      _hideLoadingOverlay();
      _showErrorSnackBar('تعذر الحصول على رمز المصادقة من Google');
      return;
    }

    if (!mounted) return;
    context.read<AuthBloc>().add(
          SocialLoginEvent(
            provider: provider,
            token: token,
            name: account.displayName?.trim().isEmpty ?? true
                ? null
                : account.displayName!.trim(),
          ),
        );
  }

  /// ينفذ العملية `_handleFacebookLogin`.
  /// Runs the `_handleFacebookLogin` operation.
  Future<void> _handleFacebookLogin(SocialLoginProvider provider) async {
    if (!_isFacebookSupportedPlatform()) {
      _showErrorSnackBar(
        'تسجيل الدخول عبر Facebook غير مدعوم على ${_currentPlatformName()}',
      );
      return;
    }

    if (kIsWeb) {
      await FacebookAuth.i.webAndDesktopInitialize(
        appId: AppConstants.facebookAppId,
        cookie: true,
        xfbml: true,
        version: 'v13.0',
      );
    }

    if (mounted) {
      setState(() => _isPickerLoading = true);
    }

    final LoginResult result;
    try {
      try {
        result = await FacebookAuth.instance.login(
          permissions: const ['public_profile', 'email'],
        );
      } on MissingPluginException {
        _showErrorSnackBar(
          'تعذر تهيئة تسجيل الدخول عبر Facebook على هذه النسخة (${_currentPlatformName()}). أعد بناء التطبيق ثم ثبته من جديد.',
        );
        return;
      } on PlatformException {
        _showErrorSnackBar(
          'تعذر تنفيذ تسجيل الدخول عبر Facebook على هذه المنصة',
        );
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _isPickerLoading = false);
      }
    }

    if (result.status != LoginStatus.success) {
      if (result.status != LoginStatus.cancelled) {
        _showErrorSnackBar('فشل تسجيل الدخول عبر Facebook');
      }
      return;
    }

    final accessToken = result.accessToken?.token;
    if (accessToken == null || accessToken.isEmpty) {
      _showErrorSnackBar('تعذر الحصول على رمز المصادقة من Facebook');
      return;
    }

    String? displayName;
    try {
      final data = await FacebookAuth.instance.getUserData(
        fields: 'name,email',
      );
      displayName = (data['name'] as String?)?.trim();
    } catch (_) {}

    _isSocialAuthInFlight = true;
    _showLoadingOverlay();
    if (!mounted) return;
    context.read<AuthBloc>().add(
          SocialLoginEvent(
            provider: provider,
            token: accessToken,
            name: (displayName == null || displayName.isEmpty)
                ? null
                : displayName,
          ),
        );
  }

  /// ينفذ العملية `_handleAppleLogin`.
  /// Runs the `_handleAppleLogin` operation.
  Future<void> _handleAppleLogin(SocialLoginProvider provider) async {
    if (kIsWeb) {
      _showErrorSnackBar(
          'تسجيل الدخول عبر Apple غير مدعوم على Web في هذا الإصدار');
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      _showErrorSnackBar(
        'تسجيل الدخول عبر Apple غير مدعوم على ${_currentPlatformName()}',
      );
      return;
    }

    _isSocialAuthInFlight = true;
    _showLoadingOverlay();

    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final WebAuthenticationOptions? webAuthOptions;
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (AppConstants.appleRedirectUri.isEmpty) {
        _isSocialAuthInFlight = false;
        _hideLoadingOverlay();
        _showErrorSnackBar(
          'Apple Sign-In على Android يحتاج Redirect URI مضبوط في AppConstants.appleRedirectUri ومسجل في Apple Developer Services ID (${AppConstants.appleServiceId}).',
        );
        return;
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
      _isSocialAuthInFlight = false;
      _hideLoadingOverlay();
      _showErrorSnackBar('لم يتم الحصول على Apple identityToken');
      return;
    }

    final appleFullName = [
      credential.givenName,
      credential.familyName,
    ].where((e) => (e ?? '').trim().isNotEmpty).map((e) => e!.trim()).join(' ');

    if (!mounted) return;
    context.read<AuthBloc>().add(
          SocialLoginEvent(
            provider: provider,
            token: idToken,
            nonce: rawNonce,
            name: appleFullName.isEmpty ? null : appleFullName,
          ),
        );
  }

  /// ينفذ العملية `_isFacebookSupportedPlatform`.
  /// Runs the `_isFacebookSupportedPlatform` operation.
  bool _isFacebookSupportedPlatform() {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  /// ينفذ العملية `_currentPlatformName`.
  /// Runs the `_currentPlatformName` operation.
  String _currentPlatformName() {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  /// ينفذ العملية `_showErrorSnackBar`.
  /// Runs the `_showErrorSnackBar` operation.
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// ينفذ العملية `_generateNonce`.
  /// Runs the `_generateNonce` operation.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}

/// يعرّف الكلاس `_FuturisticSocialButton`.
/// Describes the `_FuturisticSocialButton` class.
class _FuturisticSocialButton extends StatefulWidget {
  /// Holds the `icon` value.
  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// يخزن العضو `fallbackIcon`.
  /// Holds the `fallbackIcon` member.
  final IconData fallbackIcon;

  /// يخزن العضو `label`.
  /// Holds the `label` member.
  final String label;

  /// يخزن العضو `gradient`.
  /// Holds the `gradient` member.
  final LinearGradient gradient;

  /// يخزن العضو `borderColor`.
  /// Holds the `borderColor` member.
  final Color borderColor;

  /// يخزن العضو `onPressed`.
  /// Holds the `onPressed` member.
  final VoidCallback onPressed;

  /// ينشئ مثيلاً من `_FuturisticSocialButton`.
  /// Builds an instance of `_FuturisticSocialButton`.
  const _FuturisticSocialButton({
    required this.icon,
    required this.fallbackIcon,
    required this.label,
    required this.gradient,
    required this.borderColor,
    required this.onPressed,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<_FuturisticSocialButton> createState() =>
      _FuturisticSocialButtonState();
}

/// يعرّف الكلاس `_FuturisticSocialButtonState`.
/// Describes the `_FuturisticSocialButtonState` class.
class _FuturisticSocialButtonState extends State<_FuturisticSocialButton>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// يخزن العضو `_isHovered`.
  /// Holds the `_isHovered` member.
  bool _isHovered = false;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
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

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
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
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: widget.icon.endsWith('.svg')
                                  ? SvgPicture.asset(
                                      widget.icon,
                                      width: 20,
                                      height: 20,
                                      errorBuilder: (_, __, ___) => Icon(
                                        widget.fallbackIcon,
                                        color: AppTheme.textWhite,
                                        size: 20,
                                      ),
                                    )
                                  : Icon(
                                      widget.fallbackIcon,
                                      color: AppTheme.textWhite,
                                      size: 20,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Continue with ${widget.label}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
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
