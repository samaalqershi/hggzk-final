import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// يحدّث تفضيل المصادقة البيومترية داخل إعدادات المستخدم.
/// Updates the biometric-authentication preference in user settings.
class UpdateBiometricUseCase implements UseCase<bool, UpdateBiometricParams> {
  /// المستودع الذي يحفظ حالة تفعيل المصادقة البيومترية.
  /// Repository that persists the biometric-authentication toggle.
  final SettingsRepository repository;

  /// ينشئ حالة الاستخدام الخاصة بتحديث خيار البصمة أو المصادقة الحيوية.
  /// Creates the use case that updates the biometric-authentication option.
  UpdateBiometricUseCase(this.repository);

  /// يمرر قيمة التفعيل الجديدة للمصادقة البيومترية إلى المستودع.
  /// Forwards the new biometric-authentication value to the repository.
  @override
  Future<Either<Failure, bool>> call(UpdateBiometricParams params) async {
    return await repository.updateBiometric(params.enabled);
  }
}

/// يحمل القيمة الجديدة المطلوبة لتفضيل المصادقة البيومترية.
/// Carries the new value requested for biometric authentication.
class UpdateBiometricParams extends Equatable {
  /// يحدد ما إذا كان خيار المصادقة البيومترية يجب أن يكون مفعّلًا.
  /// Indicates whether biometric authentication should be enabled.
  final bool enabled;

  /// ينشئ معاملات تحديث المصادقة البيومترية.
  /// Creates the parameters for a biometric-preference update.
  const UpdateBiometricParams({required this.enabled});

  /// يعيد الحقول المستخدمة عند مقارنة معاملات هذا الطلب.
  /// Returns the fields used when comparing these request parameters.
  @override
  List<Object> get props => [enabled];
}
