import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/money.dart';
import '../entities/pricing_model.dart';
import '../repositories/services_repository.dart';

/// ➕ Use Case لإنشاء خدمة جديدة
class CreateServiceUseCase implements UseCase<String, CreateServiceParams> {
  /// العربية: يخزن القيمة `repository`.
  final ServicesRepository repository;
  CreateServiceUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(CreateServiceParams params) async {
    return await repository.createService(
      propertyId: params.propertyId,
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

class CreateServiceParams extends Equatable {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  final String name;
  final String? nameEn;
  final Money price;
  final PricingModel pricingModel;
  final String icon;
  final String? description;
  final String? descriptionEn;
  const CreateServiceParams({
    required this.propertyId,
    required this.name,
    this.nameEn,
    required this.price,
    required this.pricingModel,
    required this.icon,
    this.description,
    this.descriptionEn,
  });
  @override
  List<Object?> get props => [
        propertyId,
        name,
        nameEn,
        price,
        pricingModel,
        icon,
        description,
        descriptionEn
      ];
}
