import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/services_repository.dart';

/// 🗑️ Use Case لحذف خدمة
class DeleteServiceUseCase implements UseCase<bool, String> {
  /// العربية: يخزن القيمة `repository`.
  final ServicesRepository repository;
  DeleteServiceUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(String serviceId) async {
    return await repository.deleteService(serviceId);
  }
}
