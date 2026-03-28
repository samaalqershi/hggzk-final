import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzkportal/core/constants/route_constants.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_event.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/email_verification_bloc.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/email_verification_event.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/email_verification_state.dart';
import 'package:hggzkportal/injection_container.dart';

/// شاشة إدخال رمز تفعيل البريد الإلكتروني وإعادة إرساله.
/// UI page for submitting and resending the email verification code.
class VerifyEmailPage extends StatefulWidget {
  /// Initializes a new `VerifyEmailPage` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `VerifyEmailPage`.
  const VerifyEmailPage({super.key});

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

/// يعرّف الكلاس `_VerifyEmailPageState`.
/// Describes the `_VerifyEmailPageState` class.
class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _codeController = TextEditingController();

  /// يخزن العضو `_timer`.
  /// Holds the `_timer` member.
  Timer? _timer;

  /// يخزن العضو `_seconds`.
  /// Holds the `_seconds` member.
  int _seconds = 0;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _startTimer(0);
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  /// يبدأ أو يعيد ضبط مؤقت إعادة إرسال الرمز.
  /// Starts or resets the resend-code countdown timer.
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

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmailVerificationBloc>(
      create: (_) {
        return sl<EmailVerificationBloc>();
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkBackground,
                      AppTheme.darkBackground2.withValues(alpha: 0.9),
                      AppTheme.darkBackground3.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<AuthBloc, AuthState>(
                        listener: (context, aState) {
                          if (aState is AuthUnauthenticated) {
                            context.go(RouteConstants.login);
                          }
                        },
                      ),
                    ],
                    child: BlocConsumer<EmailVerificationBloc,
                        EmailVerificationState>(
                      listener: (context, state) {
                        if (state is EmailVerificationSuccess) {
                          HapticFeedback.mediumImpact();
                          context.read<AuthBloc>().add(const LogoutEvent());
                          if (!mounted) {
                            return;
                          }
                          context.go(RouteConstants.login);
                        } else if (state is EmailVerificationError) {
                          _showError(state.message);
                        } else if (state is EmailVerificationCodeResent) {
                          _startTimer(state.retryAfterSeconds ?? 60);
                        }
                      },
                      builder: (context, state) {
                        final authState = context.watch<AuthBloc>().state;
                        final email = authState is AuthAuthenticated
                            ? authState.user.email
                            : '';
                        final isLoading = state is EmailVerificationLoading;
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 420),
                          padding: const EdgeInsets.all(24),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.primaryGradient,
                                  ),
                                  child: const Icon(
                                    Icons.mark_email_read_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ShaderMask(
                                  shaderCallback: (bounds) => AppTheme
                                      .primaryGradient
                                      .createShader(bounds),
                                  child: Text(
                                    'تأكيد البريد الإلكتروني',
                                    style: AppTextStyles.heading2.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                email.isNotEmpty
                                    ? 'أدخل رمز التحقق المرسل إلى:\n$email'
                                    : 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
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
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppTheme.textWhite,
                                  letterSpacing: 4,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'رمز التحقق',
                                  hintText: '######',
                                  labelStyle: AppTextStyles.bodySmall.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                                  filled: true,
                                  fillColor:
                                      Colors.black.withValues(alpha: 0.25),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppTheme.darkBorder
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryBlue
                                          .withValues(alpha: 0.9),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final user = (context
                                                  .read<AuthBloc>()
                                                  .state as AuthAuthenticated)
                                              .user;
                                          context
                                              .read<EmailVerificationBloc>()
                                              .add(
                                                VerifyEmailSubmitted(
                                                  userId: user.userId,
                                                  email: user.email,
                                                  code: _codeController.text
                                                      .trim(),
                                                ),
                                              );
                                        },
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
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'تأكيد',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
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
                                    : () {
                                        final user = (context
                                                .read<AuthBloc>()
                                                .state as AuthAuthenticated)
                                            .user;
                                        context
                                            .read<EmailVerificationBloc>()
                                            .add(
                                              ResendCodePressed(
                                                userId: user.userId,
                                                email: user.email,
                                              ),
                                            );
                                      },
                                child: Text(
                                  _seconds > 0
                                      ? 'أعد الإرسال بعد $_seconds ث'
                                      : 'إعادة إرسال الرمز',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: _seconds > 0
                                        ? AppTheme.textMuted
                                        : AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يعرض رسالة الخطأ النهائية للمستخدم بطريقة موحدة.
  /// Shows the resolved error message to the user consistently.
  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
