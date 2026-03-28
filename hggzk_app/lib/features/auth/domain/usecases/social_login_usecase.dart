import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// ينفذ المصادقة عبر مزود خارجي ويعيد حمولة الجلسة النهائية بعد نجاح الربط.
/// Performs external-provider authentication and returns the resulting session
/// payload after a successful exchange.
class SocialLoginUseCase implements UseCase<AuthResponse, SocialLoginParams> {
  /// المستودع الذي ينفذ تبادل الرمز مع مزود المصادقة والخادم.
  /// Repository that exchanges provider credentials with the backend.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  SocialLoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(SocialLoginParams params) async {
    return await repository.socialLogin(
      provider: params.provider,
      token: params.token,
      nonce: params.nonce,
      name: params.name,
    );
  }
}

/// يحمل المدخلات اللازمة لإتمام تسجيل الدخول الاجتماعي.
/// Holds the inputs needed to complete a social sign-in flow.
class SocialLoginParams extends Equatable {
  /// اسم مزود المصادقة الخارجي مثل Google أو Apple.
  /// External provider name such as Google or Apple.
  final String provider;

  /// الرمز الذي أعاده مزود المصادقة بعد موافقة المستخدم.
  /// Token returned by the provider after the user approves the login.
  final String token;

  /// قيمة `nonce` اختيارية لبعض مزودي المصادقة.
  /// Optional nonce value required by some providers.
  final String? nonce;

  /// اسم المستخدم المقترح الذي قد يأتي من مزود الهوية.
  /// Suggested display name that may be returned by the identity provider.
  final String? name;

  const SocialLoginParams({
    required this.provider,
    required this.token,
    this.nonce,
    this.name,
  });
  @override
  List<Object?> get props => [provider, token, nonce, name];
}
