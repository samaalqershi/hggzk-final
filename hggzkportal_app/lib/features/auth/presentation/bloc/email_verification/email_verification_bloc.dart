import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

/// Arabic: يدير حالات التحقق من البريد الإلكتروني وإعادة إرسال الرمز.
/// English: Coordinates email verification and resend-code state transitions.
class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  /// Arabic: مستودع المصادقة المستخدم لتنفيذ طلبات التحقق.
  /// English: Authentication repository used to execute verification requests.
  final AuthRepository authRepository;

  /// Arabic: ينشئ الـ bloc الخاص بسير عمل تأكيد البريد الإلكتروني.
  /// English: Creates the bloc that powers the email verification flow.
  EmailVerificationBloc({required this.authRepository})
      : super(const EmailVerificationInitial()) {
    on<VerifyEmailSubmitted>(_onVerify);
    on<ResendCodePressed>(_onResend);
  }

  /// Arabic: يعالج إرسال رمز التحقق ويدفع الحالة المناسبة للواجهة.
  /// English: Handles verification submissions and emits the matching UI state.
  Future<void> _onVerify(
      VerifyEmailSubmitted event, Emitter<EmailVerificationState> emit) async {
    emit(const EmailVerificationLoading());
    try {
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

  /// Arabic: يعيد إرسال رمز التحقق ويعيد مؤقت الانتظار عند النجاح.
  /// English: Resends the verification code and emits the retry cooldown.
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

  /// Arabic: يحول أنواع الفشل المختلفة إلى رسالة مناسبة للمستخدم.
  /// English: Maps domain failures into user-facing error messages.
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

    switch (failure) {
      case NetworkFailure _:
        return 'يرجى التحقق من اتصالك بالإنترنت';
      case ServerFailure _:
        if (rawMessage.isNotEmpty && rawMessage != 'Server failure') {
          return rawMessage;
        }
        return 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً';
      case ValidationFailure validationFailure:
        final validationMessage = validationFailure.message.trim();
        if (_isExpiredVerificationCodeMessage(validationMessage)) {
          return 'انتهت صلاحية رمز التحقق. يرجى الضغط على "إعادة إرسال الرمز" للحصول على رمز جديد.';
        }
        return validationMessage;
      default:
        return rawMessage.isNotEmpty ? rawMessage : 'حدث خطأ غير متوقع';
    }
  }

  /// Arabic: يفحص ما إذا كانت الرسالة تشير إلى انتهاء صلاحية الرمز.
  /// English: Detects whether the backend message indicates an expired code.
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
