import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يحدّث الملف الشخصي للمستخدم مع الاقتصار على الحقول القابلة للتعديل من
/// الواجهة.
/// Updates the user profile while limiting the payload to fields that can be
/// changed from the client UI.
class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  /// المستودع الذي ينفذ عملية التحديث.
  /// Repository that performs the profile update.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      phone: params.phone,
    );
  }
}

/// يحمل التغييرات المسموح بها على الملف الشخصي.
/// Holds the allowed edits for the user profile.
class UpdateProfileParams extends Equatable {
  /// الاسم الجديد الذي سيظهر للمستخدم داخل التطبيق.
  /// New display name that should appear for the user in the app.
  final String name;

  /// بريد إلكتروني بديل إذا كان التعديل يشمل البريد.
  /// Replacement email when the user edits the email field.
  final String? email;

  /// رقم هاتف بديل إذا كان التعديل يشمل الهاتف.
  /// Replacement phone number when the phone field changes.
  final String? phone;

  const UpdateProfileParams({
    required this.name,
    this.email,
    this.phone,
  });
  @override
  List<Object?> get props => [name, email, phone];
}
