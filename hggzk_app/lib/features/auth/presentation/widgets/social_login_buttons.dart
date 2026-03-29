import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// يعرض أزرار المصادقة الاجتماعية ويدير تدفق اختيار المزود وإظهار حالة
/// التحميل المشتركة.
/// Renders the social-auth buttons and manages provider selection plus shared
/// loading feedback.
class SocialLoginButtons extends StatefulWidget {
  /// ينشئ مجموعة أزرار تسجيل الدخول الاجتماعي.
  /// Creates the social-login buttons group.
  const SocialLoginButtons({super.key});
  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _isPickerLoading = false;
  bool _isLoadingDialogShown = false;
  bool _isSocialAuthInFlight = false;
  OverlayEntry? _loadingOverlayEntry;
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!_isSocialAuthInFlight) return;
        if (state is AuthLoading) {
          _showLoadingDialog();
          return;
        }
        _hideLoadingDialog();
        _isSocialAuthInFlight = false;
      },
      child: Column(
        children: [
          _FuturisticSocialButton(
            icon: 'assets/icons/google.svg',
            fallbackIcon: Icons.g_mobiledata,
            label: context.tr('auth.social.google'),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderColor: Colors.white.withOpacity(0.2),
            onPressed: _isPickerLoading
                ? () {}
                : () => _handleSocialLogin(context, SocialLoginProvider.google),
          ),
          const SizedBox(height: 16),
          _FuturisticSocialButton(
            icon: 'assets/icons/facebook.svg',
            fallbackIcon: Icons.facebook,
            label: context.tr('auth.social.facebook'),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1877F2).withOpacity(0.2),
                const Color(0xFF1877F2).withOpacity(0.1),
              ],
            ),
            borderColor: const Color(0xFF1877F2).withOpacity(0.3),
            onPressed: _isPickerLoading
                ? () {}
                : () =>
                    _handleSocialLogin(context, SocialLoginProvider.facebook),
          ),
          const SizedBox(height: 16),
          _FuturisticSocialButton(
            icon: 'assets/icons/apple.svg',
            fallbackIcon: Icons.apple,
            label: context.tr('auth.social.apple'),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderColor: Colors.white.withOpacity(0.2),
            onPressed: _isPickerLoading
                ? () {}
                : () => _handleSocialLogin(context, SocialLoginProvider.apple),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideLoadingDialog();
    super.dispose();
  }

  void _showLoadingDialog() {
    if (!mounted || _isLoadingDialogShown) return;
    _isLoadingDialogShown = true;
    final overlay = Overlay.of(context, rootOverlay: true);
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

  void _hideLoadingDialog() {
    if (!_isLoadingDialogShown) return;
    _isLoadingDialogShown = false;
    _loadingOverlayEntry?.remove();
    _loadingOverlayEntry = null;
  }

  Future<void> _handleSocialLogin(
    BuildContext context,
    SocialLoginProvider provider,
  ) async {
    if (_isPickerLoading) return;
    try {
      switch (provider) {
        case SocialLoginProvider.google:
          debugPrint('🔐 Google Sign-In: بدء عملية تسجيل الدخول...');
          debugPrint('📱 Platform: ${_getCurrentPlatformName(context)}');

          // الحصول على Client ID المناسب للمنصة (لأغراض التحقق والـ logging)
          final String? platformClientId = _getGoogleClientIdForPlatform();
          if (platformClientId != null && platformClientId.isNotEmpty) {
            debugPrint(
              '🔑 Platform Client ID: ${_truncateId(platformClientId)}',
            );
          }

          // إعداد GoogleSignIn حسب المنصة
          final GoogleSignIn googleSignIn;

          if (kIsWeb) {
            // 🌐 Web: استخدام Web Client ID
            if (AppConstants.googleWebClientId.isEmpty) {
              throw Exception(context.tr('auth.social.googleWebClientMissing'));
            }
            debugPrint('🌐 Web: استخدام Web Client ID');
            debugPrint(
              '🔑 Web Client ID: ${_truncateId(AppConstants.googleWebClientId)}',
            );
            googleSignIn = GoogleSignIn(
              scopes: ['email', 'profile'],
              clientId: AppConstants.googleWebClientId,
            );
          } else if (defaultTargetPlatform == TargetPlatform.android) {
            // 📱 Android: الاعتماد على google-services.json مع serverClientId للخادم
            debugPrint('📄 Android: استخدام google-services.json');

            // serverClientId اختياري - إذا كان موجوداً يُستخدم للحصول على idToken
            final serverClientId = AppConstants.googleWebClientId.isNotEmpty
                ? AppConstants.googleWebClientId
                : null;

            if (serverClientId != null) {
              debugPrint('🔑 Server Client ID: ${_truncateId(serverClientId)}');
              googleSignIn = GoogleSignIn(
                scopes: ['email', 'profile'],
                serverClientId: serverClientId,
              );
            } else {
              debugPrint(
                '⚠️ Server Client ID غير موجود - سيتم استخدام accessToken بدلاً من idToken',
              );
              googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
            }
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            // 🍎 iOS: استخدام iOS Client ID مع Server Client ID
            if (AppConstants.googleIosClientId.isEmpty) {
              throw Exception(context.tr('auth.social.googleIosClientMissing'));
            }
            debugPrint('🍎 iOS: استخدام iOS Client ID');
            debugPrint(
              '🔑 iOS Client ID: ${_truncateId(AppConstants.googleIosClientId)}',
            );

            final serverClientId = AppConstants.googleWebClientId.isNotEmpty
                ? AppConstants.googleWebClientId
                : null;
            if (serverClientId != null) {
              debugPrint('🔑 Server Client ID: ${_truncateId(serverClientId)}');
            }

            googleSignIn = GoogleSignIn(
              scopes: ['email', 'profile'],
              clientId: AppConstants.googleIosClientId,
              serverClientId: serverClientId,
            );
          } else {
            debugPrint(
              '❌ منصة غير مدعومة: ${_getCurrentPlatformName(context)}',
            );
            throw UnsupportedError(
              context.tr('auth.social.googleUnsupportedPlatform'),
            );
          }

          // تسجيل الخروج أولاً لضمان اختيار الحساب الصحيح
          await googleSignIn.signOut();

          // بدء عملية تسجيل الدخول
          _isSocialAuthInFlight = true;
          _showLoadingDialog();
          setState(() => _isPickerLoading = true);
          final GoogleSignInAccount? account;
          try {
            account = await googleSignIn.signIn();
          } finally {
            if (mounted) setState(() => _isPickerLoading = false);
          }
          if (account == null) {
            debugPrint('❌ Google Sign-In: المستخدم ألغى العملية');
            _isSocialAuthInFlight = false;
            _hideLoadingDialog();
            return;
          }

          debugPrint(
            '✅ Google Sign-In: تم الحصول على الحساب: ${account.email}',
          );

          final GoogleSignInAuthentication auth = await account.authentication;

          debugPrint('🎫 التحقق من الـ Tokens...');
          debugPrint(
            '   - ID Token: ${auth.idToken != null && auth.idToken!.isNotEmpty ? "✅ موجود" : "❌ مفقود"}',
          );
          debugPrint(
            '   - Access Token: ${auth.accessToken != null && auth.accessToken!.isNotEmpty ? "✅ موجود" : "❌ مفقود"}',
          );

          // استخدام idToken إن وجد، وإلا استخدام accessToken
          final String? token =
              (auth.idToken != null && auth.idToken!.isNotEmpty)
                  ? auth.idToken
                  : auth.accessToken;

          if (token == null || token.isEmpty) {
            debugPrint('❌ Google Sign-In: لا يوجد token صالح!');
            _isSocialAuthInFlight = false;
            _hideLoadingDialog();
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    'auth.social.googleTokenMissing',
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final bool isIdToken =
              auth.idToken != null && auth.idToken!.isNotEmpty;
          debugPrint(
            '📤 Google Sign-In: إرسال ${isIdToken ? "idToken" : "accessToken"} إلى الخادم...',
          );

          // ignore: use_build_context_synchronously
          _isSocialAuthInFlight = true;
          context.read<AuthBloc>().add(
                SocialLoginEvent(provider: provider, token: token),
              );
          _showLoadingDialog();
          break;
        case SocialLoginProvider.facebook:
          debugPrint('🔐 Facebook Login: بدء عملية تسجيل الدخول...');

          if (!_isFacebookSupportedPlatform()) {
            _showErrorSnackBar(
              context.tr(
                'auth.social.facebookUnsupportedPlatform',
                params: {'platform': _getCurrentPlatformName(context)},
              ),
            );
            return;
          }

          if (kIsWeb) {
            await FacebookAuth.i.webAndDesktopInitialize(
              appId: AppConstants.facebookAppId,
              cookie: true,
              xfbml: true,
              version: "v13.0",
            );
          }

          setState(() => _isPickerLoading = true);
          final LoginResult res;
          try {
            try {
              res = await FacebookAuth.instance.login(
                permissions: ['public_profile', 'email'],
              );
            } on MissingPluginException {
              _showErrorSnackBar(
                context.tr(
                  'auth.social.facebookInitFailed',
                  params: {'platform': _getCurrentPlatformName(context)},
                ),
              );
              return;
            } on PlatformException {
              _showErrorSnackBar(
                context.tr(
                  'auth.social.facebookUnsupported',
                ),
              );
              return;
            }
          } finally {
            if (mounted) setState(() => _isPickerLoading = false);
          }

          if (res.status != LoginStatus.success) {
            debugPrint(
              '❌ Facebook Login: فشل - ${res.status} - ${res.message}',
            );
            return;
          }

          final accessToken = res.accessToken?.token;
          if (accessToken == null || accessToken.isEmpty) {
            debugPrint('❌ Facebook Login: accessToken فارغ!');
            return;
          }

          debugPrint('📤 Facebook Login: إرسال accessToken إلى الخادم...');

          // ignore: use_build_context_synchronously
          _isSocialAuthInFlight = true;
          context.read<AuthBloc>().add(
                SocialLoginEvent(provider: provider, token: accessToken),
              );
          _showLoadingDialog();
          break;
        case SocialLoginProvider.apple:
          if (kIsWeb) {
            _showErrorSnackBar(
              context.tr(
                'auth.social.appleUnsupportedWeb',
              ),
            );
            return;
          }

          if (defaultTargetPlatform != TargetPlatform.iOS &&
              defaultTargetPlatform != TargetPlatform.android) {
            _showErrorSnackBar(
              context.tr(
                'auth.social.appleUnsupportedPlatform',
                params: {'platform': _getCurrentPlatformName(context)},
              ),
            );
            return;
          }

          _isSocialAuthInFlight = true;
          _showLoadingDialog();

          final rawNonce = _generateNonce();
          final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

          final WebAuthenticationOptions? webAuthOptions;
          if (defaultTargetPlatform == TargetPlatform.android) {
            if (AppConstants.appleRedirectUri.isEmpty) {
              _isSocialAuthInFlight = false;
              _hideLoadingDialog();
              _showErrorSnackBar(
                context.tr(
                  'auth.social.appleRedirectMissing',
                ),
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
            _hideLoadingDialog();
            _showErrorSnackBar(
              context.tr(
                'auth.social.appleIdentityMissing',
              ),
            );
            return;
          }

          final appleFullName = [
            credential.givenName,
            credential.familyName,
          ]
              .where((e) => (e ?? '').trim().isNotEmpty)
              .map((e) => e!.trim())
              .join(' ');

          // ignore: use_build_context_synchronously
          context.read<AuthBloc>().add(
                SocialLoginEvent(
                  provider: provider,
                  token: idToken,
                  nonce: rawNonce,
                  name: appleFullName.isEmpty ? null : appleFullName,
                ),
              );
          _showLoadingDialog();
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Social Login Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      _isSocialAuthInFlight = false;
      _hideLoadingDialog();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('auth.social.loginError'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _getGoogleClientIdForPlatform() {
    if (kIsWeb) {
      return AppConstants.googleWebClientId;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return AppConstants.googleIosClientId;
      case TargetPlatform.android:
        // Android يستخدم google-services.json، لكن نعيد Client ID المخصص لأغراض التتبع والـ logging
        return AppConstants.googleAndroidClientId;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  String _getCurrentPlatformName(BuildContext context) {
    if (kIsWeb) return context.tr('auth.platform.web');

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return context.tr('auth.platform.android');
      case TargetPlatform.iOS:
        return context.tr('auth.platform.ios');
      case TargetPlatform.macOS:
        return context.tr('auth.platform.macos');
      case TargetPlatform.windows:
        return context.tr('auth.platform.windows');
      case TargetPlatform.linux:
        return context.tr('auth.platform.linux');
      case TargetPlatform.fuchsia:
        return context.tr('auth.platform.fuchsia');
    }
  }

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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _truncateId(String id) {
    if (id.isEmpty) return '(فارغ)';
    if (id.length <= 30) return id;
    return '${id.substring(0, 30)}...';
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
                    : widget.borderColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.borderColor.withOpacity(0.3),
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
                          context.tr(
                            'auth.social.loginWith',
                            params: {'provider': widget.label},
                          ),
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
    );
  }
}
