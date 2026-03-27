import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AuthRepository authRepository;
  EmailVerificationBloc({required this.authRepository})
      : super(const EmailVerificationInitial()) {
    on<VerifyEmailSubmitted>(_onVerify);
    on<ResendCodePressed>(_onResend);
  }

  Future<void> _onVerify(
      VerifyEmailSubmitted event, Emitter<EmailVerificationState> emit) async {
    emit(const EmailVerificationLoading());
    try {
      // Call repository for verification
      final result = await authRepository.verifyEmail(
          userId: event.userId, code: event.code);
      result.fold(
        (failure) =>
            emit(EmailVerificationError(_mapFailureToMessage(failure))),
        (ok) => ok
            ? emit(const EmailVerificationSuccess())
            : emit(const EmailVerificationError('رمز التحقق غير صحيح')),
      );
    } catch (e) {
      emit(EmailVerificationError(e.toString()));
    }
  }

  Future<void> _onResend(
      ResendCodePressed event, Emitter<EmailVerificationState> emit) async {
    emit(const EmailVerificationLoading());
    try {
      final result = await authRepository.resendEmailVerification(
          userId: event.userId, email: event.email);
      result.fold(
        (failure) =>
            emit(EmailVerificationError(_mapFailureToMessage(failure))),
        (retryAfter) =>
            emit(EmailVerificationCodeResent(retryAfterSeconds: retryAfter)),
      );
    } catch (e) {
      emit(EmailVerificationError(e.toString()));
    }
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
