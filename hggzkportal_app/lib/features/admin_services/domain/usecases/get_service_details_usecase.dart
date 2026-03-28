import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_details.dart';
import '../repositories/services_repository.dart';

/// 📋 Use Case لجلب تفاصيل خدمة
class GetServiceDetailsUseCase implements UseCase<ServiceDetails, String> {
  /// العربية: يخزن القيمة `repository`.
  final ServicesRepository repository;
  GetServiceDetailsUseCase(this.repository);
  @override
  Future<Either<Failure, ServiceDetails>> call(String serviceId) async {
    return await repository.getServiceDetails(serviceId);
  }
}
