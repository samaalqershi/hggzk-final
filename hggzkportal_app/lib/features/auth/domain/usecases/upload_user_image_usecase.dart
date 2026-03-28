import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `UploadUserImageUseCase`.
/// Describes the `UploadUserImageUseCase` class.
class UploadUserImageUseCase implements UseCase<User, UploadUserImageParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `UploadUserImageUseCase`.
  /// Builds an instance of `UploadUserImageUseCase`.
  UploadUserImageUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, User>> call(UploadUserImageParams params) async {
    return await repository.uploadProfileImage(
      imagePath: params.imagePath,
    );
  }
}

/// يعرّف الكلاس `UploadUserImageParams`.
/// Describes the `UploadUserImageParams` class.
class UploadUserImageParams extends Equatable {
  /// Holds the `imagePath` value.
  /// العربية: يخزن القيمة `imagePath`.
  final String imagePath;

  /// ينشئ مثيلاً من `UploadUserImageParams`.
  /// Builds an instance of `UploadUserImageParams`.
  const UploadUserImageParams({
    required this.imagePath,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [imagePath];
}
