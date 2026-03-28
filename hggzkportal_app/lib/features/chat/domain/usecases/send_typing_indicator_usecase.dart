import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../services/websocket_service.dart';

/// يعرّف الكلاس `SendTypingIndicatorUseCase`.
/// Describes the `SendTypingIndicatorUseCase` class.
class SendTypingIndicatorUseCase
    implements UseCase<void, SendTypingIndicatorParams> {
  /// يخزن العضو `webSocketService`.
  /// Holds the `webSocketService` member.
  final ChatWebSocketService webSocketService;

  /// ينشئ مثيلاً من `SendTypingIndicatorUseCase`.
  /// Builds an instance of `SendTypingIndicatorUseCase`.
  SendTypingIndicatorUseCase(this.webSocketService);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(SendTypingIndicatorParams params) async {
    try {
      webSocketService.sendTypingIndicator(
        params.conversationId,
        params.isTyping,
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

/// يعرّف الكلاس `SendTypingIndicatorParams`.
/// Describes the `SendTypingIndicatorParams` class.
class SendTypingIndicatorParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// يخزن العضو `isTyping`.
  /// Holds the `isTyping` member.
  final bool isTyping;

  /// ينشئ مثيلاً من `SendTypingIndicatorParams`.
  /// Builds an instance of `SendTypingIndicatorParams`.
  const SendTypingIndicatorParams({
    required this.conversationId,
    required this.isTyping,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [conversationId, isTyping];
}
