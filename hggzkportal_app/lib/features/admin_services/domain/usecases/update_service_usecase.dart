import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/money.dart';
import '../entities/pricing_model.dart';
import '../repositories/services_repository.dart';

/// ✏️ Use Case لتحديث خدمة
class UpdateServiceUseCase implements UseCase<bool, UpdateServiceParams> {
  /// العربية: يخزن القيمة `repository`.
  final ServicesRepository repository;
  UpdateServiceUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(UpdateServiceParams params) async {
    return await repository.updateService(
      serviceId: params.serviceId,
      name: params.name,
      nameEn: params.nameEn,
      price: params.price,
      pricingModel: params.pricingModel,
      icon: params.icon,
      description: params.description,
      descriptionEn: params.descriptionEn,
    );
  }
}

class UpdateServiceParams extends Equatable {
  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;
  final String? name;
  final String? nameEn;
  final Money? price;
  final PricingModel? pricingModel;
  final String? icon;
  final String? description;
  final String? descriptionEn;
  const UpdateServiceParams({
    required this.serviceId,
    this.name,
    this.nameEn,
    this.price,
    this.pricingModel,
    this.icon,
    this.description,
    this.descriptionEn,
  });
  @override
  List<Object?> get props => [
        serviceId,
        name,
        nameEn,
        price,
        pricingModel,
        icon,
        description,
        descriptionEn
      ];
}
