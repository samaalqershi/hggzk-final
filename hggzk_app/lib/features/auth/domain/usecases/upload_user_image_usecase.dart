import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// يرفع صورة الملف الشخصي ويعيد نسخة المستخدم بعد تحديث الصورة في الخادم.
/// Uploads a profile image and returns the updated user entity once the
/// backend accepts it.
class UploadUserImageUseCase implements UseCase<User, UploadUserImageParams> {
  /// المستودع الذي ينفذ الرفع ويسترجع بيانات المستخدم المحدثة.
  /// Repository that performs the upload and fetches the updated user data.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  UploadUserImageUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UploadUserImageParams params) async {
    return await repository.uploadProfileImage(
      imagePath: params.imagePath,
    );
  }
}

/// يحمل مسار الصورة المحلية الجاهزة للرفع.
/// Holds the local image path ready to be uploaded.
class UploadUserImageParams extends Equatable {
  /// المسار المحلي للصورة التي اختارها المستخدم.
  /// Local path of the image selected by the user.
  final String imagePath;

  const UploadUserImageParams({
    required this.imagePath,
  });
  @override
  List<Object?> get props => [imagePath];
}
