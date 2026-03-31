import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetAvailableUsersUseCase`.
class GetAvailableUsersUseCase
    implements UseCase<List<ChatUser>, GetAvailableUsersParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetAvailableUsersUseCase`.
  GetAvailableUsersUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<ChatUser>>> call(
      GetAvailableUsersParams params) async {
    return await repository.getAvailableUsers(
      userType: params.userType,
      propertyId: params.propertyId,
    );
  }
}

/// العربية: يمثل `GetAvailableUsersParams`.
class GetAvailableUsersParams extends Equatable {
  /// العربية: يخزن القيمة `userType`.
  final String? userType;

  /// العربية: يخزن القيمة `propertyId`.
  final String? propertyId;

  /// العربية: ينشئ مثيلًا جديدًا من `GetAvailableUsersParams`.
  const GetAvailableUsersParams({
    this.userType,
    this.propertyId,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [userType, propertyId];
}
