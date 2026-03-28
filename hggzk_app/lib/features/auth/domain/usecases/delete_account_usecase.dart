import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// ينفذ مسار حذف الحساب النهائي مع دعم وسائل التأكيد المختلفة.
/// Executes the permanent account-deletion flow with support for multiple
/// confirmation strategies.
class DeleteAccountUseCase implements UseCase<void, DeleteAccountParams> {
  /// المستودع الذي يتواصل مع طبقة البيانات لحذف الحساب.
  /// Repository that coordinates account deletion with the data layer.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة المناسب.
  /// Creates the use case with the appropriate auth repository.
  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) async {
    return await repository.deleteAccount(
      password: params.password,
      socialProvider: params.socialProvider,
      socialToken: params.socialToken,
      socialNonce: params.socialNonce,
      reason: params.reason,
    );
  }
}

/// يحمل وسائل التأكيد والسياق الإضافي المطلوبين قبل حذف الحساب.
/// Holds the confirmation inputs and optional context required before deleting
/// the account.
class DeleteAccountParams extends Equatable {
  /// كلمة المرور عند استخدام الحذف المعتمد على الاعتماديات التقليدية.
  /// Password when deletion is confirmed through the classic credential flow.
  final String? password;

  /// اسم مزود المصادقة الاجتماعية عند استخدامه للتأكيد.
  /// Social-auth provider name when deletion is confirmed socially.
  final String? socialProvider;

  /// الرمز الصادر من مزود المصادقة الاجتماعية للتأكيد.
  /// Provider-issued token used to confirm deletion through social auth.
  final String? socialToken;

  /// قيمة `nonce` الإضافية المطلوبة لبعض المزودين مثل Apple.
  /// Optional nonce required by some providers such as Apple.
  final String? socialNonce;

  /// سبب اختياري يرسله العميل لأغراض التحليل أو الدعم.
  /// Optional reason sent by the client for support or analytics purposes.
  final String? reason;

  const DeleteAccountParams({
    this.password,
    this.socialProvider,
    this.socialToken,
    this.socialNonce,
    this.reason,
  });
  @override
  List<Object?> get props => [
        password,
        socialProvider,
        socialToken,
        socialNonce,
        reason,
      ];
}
