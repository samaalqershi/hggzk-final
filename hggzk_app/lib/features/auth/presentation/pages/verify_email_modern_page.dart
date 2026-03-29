import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/constants/route_constants.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/theme/app_text_styles.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_event.dart';
import 'package:hggzk/features/auth/presentation/bloc/verification/email_verification_bloc.dart';
import 'package:hggzk/features/auth/presentation/bloc/verification/email_verification_event.dart';
import 'package:hggzk/features/auth/presentation/bloc/verification/email_verification_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// تعرض خطوة تأكيد البريد الإلكتروني مع إدخال الرمز وإعادة الإرسال والعودة
/// إلى مسار المصادقة عند النجاح.
/// Presents the email-confirmation step with code entry, resend support, and
/// navigation back into the auth flow after success.
class VerifyEmailModernPage extends StatefulWidget {
  /// ينشئ شاشة التحقق من البريد الإلكتروني.
  /// Creates the email-verification page.
  const VerifyEmailModernPage({super.key});
  @override
  State<VerifyEmailModernPage> createState() => _VerifyEmailModernPageState();
}

class _VerifyEmailModernPageState extends State<VerifyEmailModernPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _seconds = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _startTimer(0);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    Future.microtask(() {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() => _seconds = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmailVerificationBloc>(
      create: (_) => sl<EmailVerificationBloc>(),
      child: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
        listener: _handleVerificationState,
        builder: (context, state) {
          final authState = context.watch<AuthBloc>().state;
          final email =
              authState is AuthAuthenticated ? authState.user.email : '';

          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            body: SafeArea(
              child: Stack(
                children: [
                  _buildBackground(),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildCard(context, state, email),
                        ),
                      ),
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

  Widget _buildBackground() {
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
    );
  }

  Widget _buildCard(
    BuildContext context,
    EmailVerificationState state,
    String email,
  ) {
    final isLoading = state is EmailVerificationLoading;
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.8),
            AppTheme.darkCard.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                context.tr(
                  'auth.verify.title',
                ),
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email.isNotEmpty
                ? context.tr(
                    'auth.verify.sentToEmail',
                    params: {'email': email},
                  )
                : context.tr(
                    'auth.verify.prompt',
                  ),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(
              color: AppTheme.textWhite,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              labelText: context.tr(
                'auth.verify.codeLabel',
              ),
              hintText: '######',
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.darkBorder.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.primaryBlue.withOpacity(0.8),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _onConfirmPressed(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          context.tr('common.confirm'),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _seconds > 0 || isLoading
                ? null
                : () => _onResendPressed(context),
            child: Text(
              _seconds > 0
                  ? context.tr(
                      'auth.verify.resendCountdown',
                      params: {'seconds': _seconds},
                    )
                  : context.tr(
                      'auth.verify.resend',
                    ),
              style: AppTextStyles.bodySmall.copyWith(
                color: _seconds > 0 ? AppTheme.textMuted : AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleVerificationState(
    BuildContext context,
    EmailVerificationState state,
  ) {
    if (state is EmailVerificationSuccess) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'auth.verify.success',
            ),
          ),
        ),
      );
      context.read<AuthBloc>().add(const LogoutEvent());
      Future.microtask(() => context.go(RouteConstants.login));
    } else if (state is EmailVerificationError) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    } else if (state is EmailVerificationCodeResent) {
      final seconds = state.retryAfterSeconds ?? 60;
      _startTimer(seconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'auth.verify.resendSuccess',
            ),
          ),
        ),
      );
    }
  }

  void _onConfirmPressed(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'auth.verify.invalidCode',
            ),
          ),
        ),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'auth.verify.sessionError',
            ),
          ),
        ),
      );
      return;
    }
    final user = authState.user;
    context.read<EmailVerificationBloc>().add(
          VerifyEmailSubmitted(
            userId: user.userId,
            email: user.email,
            code: code,
          ),
        );
  }

  void _onResendPressed(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;
    context.read<EmailVerificationBloc>().add(
          ResendCodePressed(
            userId: user.userId,
            email: user.email,
          ),
        );
  }
}
