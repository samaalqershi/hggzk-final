import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يختبر بسرعة ما إذا كانت هناك جلسة قابلة للاستمرار قبل بناء مسار التنقل
/// الأولي للتطبيق.
/// Quickly checks whether a session can be continued before the app chooses
/// its initial navigation path.
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  /// المستودع المسؤول عن فحص صلاحية الجلسة أو البيانات المخزنة.
  /// Repository responsible for checking session validity or cached auth data.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة المطلوب.
  /// Creates the use case with the required auth repository.
  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
