import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetAdminUsersUseCase`.
class GetAdminUsersUseCase implements UseCase<List<ChatUser>, NoParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetAdminUsersUseCase`.
  GetAdminUsersUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<ChatUser>>> call(NoParams params) async {
    return await repository.getAdminUsers();
  }
}
