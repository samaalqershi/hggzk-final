import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// يجلب أحدث ملف للمستخدم الحالي بعد تسجيل الدخول أو عند استئناف الجلسة.
/// Fetches the freshest profile for the current user after sign-in or session
/// restoration.
class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  /// المستودع الذي يوفر بيانات المستخدم الحالي.
  /// Repository that provides the current user profile.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة المناسب.
  /// Creates the use case with the configured auth repository.
  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
