import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/resend_email_verification_usecase.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendEmailVerificationUseCase resendEmailVerificationUseCase;

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
      (ok) => emit(ok
          ? const EmailVerificationSuccess()
          : const EmailVerificationError('رمز التحقق غير صحيح')),
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
      return 'انتهت صلاحية رمز التحقق. يرجى الضغط على "إعادة إرسال الرمز" للحصول على رمز جديد.';
    }

    if (rawMessage.isNotEmpty &&
        rawMessage != 'Server failure' &&
        rawMessage != 'An unexpected error occurred' &&
        rawMessage != 'Unknown failure') {
      return rawMessage;
    }

    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'يرجى التحقق من اتصالك بالإنترنت';
      case ServerFailure:
        if (rawMessage.isNotEmpty && rawMessage != 'Server failure') {
          return rawMessage;
        }
        return 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً';
      case ValidationFailure:
        final validationMessage = (failure as ValidationFailure).message.trim();
        if (_isExpiredVerificationCodeMessage(validationMessage)) {
          return 'انتهت صلاحية رمز التحقق. يرجى الضغط على "إعادة إرسال الرمز" للحصول على رمز جديد.';
        }
        return validationMessage;
      default:
        return rawMessage.isNotEmpty ? rawMessage : 'حدث خطأ غير متوقع';
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
