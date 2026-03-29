import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/localization/app_localizations.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/resend_email_verification_usecase.dart';
import '../../../domain/usecases/verify_email_usecase.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

/// يدير إرسال رمز التحقق والتحقق منه ويترجم الإخفاقات إلى رسائل مناسبة
/// لواجهة المستخدم.
/// Manages code submission and resend actions while translating failures into
/// UI-friendly verification messages.
class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  /// حالة الاستخدام الخاصة بإرسال رمز التحقق إلى الخادم للمطابقة.
  /// Use case that submits the verification code for backend validation.
  final VerifyEmailUseCase verifyEmailUseCase;

  /// حالة الاستخدام الخاصة بطلب رمز تحقق جديد.
  /// Use case that requests a fresh verification code.
  final ResendEmailVerificationUseCase resendEmailVerificationUseCase;

  /// ينشئ الـ bloc ويربط أحداث التحقق بمعالجاتها.
  /// Creates the bloc and wires verification events to their handlers.
  EmailVerificationBloc({
    required this.verifyEmailUseCase,
    required this.resendEmailVerificationUseCase,
  }) : super(const EmailVerificationInitial()) {
    on<VerifyEmailSubmitted>(_onVerify);
    on<ResendCodePressed>(_onResend);
  }
  Future<void> _onVerify(
    VerifyEmailSubmitted event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(const EmailVerificationLoading());
    final result = await verifyEmailUseCase(
      VerifyEmailParams(userId: event.userId, code: event.code),
    );
    result.fold(
      (failure) => emit(EmailVerificationError(_mapFailureToMessage(failure))),
      (ok) => emit(
        ok
            ? const EmailVerificationSuccess()
            : EmailVerificationError(
                AppLocalizations.translateSync('auth.verify.invalidCode'),
              ),
      ),
    );
  }

  Future<void> _onResend(
    ResendCodePressed event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(const EmailVerificationLoading());
    final result = await resendEmailVerificationUseCase(
      ResendEmailVerificationParams(userId: event.userId, email: event.email),
    );
    result.fold(
      (failure) => emit(EmailVerificationError(_mapFailureToMessage(failure))),
      (retryAfter) => emit(
        EmailVerificationCodeResent(retryAfterSeconds: retryAfter),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    final rawMessage = failure.message.trim();
    if (_isExpiredVerificationCodeMessage(rawMessage)) {
      return AppLocalizations.translateSync('auth.verify.expired');
    }

    if (rawMessage.isNotEmpty &&
        rawMessage != 'Server failure' &&
        rawMessage != 'An unexpected error occurred' &&
        rawMessage != 'Unknown failure') {
      return rawMessage;
    }

    switch (failure.runtimeType) {
      case NetworkFailure:
        return AppLocalizations.translateSync('auth.verify.network');
      case ServerFailure:
        if (rawMessage.isNotEmpty && rawMessage != 'Server failure') {
          return rawMessage;
        }
        return AppLocalizations.translateSync('auth.verify.server');
      case ValidationFailure:
        final validationMessage = (failure as ValidationFailure).message.trim();
        if (_isExpiredVerificationCodeMessage(validationMessage)) {
          return AppLocalizations.translateSync('auth.verify.expired');
        }
        return validationMessage;
      default:
        return rawMessage.isNotEmpty
            ? rawMessage
            : AppLocalizations.translateSync('auth.verify.unexpected');
    }
  }

  bool _isExpiredVerificationCodeMessage(String message) {
    if (message.isEmpty) return false;
    final normalized = message.toLowerCase();
    return normalized.contains('verification_token_expired') ||
        normalized.contains('token_expired') ||
        normalized.contains('expired') ||
        message.contains('منتهي الصلاحية') ||
        message.contains('انتهت صلاحية');
  }
}
