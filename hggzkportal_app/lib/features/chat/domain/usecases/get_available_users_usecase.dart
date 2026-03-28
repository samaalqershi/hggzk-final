import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `GetAvailableUsersUseCase`.
/// Describes the `GetAvailableUsersUseCase` class.
class GetAvailableUsersUseCase
    implements UseCase<List<ChatUser>, GetAvailableUsersParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `GetAvailableUsersUseCase`.
  /// Builds an instance of `GetAvailableUsersUseCase`.
  GetAvailableUsersUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, List<ChatUser>>> call(
      GetAvailableUsersParams params) async {
    return await repository.getAvailableUsers(
      userType: params.userType,
      propertyId: params.propertyId,
    );
  }
}

/// يعرّف الكلاس `GetAvailableUsersParams`.
/// Describes the `GetAvailableUsersParams` class.
class GetAvailableUsersParams extends Equatable {
  /// Holds the `userType` value.
  /// العربية: يخزن القيمة `userType`.
  final String? userType;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// ينشئ مثيلاً من `GetAvailableUsersParams`.
  /// Builds an instance of `GetAvailableUsersParams`.
  const GetAvailableUsersParams({
    this.userType,
    this.propertyId,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [userType, propertyId];
}
