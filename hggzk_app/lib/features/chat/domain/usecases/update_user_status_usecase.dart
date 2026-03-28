import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `UpdateUserStatusUseCase`.
class UpdateUserStatusUseCase implements UseCase<void, UpdateUserStatusParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `UpdateUserStatusUseCase`.
  UpdateUserStatusUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(UpdateUserStatusParams params) async {
    return await repository.updateUserStatus(params.status);
  }
}

/// العربية: يمثل `UpdateUserStatusParams`.
class UpdateUserStatusParams extends Equatable {
  /// العربية: يخزن القيمة `status`.
  final String status;

  /// العربية: ينشئ مثيلًا جديدًا من `UpdateUserStatusParams`.
  const UpdateUserStatusParams({required this.status});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [status];
}
