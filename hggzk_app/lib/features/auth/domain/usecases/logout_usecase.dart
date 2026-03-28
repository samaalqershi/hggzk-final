import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// ينهي الجلسة الحالية ويترك للمستودع مسؤولية تنظيف الرموز والبيانات المخزنة.
/// Ends the current session and lets the repository clear tokens and cached
/// auth data.
class LogoutUseCase implements UseCase<void, NoParams> {
  /// المستودع الذي ينفذ عملية تسجيل الخروج.
  /// Repository that performs the logout operation.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
