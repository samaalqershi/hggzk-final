import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `DeleteMessageUseCase`.
/// Describes the `DeleteMessageUseCase` class.
class DeleteMessageUseCase implements UseCase<void, DeleteMessageParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `DeleteMessageUseCase`.
  /// Builds an instance of `DeleteMessageUseCase`.
  DeleteMessageUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) async {
    return await repository.deleteMessage(params.messageId);
  }
}

/// يعرّف الكلاس `DeleteMessageParams`.
/// Describes the `DeleteMessageParams` class.
class DeleteMessageParams extends Equatable {
  /// Holds the `messageId` value.
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// ينشئ مثيلاً من `DeleteMessageParams`.
  /// Builds an instance of `DeleteMessageParams`.
  const DeleteMessageParams({required this.messageId});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [messageId];
}
