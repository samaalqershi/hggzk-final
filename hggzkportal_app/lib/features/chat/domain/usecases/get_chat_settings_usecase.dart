import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attachment.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetChatSettingsUseCase`.
class GetChatSettingsUseCase implements UseCase<ChatSettings, NoParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetChatSettingsUseCase`.
  GetChatSettingsUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, ChatSettings>> call(NoParams params) async {
    return await repository.getChatSettings();
  }
}
