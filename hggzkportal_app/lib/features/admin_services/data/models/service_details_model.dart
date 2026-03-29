import '../../domain/entities/service_details.dart';
import 'money_model.dart';
import '../../domain/entities/pricing_model.dart';

/// 📋 Model لتفاصيل الخدمة
class ServiceDetailsModel extends ServiceDetails {
  /// العربية: ينشئ مثيلًا جديدًا من `ServiceDetailsModel`.
  const ServiceDetailsModel({
    required super.id,
    required super.propertyId,
    required super.propertyName,
    super.propertyNameEn,
    required super.name,
    super.nameEn,
    required super.price,
    required super.pricingModel,
    required super.icon,
    super.createdAt,
    super.updatedAt,
    super.description,
    super.descriptionEn,
  });
  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    // Handle pricing model from backend format
    final pricingModelData = json['pricingModel'];
    PricingModel pricingModel;

    if (pricingModelData is Map) {
      pricingModel = PricingModel.fromValue(pricingModelData.keys.first);
    } else {
      pricingModel =
          PricingModel.fromValue('${pricingModelData ?? 'PerBooking'}');
    }

    return ServiceDetailsModel(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      propertyName: json['propertyName'] ?? '',
      propertyNameEn: json['propertyNameEn'],
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      price: MoneyModel.fromJson(json['price'] ?? {}),
      pricingModel: pricingModel,
      icon: json['icon'] ?? 'room_service',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      description: json['description'],
      descriptionEn: json['descriptionEn'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyNameEn': propertyNameEn,
      'name': name,
      'nameEn': nameEn,
      'price': MoneyModel(
        amount: price.amount,
        currency: price.currency,
        formattedAmount: price.formattedAmount,
      ).toJson(),
      'pricingModel': pricingModel.value,
      'icon': icon,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
      'descriptionEn': descriptionEn,
    };
  }

  ServiceDetails toEntity() => ServiceDetails(
        id: id,
        propertyId: propertyId,
        propertyName: propertyName,
        propertyNameEn: propertyNameEn,
        name: name,
        nameEn: nameEn,
        price: price,
        pricingModel: pricingModel,
        icon: icon,
        createdAt: createdAt,
        updatedAt: updatedAt,
        description: description,
        descriptionEn: descriptionEn,
      );
}
